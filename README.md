# 脉冲 Maichong

AI-native life rhythm coordination assistant for intimate groups.

**Live**: https://maichong.vercel.app

## Screenshots

<p align="center">
  <img src="docs/screenshots/01-auth.png" width="200" alt="登录页">
  <img src="docs/screenshots/02-home.png" width="200" alt="首页">
  <img src="docs/screenshots/03-timeline.png" width="200" alt="时间线">
  <img src="docs/screenshots/04-chat.png" width="200" alt="AI 助手">
</p>

## Features

- **Collaborative Timelines** — Create shared timelines with your partner, family, or friends
- **AI Chat Assistant** — Tell the AI your plans in natural language and it creates events automatically
- **Realtime Sync** — Changes are synced instantly across all members via Supabase Realtime
- **Share Cards** — Generate beautiful screenshot cards of your schedule to share
- **Invite via Link** — Share an invite link to add members to your timeline
- **Demo Mode** — Try the app without signing up (data stored in localStorage)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Vite + Vanilla JS (ES Modules) |
| Styling | CSS Variables, system fonts |
| Backend | Supabase (Auth + PostgreSQL + Realtime) |
| AI | GLM-4 (智谱AI, OpenAI-compatible) |
| Screenshots | modern-screenshot |
| Deployment | Vercel |

## Quick Start

```bash
# Install dependencies
npm install

# Start dev server (port 3000)
npm run dev

# Production build
npm run build
```

### Configuration

Copy `.env.example` to `.env` and fill in your keys:

```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_GLM4_API_KEY=your-glm4-api-key
```

Without `.env`, the app runs in **demo mode** using localStorage.

## Architecture

```
src/
├── lib/            # Framework layer (store, router, DOM helpers)
├── services/       # Business logic (auth, timeline, events, AI, realtime)
├── views/          # Page-level views (auth, home, timeline, chat, share)
├── components/     # Reusable UI (header, cards, modals, toast)
├── styles/         # CSS modules (variables, layout, chat, forms...)
├── main.js         # App entry point
├── router.js       # Hash-based SPA router
└── config.js       # Environment config
```

### Key Design Decisions

- **No framework** — Vanilla JS with a custom reactive store and hyperscript DOM helpers
- **Three-layer architecture** — `lib/` (zero domain knowledge) → `services/` (business logic, no DOM) → `views/` + `components/` (presentation)
- **Graceful degradation** — Falls back to localStorage when Supabase is not configured, mock AI responses when no API key
- **Doubao-inspired UI** — Clean white backgrounds, solid blue accents, minimal shadows, system fonts

## Database

Schema: `supabase/migrations/001_initial_schema.sql`

Tables: `profiles`, `timelines`, `timeline_members`, `events`, `chat_messages` — all with Row Level Security policies.

## License

MIT
