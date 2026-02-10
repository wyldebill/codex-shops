plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load API key from environment variable first, then fall back to .env file
val slpyApiKey: String by lazy {
    // First, try to get from environment variable (for CI/CD builds like Codemagic)
    val envVarKey = System.getenv("SLPY_API_KEY")
    if (!envVarKey.isNullOrBlank()) {
        envVarKey
    } else {
        // Fall back to reading from .env file (for local development)
        val envFile = file("../../.env")
        if (envFile.exists()) {
            val lines = envFile.readLines()
            val apiKeyLine = lines.find { it.startsWith("SLPY_API_KEY=") }
            apiKeyLine?.substringAfter("=")?.trim() ?: ""
        } else {
            ""
        }
    }
}

android {
    namespace = "com.example.shops"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.shops"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Note: Slpy API key loaded above for potential future use
        // MapLibre GL uses the API key differently than Google Maps
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
