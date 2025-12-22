#!/bin/bash

# iOS Build Phase Script to inject Google Maps API Key
# This script runs during Xcode build and injects the API key from .env into Info.plist

PLIST_FILE="$SRCROOT/Runner/Info.plist"
ENV_FILE="$SRCROOT/../.env"

# Check if .env file exists
if [ -f "$ENV_FILE" ]; then
    # Extract API key from .env
    GOOGLE_MAPS_API_KEY=$(grep "^GOOGLE_MAPS_API_KEY=" "$ENV_FILE" | cut -d '=' -f 2)
    
    if [ -n "$GOOGLE_MAPS_API_KEY" ]; then
        # Use plutil to set the API key in Info.plist
        /usr/libexec/PlistBuddy -c "Add :GCM_API_KEY string" "$PLIST_FILE" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Set :GCM_API_KEY $GOOGLE_MAPS_API_KEY" "$PLIST_FILE"
        
        echo "Google Maps API key injected into Info.plist"
    else
        echo "ERROR: GOOGLE_MAPS_API_KEY not found in .env file"
        exit 1
    fi
else
    echo "ERROR: .env file not found at $ENV_FILE"
    exit 1
fi
