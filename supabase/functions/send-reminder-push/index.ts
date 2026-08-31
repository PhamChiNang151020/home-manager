// Reminder push (daily cron) + broadcast push (e.g. new app version after deploy).
// Auth: Bearer CRON_SECRET, or x-cron-secret (GitHub Actions also sends the
// anon JWT in Authorization so the gateway accepts the call when Verify JWT
// is on).
// Secrets: CRON_SECRET, FIREBASE_SERVICE_ACCOUNT_JSON, FIREBASE_PROJECT_ID
// (plus auto SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY).
//
// Body:
//   {} or omitted → daily schedule reminders (Asia/Ho_Chi_Minh)
//   { "mode": "broadcast", "title": "...", "body": "..." } → all fcm_tokens

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import * as jose from "https://esm.sh/jose@5.2.4";
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-cron-secret",
};

type ServiceAccount = {
  client_email: string;
  private_key: string;
  token_uri?: string;
};

type HomeRow = {
  id: string;
  name: string;
  photo_due_day: number | null;
  payday_day: number | null;
  remind_day: number | null;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const cronSecret = Deno.env.get("CRON_SECRET") ?? "";
    if (!isCronAuthorized(req, cronSecret)) {
      return json({ error: "unauthorized" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const projectId = Deno.env.get("FIREBASE_PROJECT_ID") ?? "";
    const saRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON") ?? "";

    if (!supabaseUrl || !serviceKey) {
      return json({ error: "supabase env not configured" }, 500);
    }
    if (!projectId || !saRaw) {
      return json(
        {
          error:
            "firebase env not configured (FIREBASE_PROJECT_ID, FIREBASE_SERVICE_ACCOUNT_JSON)",
        },
        500,
      );
    }

    let serviceAccount: ServiceAccount;
    try {
      serviceAccount = JSON.parse(saRaw) as ServiceAccount;
    } catch {
      return json({ error: "invalid FIREBASE_SERVICE_ACCOUNT_JSON" }, 500);
    }

    const payload = await req.json().catch(() => ({}));
    const admin = createClient(supabaseUrl, serviceKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const accessToken = await getGoogleAccessToken(serviceAccount);

    if (payload?.mode === "broadcast") {
      const title =
        typeof payload.title === "string" && payload.title.trim()
          ? payload.title.trim()
          : "Tổ Ấm";
      const body =
        typeof payload.body === "string" && payload.body.trim()
          ? payload.body.trim()
          : "Có bản cập nhật mới.";
      const result = await sendToAllTokens(
        admin,
        projectId,
        accessToken,
        title,
        body,
      );
      return json({ ok: true, mode: "broadcast", ...result });
    }

    const { year, month, day } = vietnamYmd();

    const { data: homes, error: homesError } = await admin
      .from("homes")
      .select("id, name, photo_due_day, payday_day, remind_day");
    if (homesError) {
      return json({ error: homesError.message }, 500);
    }

    const dueHomes = ((homes ?? []) as HomeRow[]).flatMap((home) => {
      const jobs: { home: HomeRow; kind: string; title: string; body: string }[] =
        [];
      if (
        home.photo_due_day != null &&
        clampDay(home.photo_due_day, year, month) === day
      ) {
        jobs.push({
          home,
          kind: "photo",
          title: "Chụp hoá đơn điện / nước",
          body: `Hôm nay chụp hoá đơn — ${home.name}`,
        });
      }
      if (
        home.payday_day != null &&
        clampDay(home.payday_day, year, month) === day
      ) {
        jobs.push({
          home,
          kind: "payday",
          title: "Lãnh lương",
          body: `Hôm nay lãnh lương — ${home.name}`,
        });
      }
      if (
        home.remind_day != null &&
        clampDay(home.remind_day, year, month) === day
      ) {
        jobs.push({
          home,
          kind: "remind",
          title: "Ghi số & đóng tiền điện / nước",
          body: `Hôm nay ghi số & đóng tiền — ${home.name}`,
        });
      }
      return jobs;
    });

    if (dueHomes.length === 0) {
      return json({
        ok: true,
        mode: "reminders",
        date: `${year}-${pad(month)}-${pad(day)}`,
        sent: 0,
        jobs: 0,
      });
    }

    let sent = 0;
    let failed = 0;
    const details: Record<string, unknown>[] = [];

    for (const job of dueHomes) {
      const { data: members, error: membersError } = await admin
        .from("home_members")
        .select("user_id")
        .eq("home_id", job.home.id)
        .is("left_at", null);
      if (membersError) {
        failed += 1;
        details.push({ home_id: job.home.id, error: membersError.message });
        continue;
      }
      const userIds = (members ?? []).map((m: { user_id: string }) => m.user_id);
      if (userIds.length === 0) continue;

      const { data: tokens, error: tokensError } = await admin
        .from("fcm_tokens")
        .select("token, user_id")
        .in("user_id", userIds);
      if (tokensError) {
        failed += 1;
        details.push({ home_id: job.home.id, error: tokensError.message });
        continue;
      }

      const batch = await deliverTokens(
        admin,
        projectId,
        accessToken,
        (tokens ?? []).map((r: { token: string }) => r.token),
        job.title,
        job.body,
      );
      sent += batch.sent;
      failed += batch.failed;
      for (const d of batch.details) {
        details.push({ home_id: job.home.id, kind: job.kind, ...d });
      }
    }

    return json({
      ok: true,
      mode: "reminders",
      date: `${year}-${pad(month)}-${pad(day)}`,
      jobs: dueHomes.length,
      sent,
      failed,
      details: details.slice(0, 20),
    });
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});

async function sendToAllTokens(
  admin: SupabaseClient,
  projectId: string,
  accessToken: string,
  title: string,
  body: string,
): Promise<{ sent: number; failed: number; details: Record<string, unknown>[] }> {
  const { data: tokens, error } = await admin.from("fcm_tokens").select("token");
  if (error) {
    throw new Error(error.message);
  }
  return deliverTokens(
    admin,
    projectId,
    accessToken,
    (tokens ?? []).map((r: { token: string }) => r.token),
    title,
    body,
  );
}

async function deliverTokens(
  admin: SupabaseClient,
  projectId: string,
  accessToken: string,
  tokens: string[],
  title: string,
  body: string,
): Promise<{ sent: number; failed: number; details: Record<string, unknown>[] }> {
  let sent = 0;
  let failed = 0;
  const details: Record<string, unknown>[] = [];
  const unique = [...new Set(tokens.filter(Boolean))];

  for (const token of unique) {
    try {
      await sendFcm(projectId, accessToken, token, title, body);
      sent += 1;
    } catch (err) {
      failed += 1;
      details.push({ error: String(err) });
      const msg = String(err);
      if (
        msg.includes("UNREGISTERED") ||
        msg.includes("INVALID_ARGUMENT") ||
        msg.includes("NOT_FOUND")
      ) {
        await admin.from("fcm_tokens").delete().eq("token", token);
      }
    }
  }
  return { sent, failed, details };
}

function vietnamYmd(): { year: number; month: number; day: number } {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Ho_Chi_Minh",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(new Date());
  const get = (type: string) =>
    Number(parts.find((p) => p.type === type)?.value ?? "0");
  return { year: get("year"), month: get("month"), day: get("day") };
}

function clampDay(day: number, year: number, month: number): number {
  const daysInMonth = new Date(year, month, 0).getDate();
  return Math.min(Math.max(1, day), daysInMonth);
}

function pad(n: number): string {
  return n < 10 ? `0${n}` : String(n);
}

async function getGoogleAccessToken(sa: ServiceAccount): Promise<string> {
  const pem = sa.private_key.replace(/\\n/g, "\n");
  const key = await jose.importPKCS8(pem, "RS256");
  const jwt = await new jose.SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(sa.client_email)
    .setAudience(sa.token_uri ?? "https://oauth2.googleapis.com/token")
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(key);

  const tokenRes = await fetch(
    sa.token_uri ?? "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: jwt,
      }),
    },
  );
  const tokenJson = await tokenRes.json();
  if (!tokenRes.ok || !tokenJson.access_token) {
    throw new Error(
      `google token failed: ${tokenJson.error ?? tokenRes.status}`,
    );
  }
  return tokenJson.access_token as string;
}

async function sendFcm(
  projectId: string,
  accessToken: string,
  token: string,
  title: string,
  body: string,
): Promise<void> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          webpush: {
            headers: { Urgency: "high" },
            notification: {
              title,
              body,
              icon: "/home-manager/icons/Icon-192.png",
            },
          },
        },
      }),
    },
  );
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`FCM ${res.status}: ${text}`);
  }
}

function isCronAuthorized(req: Request, cronSecret: string): boolean {
  if (!cronSecret) return false;
  const authHeader = req.headers.get("Authorization") ?? "";
  const bearer = authHeader.startsWith("Bearer ")
    ? authHeader.slice("Bearer ".length).trim()
    : "";
  const headerSecret = (req.headers.get("x-cron-secret") ?? "").trim();
  return bearer === cronSecret || headerSecret === cronSecret;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
