# Secure Secrets Management

## Overview

This project uses **environment variables** with `flutter_dotenv` to securely manage API keys and sensitive data. **API keys are NEVER hardcoded in source code.**

## File Structure

```
shops/
├── .env                    # ⚠️ LOCAL ONLY - Contains actual API keys (NOT in git)
├── .env.sample            # Template showing required variables (safe to share)
├── .env.local             # Optional local overrides (also NOT in git)
├── lib/
│   └── config/
│       └── app_secrets.dart # Secure configuration loader
└── .gitignore             # Prevents committing .env files
```

## Setup Instructions

### 1. For Local Development

**First time setup:**

```bash
# Copy the sample file
cp .env.sample .env

# Edit .env and add your actual API key
# .env:
GOOGLE_MAPS_API_KEY=your_actual_key_here
```

### 2. For Team Members

1. Clone the repository
2. Copy the template:
   ```bash
   cp .env.sample .env
   ```
3. Add your own API key to `.env`:
   ```
   GOOGLE_MAPS_API_KEY=your_key_here
   ```
4. **Never commit the `.env` file** - it's in `.gitignore`

## How It Works

### Loading Secrets

The app initializes secrets in `main()` before running the app:

```dart
import 'package:shops/config/app_secrets.dart';

void main() async {
  // Load environment variables from .env file
  await AppSecrets.init();
  runApp(const MyApp());
}
```

### Accessing Secrets

Use the `AppSecrets` class to access configuration:

```dart
import 'package:shops/config/app_secrets.dart';

// Get the API key
String apiKey = AppSecrets.googleMapsApiKey;

// Check if API key is configured
if (AppSecrets.hasApiKey) {
  // Use Google Maps
}
```

## Security Best Practices

✅ **DO:**
- Store API keys in `.env` file only
- Use `.env.sample` as a template for team members
- Add `.env` to `.gitignore` (already done)
- Rotate API keys regularly
- Restrict API keys in Google Cloud Console to:
  - Specific Android app package names
  - Specific iOS bundle identifiers
  - Maps API usage only

❌ **DON'T:**
- Commit `.env` files to version control
- Hardcode API keys in source files
- Share `.env` files via email or messaging
- Use production API keys in development
- Leave API keys with unrestricted access

## .gitignore Protection

The following patterns are in `.gitignore` to prevent accidents:

```
# Environment variables and API keys - NEVER COMMIT THESE
.env
.env.local
.env.*.local
!.env.sample
```

This ensures:
- `.env` and `.env.local` are never committed
- `.env.*.local` (environment-specific local files) are never committed
- `.env.sample` is safe to commit (it's the exception with `!`)

## CI/CD Deployment

For GitHub Actions or other CI/CD:

1. **Never commit `.env` files**
2. **Add secrets to GitHub Secrets:**
   - Go to: Settings > Secrets and variables > Actions
   - Add `GOOGLE_MAPS_API_KEY` secret
3. **In workflow file:**
   ```yaml
   - name: Create .env file
     run: echo "GOOGLE_MAPS_API_KEY=${{ secrets.GOOGLE_MAPS_API_KEY }}" > .env
   
   - name: Build
     run: flutter build apk
   ```

## Troubleshooting

**"GOOGLE_MAPS_API_KEY not found":**
- Verify `.env` file exists in project root
- Verify the format: `GOOGLE_MAPS_API_KEY=your_key_here`
- No spaces around the `=`
- Run `flutter clean` and try again

**API key not loading:**
- Check that `AppSecrets.init()` is called in `main()`
- Verify `flutter_dotenv: ^5.1.0` is in `pubspec.yaml`
- Run `flutter pub get`

**Maps still not working after adding key:**
- Verify API key is valid in Google Cloud Console
- Check that Maps APIs are enabled
- Verify platform restrictions (Android package name, iOS bundle ID)
- Wait a few minutes for API key to propagate

## Files NOT to Commit

These files contain sensitive data and are protected by `.gitignore`:

- `.env` - Your local API keys
- `.env.local` - Local environment overrides
- Any `.env.*.local` files - Environment-specific local config
