## Configuration Module

This directory contains application configuration and secrets management.

### Files

- **`app_secrets.dart`** - Loads and manages API keys from compile-time environment variables
  - Must be initialized in `main()` before running the app
  - Provides secure access to sensitive configuration
  - Never exposes secrets in logs or debug output

### Usage

```dart
import 'package:shops/config/app_secrets.dart';

void main() async {
  // Initialize secrets from environment configuration
  await AppSecrets.init();
  runApp(const MyApp());
}

// Later, access the API key
if (AppSecrets.hasApiKey) {
  String apiKey = AppSecrets.googleMapsApiKey;
}
```

Pass the API key at build/run time with `--dart-define=GOOGLE_MAPS_API_KEY=...`.

### Security

All sensitive data (API keys, tokens, etc.) should be:
1. Loaded from environment configuration (not in version control)
2. Accessed through `AppSecrets` class
3. Never logged or exposed
4. Never hardcoded in source files
