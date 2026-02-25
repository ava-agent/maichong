# 脉冲 Maichong

AI-native life rhythm coordination assistant for intimate groups.

**Live**: https://maichong.vercel.app

## Screenshots

<p align="center">
  <img src="docs/screenshots/01-auth.png" width="180" alt="登录页">
  <img src="docs/screenshots/02-home.png" width="180" alt="首页">
  <img src="docs/screenshots/03-timeline.png" width="180" alt="时间线">
</p>
<p align="center">
  <img src="docs/screenshots/04-chat.png" width="180" alt="AI 助手">
  <img src="docs/screenshots/05-profile.png" width="180" alt="个人页">
  <img src="docs/screenshots/06-event-form.png" width="180" alt="创建事件">
</p>

## Features

- **Bottom Tab Navigation** — 4-tab layout (Home, Timeline, AI Chat, Profile) inspired by Doubao
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
| Icons | Lucide (linear stroke icons, tree-shakeable) |
| Backend | Supabase (Auth + PostgreSQL + Realtime) |
| AI | GLM-4 (OpenAI-compatible) |
| Screenshots | modern-screenshot |
| Deployment | Vercel |

## Quick Start

```bash
npm install          # Install dependencies
npm run dev          # Start dev server (port 3000)
npm run build        # Production build
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
├── views/          # Page-level views (auth, home, timeline, chat, share, profile)
├── components/     # Reusable UI (header, tab-bar, cards, modals, icons, toast)
├── styles/         # CSS modules (variables, layout, chat, forms, tab-bar...)
├── main.js         # App entry point
├── router.js       # Hash-based SPA router with guards
└── config.js       # Environment config
```

### Key Design Decisions

- **No framework** — Vanilla JS with a custom reactive store and hyperscript DOM helpers
- **Three-layer architecture** — `lib/` (zero domain knowledge) -> `services/` (business logic, no DOM) -> `views/` + `components/` (presentation)
- **Graceful degradation** — Falls back to localStorage when Supabase is not configured, mock AI responses when no API key
- **Doubao-inspired UI** — Bottom tab bar, Lucide linear icons, clean white backgrounds, subtle card shadows, large border-radius

### Routes

| Hash Route | View | Tab |
|---|---|---|
| `#/auth` | Login/signup | hidden |
| `#/` | Home (timeline list) | Home |
| `#/timeline/:id` | Timeline events | Timeline |
| `#/timeline/:id/chat` | AI assistant | AI Chat |
| `#/profile` | User profile | Profile |
| `#/timeline/:id/share` | Share card export | hidden |
| `#/join/:code` | Process invite link | hidden |

## Testing

```bash
node scripts/test-e2e.mjs       # Run 64 E2E tests (requires Chrome)
node scripts/screenshot.mjs     # Capture screenshots for docs
```

## Database

Schema: `supabase/migrations/001_initial_schema.sql`

Tables: `profiles`, `timelines`, `timeline_members`, `events`, `chat_messages` — all with Row Level Security policies.

## License

MIT
