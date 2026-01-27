# Google Maps API Key Setup - Android vs iOS

This document explains how the Android and iOS builds obtain the Google Maps API key, highlighting the key differences between the two platforms.

## Overview

Both platforms require the Google Maps API key, but they obtain it through **completely different mechanisms**:

- **Android**: Build-time injection via Gradle and Android manifest
- **iOS**: Runtime injection via xcconfig files and AppDelegate initialization

---

## Android: Build-Time Injection

### How It Works

The Android build process reads the environment variable at **compile time** and injects it into the Android manifest as a meta-data entry.

### Step-by-Step Flow

#### 1. **Set Environment Variable in Shell**
```bash
export GOOGLE_MAPS_API_KEY=yourapikeyhere
```

#### 2. **Gradle Reads Environment Variable**
**File:** [android/app/build.gradle.kts](android/app/build.gradle.kts)

```kotlin
// Read Google Maps API key from environment variable
val googleMapsApiKey: String = System.getenv("GOOGLE_MAPS_API_KEY") ?: ""
```

- `System.getenv("GOOGLE_MAPS_API_KEY")` reads the environment variable
- The `?: ""` provides a default empty string if the variable is not set
- This happens at **build time** when you run `flutter build apk` or `flutter run`

#### 3. **Gradle Injects Into Manifest Placeholder**
Still in [android/app/build.gradle.kts](android/app/build.gradle.kts#L35-L36):

```kotlin
defaultConfig {
    // ... other config ...
    
    // Inject Google Maps API key from environment variable at build time
    if (googleMapsApiKey.isNotEmpty()) {
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }
}
```

- Creates a placeholder variable that will be substituted in the manifest
- Only sets it if the API key is not empty

#### 4. **Android Manifest Uses the Placeholder**
**File:** [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml#L30)

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}" />
```

- During the build, `${GOOGLE_MAPS_API_KEY}` is replaced with the actual API key value
- This meta-data tag is compiled into the app's AndroidManifest.xml

#### 5. **Google Maps SDK Reads at Runtime**
- When the app starts, Google Maps Flutter plugin reads the `com.google.android.geo.API_KEY` meta-data entry
- Initializes the Google Maps SDK with that API key

### Android Summary
```
Shell Environment Variable
    ↓
System.getenv() in Gradle
    ↓
manifestPlaceholders
    ↓
AndroidManifest.xml meta-data
    ↓
Google Maps SDK
```

---

## iOS: Runtime Injection

### How It Works

The iOS build process uses Xcode configuration files (xcconfig) to provide build settings that are embedded in the Info.plist, which are then read at runtime by the AppDelegate.

### Step-by-Step Flow

#### 1. **Set Environment Variable in Shell**
```bash
export GOOGLE_MAPS_API_KEY=yourapikeyhere
```

#### 2. **Xcode Configuration Files Reference the Variable**
**File:** [ios/Flutter/Debug.xcconfig](ios/Flutter/Debug.xcconfig#L7)

```xcconfig
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
#include "Generated.xcconfig"

// Allow developers to provide a local xcconfig with `GOOGLE_MAPS_API_KEY` (ignored in git)
#include? "../Local.xcconfig"

// API key forwarding: INJECTED_GOOGLE_MAPS_API_KEY will be available to Info.plist as $(INJECTED_GOOGLE_MAPS_API_KEY)
INJECTED_GOOGLE_MAPS_API_KEY = $(GOOGLE_MAPS_API_KEY)
```

**File:** [ios/Flutter/Release.xcconfig](ios/Flutter/Release.xcconfig#L7)

```xcconfig
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig"
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
#include "Generated.xcconfig"

// Allow developers to provide a local xcconfig with `GOOGLE_MAPS_API_KEY` (ignored in git)
#include? "../Local.xcconfig"

// API key forwarding: INJECTED_GOOGLE_MAPS_API_KEY will be available to Info.plist as $(INJECTED_GOOGLE_MAPS_API_KEY)
INJECTED_GOOGLE_MAPS_API_KEY = $(GOOGLE_MAPS_API_KEY)
```

- `INJECTED_GOOGLE_MAPS_API_KEY = $(GOOGLE_MAPS_API_KEY)` creates a build setting
- `$(GOOGLE_MAPS_API_KEY)` references the environment variable

#### 3. **Info.plist Uses the Build Setting**
**File:** [ios/Runner/Info.plist](ios/Runner/Info.plist#L26)

```xml
<key>GOOGLE_MAPS_API_KEY</key>
<string>$(INJECTED_GOOGLE_MAPS_API_KEY)</string>
```

- During the build, `$(INJECTED_GOOGLE_MAPS_API_KEY)` is replaced with the actual API key value
- This value is embedded in the app's Info.plist file

#### 4. **AppDelegate Reads at Runtime**
**File:** [ios/Runner/AppDelegate.swift](ios/Runner/AppDelegate.swift#L11-L12)

```swift
if let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String {
    GMSServices.provideAPIKey(key)
    // ... rest of initialization
}
```

- `Bundle.main` accesses the app's Info.plist
- `object(forInfoDictionaryKey:)` retrieves the `GOOGLE_MAPS_API_KEY` value
- `GMSServices.provideAPIKey(key)` initializes Google Maps with the API key

### iOS Summary
```
Shell Environment Variable
    ↓
xcconfig build setting ($(GOOGLE_MAPS_API_KEY))
    ↓
Info.plist ($(INJECTED_GOOGLE_MAPS_API_KEY))
    ↓
AppDelegate.swift (Bundle.main.object)
    ↓
GMSServices.provideAPIKey()
```

---

## Side-by-Side Comparison

| Aspect | Android | iOS |
|--------|---------|-----|
| **Timing** | Build-time (compile) | Runtime (app startup) |
| **Environment Variable** | `System.getenv("GOOGLE_MAPS_API_KEY")` | `$(GOOGLE_MAPS_API_KEY)` in xcconfig |
| **Configuration File** | AndroidManifest.xml | Info.plist |
| **Build Tool** | Gradle | Xcode |
| **Meta-data Key** | `com.google.android.geo.API_KEY` | `GOOGLE_MAPS_API_KEY` |
| **Initialization** | Google Maps SDK reads manifest | AppDelegate explicitly calls GMSServices.provideAPIKey() |
| **File Sources** | `android/app/build.gradle.kts` | `ios/Flutter/Debug.xcconfig`, `ios/Flutter/Release.xcconfig` |

---

## Why the Difference?

### Android Approach (Build-Time)
- **Advantage**: Simpler - API key is baked into the app at compile time
- **Advantage**: No special initialization code needed beyond plugin registration
- **Disadvantage**: Requires environment variable to be set when building

### iOS Approach (Runtime)
- **Advantage**: More flexible - API key can theoretically be changed without recompiling
- **Advantage**: Explicit control in AppDelegate code
- **Disadvantage**: Requires initialization code in AppDelegate
- **Disadvantage**: Slightly more complex setup with xcconfig files

---

## Setting Up Locally

### For Android

1. **Set the environment variable:**
   ```bash
   export GOOGLE_MAPS_API_KEY=your_api_key_here
   ```

2. **Build the app:**
   ```bash
   flutter run -d <device_id>
   ```

3. **Verify:** Check [android/app/build.gradle.kts](android/app/build.gradle.kts) to see the environment variable is properly defined

### For iOS

1. **Set the environment variable:**
   ```bash
   export GOOGLE_MAPS_API_KEY=your_api_key_here
   ```

2. **Run the app:**
   ```bash
   flutter run -d <device_id>
   ```

3. **Verify:** Check [ios/Flutter/Debug.xcconfig](ios/Flutter/Debug.xcconfig) and [ios/Runner/Info.plist](ios/Runner/Info.plist) have the API key configured

---

## Troubleshooting

### Android Issues

**Problem:** Maps show blank or "Maps not initialized" error
- **Solution:** Ensure `GOOGLE_MAPS_API_KEY` environment variable is set before building
- **Solution:** Run `flutter clean` and rebuild
- **Check:** Verify [android/app/build.gradle.kts](android/app/build.gradle.kts#L35-L36) has the API key injection logic

**Problem:** "Unknown error executing gradle task assembleDebug"
- **Solution:** API key environment variable may not be set
- **Check:** Run `echo $GOOGLE_MAPS_API_KEY` to verify it's set

### iOS Issues

**Problem:** Maps show blank or "GMSServices.provideAPIKey() must be called"
- **Solution:** Check [ios/Runner/AppDelegate.swift](ios/Runner/AppDelegate.swift#L11-L12) is calling GMSServices.provideAPIKey()
- **Solution:** Verify [ios/Runner/Info.plist](ios/Runner/Info.plist) has the GOOGLE_MAPS_API_KEY entry
- **Solution:** Run `flutter clean` and rebuild

**Problem:** Info.plist not getting the API key value
- **Solution:** Check environment variable is set before building
- **Solution:** Verify [ios/Flutter/Debug.xcconfig](ios/Flutter/Debug.xcconfig#L7) has the INJECTED_GOOGLE_MAPS_API_KEY line

---

## Additional Notes

### Permanent Environment Variable Setup

To avoid setting the environment variable every time you open a terminal:

1. **Edit your shell configuration:**
   ```bash
   nano ~/.zshrc
   ```

2. **Add the export line:**
   ```bash
   export GOOGLE_MAPS_API_KEY=your_api_key_here
   ```

3. **Save and reload:**
   ```bash
   source ~/.zshrc
   ```

### Security

⚠️ **Important**: Never commit the actual API key to version control:
- The `.env` file (if used) should be in `.gitignore`
- Only share `.env.sample` with team members as a template
- Rotate your API keys regularly
- Restrict API keys in Google Cloud Console to your app's package names and bundle IDs

---

## References

- [Google Maps Flutter Plugin Documentation](https://pub.dev/packages/google_maps_flutter)
- [Android Manifest Meta-data](https://developer.android.com/guide/topics/manifest/meta-data-element)
- [iOS Info.plist Format](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode/build-settings-reference)
