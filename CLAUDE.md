# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**脉冲 (Maichong / Pulse)** — AI-native life rhythm coordination assistant for intimate groups (couples, families, close friends). Web SPA with collaborative timelines, AI chat assistant, and shareable schedule cards.

## Build & Dev Commands

```bash
npm install          # Install dependencies
npm run dev          # Start dev server (port 3000)
npm run build        # Production build to dist/
npm run preview      # Preview production build
```

## Tech Stack

- **Frontend**: Vite + Vanilla JS (ES Modules) + CSS Variables
- **Styling**: Apple/iOS design system (Human Interface Guidelines)
- **Icons**: Lucide (linear stroke icons, tree-shakeable ESM imports)
- **Backend**: Supabase (Auth + PostgreSQL + Realtime)
- **AI**: GLM-4 (智谱AI, OpenAI-compatible API)
- **Screenshot**: modern-screenshot (for share card generation)

## Configuration

Copy `.env.example` to `.env` and fill in keys. The app works in demo mode (localStorage) without Supabase config.

## Architecture

### Source Code (`src/`)

- **`main.js`** — App bootstrap, route registration, Supabase auth init
- **`router.js`** — Hash-based SPA router with guards
- **`config.js`** — Environment variable access

#### `lib/` — Framework layer (zero domain knowledge)
- `store.js` — Reactive pub/sub state management. `subscribe(key, callback)` for granular reactivity
- `component.js` — Base component class with mount/unmount lifecycle
- `dom.js` — `h()` hyperscript helper for DOM creation, `$()` query selector
- `supabase.js` — Supabase client singleton

#### `services/` — Business logic (no DOM)
- `auth.service.js` — signUp/signIn/signOut, demo mode fallback
- `timeline.service.js` — Timeline CRUD, membership, invite-via-link
- `event.service.js` — Pulse event CRUD, date grouping, formatting. Falls back to localStorage
- `realtime.service.js` — Supabase Realtime subscriptions for events/members
- `ai.service.js` — GLM-4 chat integration, system prompt builder, action executor. Falls back to mock responses
- `share.service.js` — Share card DOM generation, screenshot export

#### `views/` — Page-level views (mounted by router)
- `auth.view.js` — Login/signup or demo mode entry
- `timeline-list.view.js` — Home page, list of timelines
- `timeline.view.js` — Single timeline with pulse cards, FAB for event creation
- `chat.view.js` — AI chat interface with iOS Messages-style bubbles
- `share-preview.view.js` — Share card preview with download
- `profile.view.js` — User profile with settings and logout

#### `components/` — Reusable UI pieces
- `header.js` — Navigation header with Lucide icon system (`createIcon('back')`)
- `icons.js` — Lucide icon wrapper with tree-shakeable imports
- `tab-bar.js` — Bottom tab navigation (4 tabs: Home, Timeline, AI Chat, Profile)
- `pulse-card.js` — Event card with status indicator
- `event-form.js` — Bottom-sheet modal for creating/editing events
- `input-bar.js` — Bottom input bar with `aboveTabBar` positioning
- `chat-message.js` — Chat bubbles, typing indicator, suggestion chips
- `avatar-stack.js` — Overlapping member avatars
- `loading-spinner.js` — Loading indicator and overlay
- `modal.js` — Generic bottom-sheet modal
- `toast.js` — Toast notifications (`showToast(msg, type)`)

#### `styles/` — CSS modules imported via `styles/index.css`
- `variables.css` — Design tokens: iOS System Blue (`#007AFF`), 8pt spacing grid, typography scale
- `tab-bar.css` — iOS-style bottom tab navigation (49px height)
- `profile.css` — iOS Settings-style grouped list

### Routes

| Hash Route | View | Tab |
|---|---|---|
| `#/auth` | auth | hidden |
| `#/` | timeline-list | Home |
| `#/timeline/:id` | timeline | Timeline |
| `#/timeline/:id/chat` | chat | AI Chat |
| `#/profile` | profile | Profile |
| `#/timeline/:id/share` | share-preview | hidden |
| `#/join/:code` | (handler) | hidden |

### Database

Schema in `supabase/migrations/001_initial_schema.sql`. Tables: `profiles`, `timelines`, `timeline_members`, `events`, `chat_messages`. All have RLS policies.

## Deployment

- **Frontend**: Vercel — https://maichong.vercel.app
- **Backend**: Supabase (project `evljxrlicctchscyfuan`, region `ap-northeast-1`)
- **CI**: Push to `main` triggers Vercel auto-deploy

## Product Documents

- `产品规划/脉冲-产品计划书.md` — **Primary source of truth** for product vision and features
- `产品规划/脉冲-行动计划.md` — Development roadmap
- `设计稿1/` + `设计稿2_交互稿/` — Original HTML prototypes (reference only)
