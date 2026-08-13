# AGENTS.md

Run `pnpm smoke` to verify the app end to end. It starts or reuses the dev server, sends a real chat message, prints the reply, and exits non-zero with a one-line reason if anything is broken. Run it after any change.

`OPENAI_API_KEY` is already exported in the environment — use it from there, never copy the value into a file.

Postgres is already provisioned and migrated. Do not run `pnpm db:migrate`.

Start the app with `pnpm dev` (http://localhost:3000). Node >= 22, pnpm 10, deps already installed.
