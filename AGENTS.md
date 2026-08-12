# AGENTS.md

Operator notes for this repo. Node >= 22, pnpm 10.

## Environment

- `OPENAI_API_KEY` is already exported in the environment. Use it from the environment — do not copy the value into `.env.local`, `.env`, source files, or commits.
- Postgres is already provisioned and migrated (`POSTGRES_URL` is set). You do not need to run `pnpm db:migrate`.
- `REDIS_URL` is optional and unset by default; the app runs without it.

## Running

```bash
pnpm install     # if node_modules is absent
pnpm dev         # http://localhost:3000
```

## Verifying

```bash
pnpm smoke
```

One command, end to end: reuses the dev server if one is running (starts one and leaves it up otherwise), does the guest-auth handshake, sends a chat message, and prints the streamed reply. Exits 0 on success, non-zero with a one-line reason on failure. Safe to run repeatedly.

## Layout

- `app/(chat)/api/chat/route.ts` — the chat endpoint (streaming, tool calling)
- `lib/ai/` — model config, provider, prompts, tools
- `lib/db/` — Drizzle schema, queries, migrations
