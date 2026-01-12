#!/bin/bash

# This script reads GOOGLE_MAPS_API_KEY from a local .env file and injects
# it into the iOS Runner Info.plist and (if needed) prepares AppDelegate
# initialization for the Google Maps SDK. It previously targeted Android;
# it's been adapted to iOS projects.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
IOS_INFO_PLIST="$ROOT_DIR/ios/Runner/Info.plist"
APP_DELEGATE_SWIFT="$ROOT_DIR/ios/Runner/AppDelegate.swift"

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: .env file not found at $ENV_FILE"
    exit 1
fi

# load GOOGLE_MAPS_API_KEY from .env
export $(grep -E '^GOOGLE_MAPS_API_KEY=' "$ENV_FILE" || true)

if [ -z "${GOOGLE_MAPS_API_KEY-}" ]; then
    echo "No GOOGLE_MAPS_API_KEY found in $ENV_FILE; nothing to inject."
    exit 0
fi

echo "Injecting Google Maps API key into iOS project..."

if [ -f "$IOS_INFO_PLIST" ]; then
    # Use PlistBuddy to add or set the key in Info.plist
    if /usr/libexec/PlistBuddy -c "Print :GOOGLE_MAPS_API_KEY" "$IOS_INFO_PLIST" >/dev/null 2>&1; then
        /usr/libexec/PlistBuddy -c "Set :GOOGLE_MAPS_API_KEY $GOOGLE_MAPS_API_KEY" "$IOS_INFO_PLIST"
        echo "Updated GOOGLE_MAPS_API_KEY in $IOS_INFO_PLIST"
    else
        /usr/libexec/PlistBuddy -c "Add :GOOGLE_MAPS_API_KEY string $GOOGLE_MAPS_API_KEY" "$IOS_INFO_PLIST"
        echo "Added GOOGLE_MAPS_API_KEY to $IOS_INFO_PLIST"
    fi
else
    echo "Warning: $IOS_INFO_PLIST not found; skipping Info.plist injection."
fi

# Ensure AppDelegate initializes GMSServices if present
if [ -f "$APP_DELEGATE_SWIFT" ]; then
    if ! grep -q "GMSServices.provideAPIKey" "$APP_DELEGATE_SWIFT" >/dev/null 2>&1; then
        echo "Patching AppDelegate to initialize GMSServices..."
        # Insert import GoogleMaps at top if not present
        if ! grep -q "import GoogleMaps" "$APP_DELEGATE_SWIFT" >/dev/null 2>&1; then
            awk 'NR==1{print; next} {print}' "$APP_DELEGATE_SWIFT" > "$APP_DELEGATE_SWIFT.tmp" && \
                sed -i '' '1s|^|import GoogleMaps\n|' "$APP_DELEGATE_SWIFT.tmp" && \
                mv "$APP_DELEGATE_SWIFT.tmp" "$APP_DELEGATE_SWIFT"
        fi

        # Add initialization before GeneratedPluginRegistrant.register(with: self)
        awk '
        {print}
        /GeneratedPluginRegistrant.register\(with: self\)/ && !x {
            print "    if let key = Bundle.main.object(forInfoDictionaryKey: \"GOOGLE_MAPS_API_KEY\") as? String {"
            print "      GMSServices.provideAPIKey(key)"
            print "    }"
            x=1
        }
        ' "$APP_DELEGATE_SWIFT" > "$APP_DELEGATE_SWIFT.tmp" && mv "$APP_DELEGATE_SWIFT.tmp" "$APP_DELEGATE_SWIFT"

        echo "AppDelegate patched to call GMSServices.provideAPIKey(...)"
    else
        echo "AppDelegate already initializes GMSServices; skipping patch."
    fi
else
    echo "Warning: $APP_DELEGATE_SWIFT not found; cannot patch AppDelegate."
fi

echo "Injection complete."
