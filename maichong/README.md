# 脉冲 (Mài Chōng)

AI-native life rhythm coordination assistant.

## Getting Started

This project requires Flutter SDK 3.24+.

### Install Flutter

1. Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. Add Flutter to your PATH
3. Run `flutter doctor` to verify installation
4. Enable Web support: `flutter config --enable-web`

### Run the App

```bash
# Install dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome

# Build for production
flutter build web
```

## Project Structure

```
lib/
├── core/           # Core configurations
├── data/           # Data layer
├── domain/         # Domain layer
├── presentation/   # UI layer
└── services/       # Services
```

## Documentation

See [docs/](../docs) for project documentation.
