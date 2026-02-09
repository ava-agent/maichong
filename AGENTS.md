# Repository Guidelines

## Project Structure & Module Organization
This repo contains planning docs plus a Flutter app in `maichong/`.
- `maichong/lib/`: Dart source code (feature modules, UI, core).
- `maichong/test/`: Unit, widget, and integration tests (`unit/`, `widget/`, `integration/`).
- `maichong/assets/`: Images, fonts, and other app assets referenced by `pubspec.yaml`.
- `maichong/web/`: Flutter web scaffold and static files.
- `docs/` and other top-level folders (Chinese names): product planning, research, and design references.

## Build, Test, and Development Commands
Run these from `maichong/`:
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
- Environment variables live in your local shell (do not commit secrets).
  - Example keys used by the app: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `DEEPSEEK_API_KEY`, `OPENAI_API_KEY`.
- Keep `pubspec.yaml` and `assets/` in sync when adding files.
