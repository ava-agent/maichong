# Repository Guidelines

## Project Structure & Module Organization
This repo contains a production-oriented Vite/Vanilla JS web app at the root plus a Flutter implementation/reference in `maichong/`.
- `src/`: root Vite app source for `maichong.rxcloud.group`.
- `scripts/`: screenshot, syntax-check, and E2E helper scripts.
- `supabase/` and `docs/supabase/`: database migrations for the Vite app.
- `maichong/lib/`: Dart source code for the Flutter implementation/reference.
- `maichong/test/`: Flutter unit/widget/integration tests.
- `maichong/assets/`: Flutter app assets referenced by `pubspec.yaml`.
- `maichong/web/`: Flutter web scaffold and static files.
- `docs/` and other top-level folders (Chinese names): product planning, research, and design references.

## Build, Test, and Development Commands
Run these from the repository root for the current Vite app:
- `npm install`: install dependencies.
- `npm run dev`: start the Vite dev server on port 3000.
- `npm run build`: build the Vite app to `dist/`.
- `npm run lint`: syntax-check JS/MJS files under `src/`, `scripts/`, and `vite.config.js`.
- `npm run test`: current smoke test alias for `npm run lint`.
- `npm run test:e2e`: run the browser E2E helper when Chrome and a served app are available.

Run these from `maichong/` for the Flutter reference app:
- `flutter pub get`: install dependencies.
- `flutter run -d chrome --web-port 8082`: run the web app locally.
- `start.bat`: Windows helper that runs analyze + launches web app.
- `run.bat`: quick design preview (web).
- `flutter analyze`: static analysis (uses `flutter_lints`).
- `flutter test`: run all tests.
- `verify.bat`: sanity checks for key files and structure.

## Coding Style & Naming Conventions
- Language: Dart / Flutter.
- Linting: `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`.
- Formatting: use `dart format .` before committing.
- Naming: files in `snake_case`, classes in `PascalCase`, and widgets in `PascalCase`.

## Testing Guidelines
- Frameworks: `flutter_test` for unit/widget tests; `integration_test` for integration tests.
- Location: place tests under `test/unit/`, `test/widget/`, `test/integration/`.
- Naming: end test files with `_test.dart` (e.g., `test/unit/event_test.dart`).
- Coverage: run `flutter test --coverage` when making significant changes.

## Commit & Pull Request Guidelines
- Commit messages follow Conventional Commits (`feat:`, `fix:`); keep them scoped and imperative.
- PRs should include:
  - Summary of changes and rationale.
  - Linked issue/task (if applicable).
  - Screenshots or screen recordings for UI changes (web/mobile).
  - Notes on testing performed (commands and results).

## Security & Configuration Tips
- Environment variables live in local `.env` files or deployment settings; do not commit secrets.
- Root Vite app uses `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, and `VITE_AI_CHAT_ENDPOINT`; the Vercel API route uses server-side `ARK_API_KEY`, `ARK_BASE_URL`, and `ARK_CHAT_MODEL`.
- Flutter reference docs mention `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `DEEPSEEK_API_KEY`, and `OPENAI_API_KEY`.
- Keep `pubspec.yaml` and `assets/` in sync when adding Flutter files.
