import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Secure configuration for API keys and sensitive data
///
/// This class handles loading and accessing sensitive configuration from
/// environment files that are NOT committed to version control.
class AppSecrets {
  static late final String _googleMapsApiKey;

  /// Initialize secrets from .env file
  /// Must be called in main() before accessing any secrets
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      _googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

      if (_googleMapsApiKey.isEmpty) {
        if (kDebugMode) {
          print('WARNING: GOOGLE_MAPS_API_KEY not found in .env file');
          print('Please copy .env.sample to .env and add your API key');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading .env file: $e');
      }
    }
  }

  /// Get Google Maps API Key
  /// Returns empty string if not configured (for development)
  static String get googleMapsApiKey => _googleMapsApiKey;

  /// Check if API key is configured
  static bool get hasApiKey => _googleMapsApiKey.isNotEmpty;
}
