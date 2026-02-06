# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**脉冲 (Mài Chōng)** is an AI-native life rhythm coordination assistant for individuals and intimate groups (families, couples, friends). The project is currently in the **pre-development planning phase**.

**Core Concept**: Replace traditional calendar grids with a visual timeline interface and AI-driven natural language scheduling.

**Target User**: "The Planner" - the person in every friend group, family, or couple who organizes activities and coordinates schedules.

## Tech Stack (Planned)

- **Frontend**: Flutter (cross-platform mobile)
- **Backend/Database**: Supabase (PostgreSQL + real-time + auth)
- **AI**: DeepSeek or other LLM API for natural language scheduling
- **Language**: Dart (Flutter), TypeScript (Supabase Edge Functions if needed)

## Essential Commands

Once development begins, these will be the standard commands:

```bash
# Flutter
flutter run                    # Run the app
flutter test                   # Run tests
flutter analyze                # Linting
flutter build apk              # Build Android APK
flutter build ios              # Build iOS app

# Supabase (if using CLI)
supabase start                 # Start local dev instance
supabase db push               # Push migrations
supabase gen types typescript  # Generate types
```

## Product Architecture

The app has two main views:

1. **AI Chat View**: Conversation interface where users interact with an AI assistant to create, modify, and query schedules using natural language.

2. **Timeline View**: Vertical scrolling timeline displaying events as "pulse cards" - the core innovation replacing traditional calendar grids.

**Core Data Model** (planned):
- `Events` (脉冲事件): Time-bounded activities with title, time, location, participants
- `Timelines` (时间线): Collections of events, can be shared among users
- `Users`: Standard user profiles with authentication

## Key Differentiators

1. **AI-Native**: Natural language is the primary input method, not a side feature
2. **Visual Timeline**: Vertical flow replaces calendar grid - more intuitive for "life rhythm"
3. **Real-Time Collaboration**: Default "Live Mode" where all changes sync instantly
4. **Shareable Aesthetics**: Generate beautiful images/video of schedules for social sharing
5. **Proposal Mode**: Future feature inspired by Git - changes as "proposals" requiring approval

## MVP Scope (3-Week Plan)

**Week 1**: Single-player timeline (local-only event CRUD)
**Week 2**: Collaboration (Supabase sync, auth, invites)
**Week 3**: AI assistant V1 (natural language → structured events)

## Documentation Structure

- `产品规划/脉冲-产品计划书.md` - **Primary reference** for feature definition and strategy
- `产品规划/脉冲-行动计划.md` - Implementation roadmap and phase breakdown
- `GEMINI.md` - Legacy AI context file (similar to this one)
- `讨论环节1/` - Market research, competitive analysis, architecture planning
- `设计稿1/` & `设计稿2_交互稿/` - UI/UX prototypes (HTML/SVG)

## Important Context

- **Current Phase**: Planning/design. No actual code exists yet.
- **Design Language**: Minimalist, elegant, focused on "pulse" imagery and rhythm
- **Primary Value Prop**: "Sync every pulse" - coordinating life with people who matter
- **Beachhead Market**: Urban professionals aged 18-35 who plan activities for their social circles
