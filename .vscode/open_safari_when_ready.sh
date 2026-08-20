#!/usr/bin/env bash
# Polls Flutter web on :8080 then opens Safari on the booted iOS Simulator.
# Runs detached so it cannot block the Dart launch (preLaunchTask).

echo "[$(date +%H:%M:%S)] Waiting for Flutter on http://127.0.0.1:8080 ..."
n=0
until curl -sf -o /dev/null http://127.0.0.1:8080; do
  n=$((n + 2))
  echo "[$(date +%H:%M:%S)] still waiting (${n}s)"
  sleep 2
done

IP="$(ipconfig getifaddr en0 || true)"
if [[ -z "${IP}" ]]; then
  echo "[$(date +%H:%M:%S)] ERROR: no Wi-Fi IP on en0"
  exit 1
fi

echo "[$(date +%H:%M:%S)] Opening http://${IP}:8080 on Simulator"
xcrun simctl openurl booted "http://${IP}:8080"
echo "[$(date +%H:%M:%S)] Safari opened"
