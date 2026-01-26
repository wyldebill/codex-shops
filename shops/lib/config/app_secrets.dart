import 'package:flutter/foundation.dart';

/// Secure configuration for API keys and sensitive data
///
/// This class handles loading and accessing sensitive configuration from
/// environment files that are NOT committed to version control.
class AppSecrets {
  static late final String _googleMapsApiKey;

  /// Initialize secrets from compile-time environment variables
  /// Must be called in main() before accessing any secrets
  static Future<void> init() async {
    try {
      _googleMapsApiKey = const String.fromEnvironment('GOOGLE_MAPS_API_KEY');

      if (_googleMapsApiKey.isEmpty) {
        if (kDebugMode) {
          print('WARNING: GOOGLE_MAPS_API_KEY not defined.');
        }
      }
    } catch (e) {
      _googleMapsApiKey = '';
      if (kDebugMode) {
        print('Error loading environment configuration: $e');
      }
    }
  }

  /// Get Google Maps API Key
  /// Returns empty string if not configured (for development)
  static String get googleMapsApiKey => _googleMapsApiKey;

  /// Check if API key is configured
  static bool get hasApiKey => _googleMapsApiKey.isNotEmpty;
}
