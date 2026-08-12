#!/usr/bin/env bash
# End-to-end check: guest auth -> POST /api/chat -> streamed reply (with a getWeather tool call).
# Reuses an already-running dev server; starts one and leaves it running if there isn't.
# Exits 0 on success, non-zero with a one-line reason on failure.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-3000}"
BASE="http://127.0.0.1:${PORT}"
WORK="${ROOT}/.smoke"
DEV_LOG="${WORK}/dev.log"
JAR="${WORK}/cookies.txt"
STREAM="${WORK}/stream.sse"
READY_TIMEOUT="${SMOKE_READY_TIMEOUT:-60}"
CHAT_TIMEOUT="${SMOKE_CHAT_TIMEOUT:-45}"
PROMPT="${SMOKE_PROMPT:-What is the weather in San Francisco right now?}"

fail() {
  echo "SMOKE FAIL: $1" >&2
  exit "${2:-1}"
}

mkdir -p "$WORK" || fail "cannot create ${WORK}"

command -v curl >/dev/null 2>&1 || fail "curl is not installed" 1
[ -x "${ROOT}/node_modules/.bin/next" ] || fail "dependencies missing — run 'pnpm install' first" 1

if [ -z "${OPENAI_API_KEY:-}" ] && ! grep -qs '^OPENAI_API_KEY=' "${ROOT}/.env.local" "${ROOT}/.env"; then
  fail "OPENAI_API_KEY is not set (export it, or put it in .env.local)" 1
fi
if [ -z "${POSTGRES_URL:-}" ] && ! grep -qs '^POSTGRES_URL=' "${ROOT}/.env.local" "${ROOT}/.env"; then
  fail "POSTGRES_URL is not set (export it, or put it in .env.local)" 1
fi

is_up() {
  [ "$(curl -fsS --max-time 2 "${BASE}/ping" 2>/dev/null)" = "pong" ]
}

if is_up; then
  echo "server: already running on :${PORT}"
else
  echo "server: starting on :${PORT} (logs: ${DEV_LOG})"
  ( cd "$ROOT" && nohup "${ROOT}/node_modules/.bin/next" dev --turbo --port "$PORT" >"$DEV_LOG" 2>&1 & )

  deadline=$(( SECONDS + READY_TIMEOUT ))
  until is_up; do
    if grep -qsE 'EADDRINUSE|is in use' "$DEV_LOG"; then
      fail "port ${PORT} is taken by something that is not this app — free it or set PORT=" 2
    fi
    [ "$SECONDS" -lt "$deadline" ] || fail "server did not become ready within ${READY_TIMEOUT}s (see ${DEV_LOG})" 2
    sleep 0.25
  done
  echo "server: ready (left running for subsequent runs)"
fi

# Warm the chat route so its first compile does not land on the timed request.
curl -fsS --max-time 20 -o /dev/null -X POST "${BASE}/api/chat" \
  -H 'content-type: application/json' -d '{}' 2>/dev/null || true

rm -f "$JAR"
guest_status=$(curl -sS -c "$JAR" -b "$JAR" -L --max-time 20 -o /dev/null -w '%{http_code}' \
  "${BASE}/api/auth/guest?redirectUrl=%2Fping" 2>/dev/null) \
  || fail "guest auth request failed (is the server healthy? see ${DEV_LOG})" 3
grep -q 'session-token' "$JAR" 2>/dev/null \
  || fail "guest auth did not set a session cookie (HTTP ${guest_status})" 3
echo "auth: guest session established"

command -v node >/dev/null 2>&1 || fail "node is not installed" 1
chat_id=$(node -e 'console.log(crypto.randomUUID())') || fail "could not generate a uuid" 1
message_id=$(node -e 'console.log(crypto.randomUUID())')

payload=$(PROMPT="$PROMPT" CHAT_ID="$chat_id" MESSAGE_ID="$message_id" node -e '
  process.stdout.write(JSON.stringify({
    id: process.env.CHAT_ID,
    message: {
      id: process.env.MESSAGE_ID,
      role: "user",
      parts: [{ type: "text", text: process.env.PROMPT }],
    },
    selectedChatModel: "gpt-5-mini",
    selectedVisibilityType: "private",
  }));
') || fail "could not build the request payload" 1

echo "chat: ${PROMPT}"
curl -sS --no-buffer -b "$JAR" -c "$JAR" --max-time "$CHAT_TIMEOUT" \
  -X POST "${BASE}/api/chat" -H 'content-type: application/json' -d "$payload" \
  >"$STREAM" 2>/dev/null \
  || fail "chat request failed or timed out after ${CHAT_TIMEOUT}s (raw stream: ${STREAM})" 4

node -e '
  const fs = require("node:fs");
  const lines = fs.readFileSync(process.argv[1], "utf8").split("\n");
  let text = "";
  let toolCall = false;
  let error = null;

  for (const line of lines) {
    if (!line.startsWith("data: ")) { continue; }
    const body = line.slice(6).trim();
    if (!body || body === "[DONE]") { continue; }
    let part;
    try { part = JSON.parse(body); } catch { continue; }
    if (typeof part.type === "string" && part.type.includes("getWeather")) { toolCall = true; }
    if (part.toolName === "getWeather") { toolCall = true; }
    if (part.type === "text-delta" && typeof part.delta === "string") { text += part.delta; }
    if (part.type === "error") { error = part.errorText || "unknown error"; }
  }

  if (error) {
    console.error(`SMOKE FAIL: the model call errored: ${error}`);
    process.exit(4);
  }
  if (!text.trim() && !toolCall) {
    console.error("SMOKE FAIL: no assistant output in the stream");
    process.exit(4);
  }

  console.log("---");
  console.log(text.trim() || "(tool call only, no text)");
  console.log("---");
  console.log(toolCall ? "tool: getWeather called" : "tool: WARNING — model answered without calling getWeather");
' "$STREAM"
status=$?
[ "$status" -eq 0 ] || exit "$status"

echo "SMOKE OK"
