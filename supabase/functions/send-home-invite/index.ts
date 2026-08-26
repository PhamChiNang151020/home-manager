// Sends a Vietnamese invite email via Resend with the home join URL.
// Secrets: RESEND_API_KEY, INVITE_FROM_EMAIL, APP_PUBLIC_URL
// Optional: SUPABASE_URL + SUPABASE_ANON_KEY + SUPABASE_SERVICE_ROLE_KEY
// (provided automatically on hosted Supabase).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return json({ error: "missing authorization" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const resendKey = Deno.env.get("RESEND_API_KEY") ?? "";
    const fromEmail = Deno.env.get("INVITE_FROM_EMAIL") ?? "";
    const appPublicUrl = (Deno.env.get("APP_PUBLIC_URL") ?? "").replace(
      /\/?$/,
      "/",
    );

    if (!supabaseUrl || !anonKey || !serviceKey) {
      return json({ error: "supabase env not configured" }, 500);
    }
    if (!resendKey || !fromEmail || !appPublicUrl) {
      return json(
        {
          error:
            "email env not configured (RESEND_API_KEY, INVITE_FROM_EMAIL, APP_PUBLIC_URL)",
        },
        500,
      );
    }

    const body = await req.json().catch(() => null);
    const inviteId = typeof body?.invite_id === "string" ? body.invite_id : "";
    if (!inviteId) {
      return json({ error: "invite_id required" }, 400);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();
    if (userError || !user) {
      return json({ error: "unauthorized" }, 401);
    }

    const admin = createClient(supabaseUrl, serviceKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const { data: invite, error: inviteError } = await admin
      .from("home_invites")
      .select("id, home_id, email, status, expires_at, invited_by")
      .eq("id", inviteId)
      .maybeSingle();

    if (inviteError || !invite) {
      return json({ error: "invite not found" }, 404);
    }
    if (invite.status !== "pending") {
      return json({ error: "invite is not pending" }, 400);
    }

    const { data: membership } = await admin
      .from("home_members")
      .select("role")
      .eq("home_id", invite.home_id)
      .eq("user_id", user.id)
      .maybeSingle();
    if (membership?.role !== "owner") {
      return json({ error: "only owner can send invite email" }, 403);
    }

    const { data: home } = await admin
      .from("homes")
      .select("name")
      .eq("id", invite.home_id)
      .maybeSingle();

    const { data: inviter } = await admin
      .from("profiles")
      .select("display_name, email")
      .eq("id", invite.invited_by)
      .maybeSingle();

    const { data: joinLink, error: joinError } = await userClient.rpc(
      "create_or_get_join_link",
      { p_home_id: invite.home_id, p_rotate: false },
    );
    if (joinError || !joinLink?.token) {
      await markEmailError(admin, inviteId, joinError?.message ?? "join link failed");
      return json({ error: "could not create join link" }, 502);
    }

    const joinUrl = buildJoinUrl(appPublicUrl, joinLink.token as string);
    const homeName = (home?.name as string | undefined) ?? "nhà";
    const inviterName =
      (inviter?.display_name as string | undefined)?.trim() ||
      (inviter?.email as string | undefined) ||
      "Chủ nhà";
    const expiresAt = invite.expires_at
      ? new Date(invite.expires_at as string)
      : null;
    const expiresLabel = expiresAt
      ? expiresAt.toLocaleDateString("vi-VN")
      : "14 ngày";

    const subject = `${inviterName} mời bạn vào nhà «${homeName}» trên Tổ Ấm`;
    const html = buildEmailHtml({
      homeName,
      inviterName,
      inviteeEmail: invite.email as string,
      joinUrl,
      expiresLabel,
    });
    const text = [
      `${inviterName} mời bạn vào nhà «${homeName}» trên Tổ Ấm.`,
      `Mở liên kết rồi đăng nhập Google (nên dùng ${invite.email}):`,
      joinUrl,
      `Mã có hạn đến ${expiresLabel}.`,
    ].join("\n");

    const resendRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${resendKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: fromEmail,
        to: [invite.email],
        subject,
        html,
        text,
      }),
    });

    if (!resendRes.ok) {
      const detail = await resendRes.text();
      await markEmailError(admin, inviteId, detail.slice(0, 500));
      return json({ error: "resend failed", detail }, 502);
    }

    await admin
      .from("home_invites")
      .update({ email_sent_at: new Date().toISOString(), email_last_error: null })
      .eq("id", inviteId);

    return json({ ok: true, join_url: joinUrl });
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return json({ error: message }, 500);
  }
});

function buildJoinUrl(baseUrl: string, token: string): string {
  const url = new URL(baseUrl);
  url.searchParams.set("join", token);
  return url.toString();
}

async function markEmailError(
  admin: ReturnType<typeof createClient>,
  inviteId: string,
  error: string,
) {
  await admin
    .from("home_invites")
    .update({ email_last_error: error.slice(0, 500) })
    .eq("id", inviteId);
}

function buildEmailHtml(args: {
  homeName: string;
  inviterName: string;
  inviteeEmail: string;
  joinUrl: string;
  expiresLabel: string;
}): string {
  const { homeName, inviterName, inviteeEmail, joinUrl, expiresLabel } = args;
  return `<!DOCTYPE html>
<html lang="vi">
<body style="margin:0;padding:24px;background:#0B0D10;color:#F5F6F8;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width:520px;margin:0 auto;background:#151A21;border-radius:16px;padding:28px;">
    <tr><td>
      <p style="margin:0 0 8px;font-size:13px;color:#A8B0BD;">Tổ Ấm</p>
      <h1 style="margin:0 0 16px;font-size:22px;line-height:1.3;color:#FFFFFF;">Mời vào nhà «${escapeHtml(homeName)}»</h1>
      <p style="margin:0 0 16px;font-size:15px;line-height:1.5;color:#D5DAE2;">
        <strong style="color:#FFFFFF;">${escapeHtml(inviterName)}</strong> mời bạn cùng theo dõi điện, nước và chi tiêu.
      </p>
      <p style="margin:0 0 24px;font-size:14px;line-height:1.5;color:#A8B0BD;">
        Bấm nút bên dưới, rồi đăng nhập Google (nên dùng <strong style="color:#D5DAE2;">${escapeHtml(inviteeEmail)}</strong>).
      </p>
      <p style="margin:0 0 28px;">
        <a href="${escapeAttr(joinUrl)}" style="display:inline-block;background:#E8A838;color:#1A1205;text-decoration:none;font-weight:700;padding:12px 20px;border-radius:10px;">
          Vào nhà
        </a>
      </p>
      <p style="margin:0 0 8px;font-size:12px;line-height:1.5;color:#7A8494;word-break:break-all;">
        Hoặc mở liên kết:<br/>${escapeHtml(joinUrl)}
      </p>
      <p style="margin:16px 0 0;font-size:12px;color:#7A8494;">
        Mã có hạn đến ${escapeHtml(expiresLabel)}. Nếu không nhận ra lời mời, hãy bỏ qua email này.
      </p>
    </td></tr>
  </table>
</body>
</html>`;
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function escapeAttr(value: string): string {
  return escapeHtml(value).replaceAll("'", "&#39;");
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
