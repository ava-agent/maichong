# Deployment

## Production Web App

- Live site: `https://maichong.rxcloud.group`
- GitHub: `ava-agent/maichong`
- Platform: Vercel
- App root: repository root
- Build command: `npm run build`
- Output directory: `dist`
- SPA fallback: all routes rewrite to `/index.html`

## Environment Variables

Set these in Vercel when enabling the cloud/AI path:

```env
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
VITE_AI_CHAT_ENDPOINT=/api/chat
ARK_API_KEY=...
ARK_BASE_URL=https://ark.cn-beijing.volces.com/api/coding/v3
ARK_CHAT_MODEL=doubao-seed-2-0-code-preview-260215
```

Without these variables, the app falls back to demo/localStorage behavior.

## Validation

```bash
npm run lint
npm run test
npm run build
```

Use `npm run test:e2e` only when Chrome and a served app are available.

## Flutter Reference

The `maichong/` subdirectory contains a Flutter implementation/reference. Its deployment path is separate from the current Vite web app and should not be mixed with the root Vercel configuration.
