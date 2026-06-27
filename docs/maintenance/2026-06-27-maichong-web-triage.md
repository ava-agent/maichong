# maichong Web Triage - 2026-06-27

## Repository

- GitHub: `ava-agent/maichong`
- Live site: `https://maichong.rxcloud.group`
- Deployment: Vercel
- Current production app: root Vite/Vanilla JS SPA
- Reference implementation: Flutter app under `maichong/`

## Local State

- `.playwright-mcp/` was the only untracked item at triage time.
- Root `.env`, `.vercel/`, `dist/`, `node_modules/`, and `.DS_Store` were already ignored.

## Actions Taken

- Updated `AGENTS.md` to clarify the dual root Vite app plus `maichong/` Flutter reference structure.
- Added `.playwright-mcp/` to root `.gitignore`.
- Added root `vercel.json` for Vite SPA deployment.
- Added `DEPLOYMENT.md` with production deployment settings and environment variables.
- Replaced `sk-*` style documentation placeholders with angle-bracket placeholders to reduce false-positive secret scans.
- Added `scripts/check-syntax.mjs` and root scripts:
  - `lint`: `node scripts/check-syntax.mjs`
  - `test`: `npm run lint`
  - `test:e2e`: `node scripts/test-e2e.mjs`

## Follow-Up

- Decide whether the Flutter implementation under `maichong/` is active, archival, or a separate product track.
- Add real tests around auth/demo mode, timeline CRUD, AI structured-output actions, and share-card generation.
- Run `npm run test:e2e` only after confirming Chrome and the target server URL expected by `scripts/test-e2e.mjs`.

## Validation

- `npm run lint`: passed; checked 34 JavaScript files
- `npm run test`: passed
- `npm run build`: passed
- Live site check: `https://maichong.rxcloud.group` returned HTTP 200 and the HTML title `脉冲 - 同步每次脉冲`
- `git diff --check`: passed
- Common secret pattern scan: remaining matches are `src/config.js` environment-variable access and an invite-token variable in `docs/API集成规范.md`; no hardcoded production credential identified
- Global inventory refresh: completed; readiness is now 100
