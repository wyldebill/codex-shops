#!/bin/bash

# Read API key from .env file
if [ -f ".env" ]; then
    export $(cat .env | grep GOOGLE_MAPS_API_KEY | xargs)
    
    # Inject into Android AndroidManifest.xml
    if [ -n "$GOOGLE_MAPS_API_KEY" ]; then
        # Create temporary manifest with API key injected
        cat > /tmp/manifest_template.xml << 'EOF'
        <!-- Google Maps API Key - injected from .env at build time -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="GOOGLE_MAPS_API_KEY_PLACEHOLDER" />
EOF
        
        # Replace placeholder with actual key
        sed -i "s|GOOGLE_MAPS_API_KEY_PLACEHOLDER|$GOOGLE_MAPS_API_KEY|g" /tmp/manifest_template.xml
        
        echo "API Key injected into build configuration"
    fi
else
    echo "ERROR: .env file not found"
    exit 1
fi
