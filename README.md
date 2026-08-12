<a href="https://chatbot.ai-sdk.dev/demo">
  <img alt="Chatbot" src="app/(chat)/opengraph-image.png">
  <h1 align="center">Chatbot</h1>
</a>

<p align="center">
    A minimal, open-source chatbot template built with Next.js and the AI SDK — chat, tools, and persistence, nothing else.
</p>

<p align="center">
  <a href="#features"><strong>Features</strong></a> ·
  <a href="#model-provider"><strong>Model Provider</strong></a> ·
  <a href="#running-locally"><strong>Running locally</strong></a>
</p>
<br/>

## Features

- [Next.js](https://nextjs.org) App Router
  - React Server Components (RSCs) and Server Actions
- [AI SDK](https://ai-sdk.dev/docs/introduction)
  - Streaming chat with tool calling (`getWeather`, with a human-in-the-loop approval flow)
  - Hooks for building dynamic chat UIs
- [shadcn/ui](https://ui.shadcn.com)
  - Styling with [Tailwind CSS](https://tailwindcss.com)
  - Component primitives from [Radix UI](https://radix-ui.com)
- Data Persistence
  - Postgres (via [Drizzle ORM](https://orm.drizzle.team)) for chat history and user data
  - Redis (optional) for resumable streams and IP rate limiting
- [Auth.js](https://authjs.dev)
  - Email/password accounts plus guest sessions

## Model Provider

This template talks to [OpenAI](https://platform.openai.com) directly via `@ai-sdk/openai`. The default model is `gpt-5-mini`; the selectable models live in `lib/ai/models.ts`. Set `OPENAI_API_KEY` to use it.

With the [AI SDK](https://ai-sdk.dev/docs/introduction), you can switch to other providers like [Anthropic](https://anthropic.com), [Google](https://ai.google.dev), or the [Vercel AI Gateway](https://vercel.com/docs/ai-gateway) by changing `lib/ai/providers.ts`.

## Running locally

Copy `.env.example` to `.env.local` and fill it in. Required: `AUTH_SECRET`, `OPENAI_API_KEY`, `POSTGRES_URL`. Optional: `REDIS_URL`.

```bash
pnpm install
pnpm db:migrate # create the database schema
pnpm dev
```

Your app should now be running on [localhost:3000](http://localhost:3000).

Run `pnpm smoke` to verify the app end to end — it handles guest auth, sends a chat message, prints the streamed reply, and exits non-zero if anything is broken.

> Note: You should not commit your `.env.local` file or it will expose secrets.
