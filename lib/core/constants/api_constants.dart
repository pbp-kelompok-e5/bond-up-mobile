/// API Configuration Constants
/// 
/// This file contains all API-related constants including base URLs.
/// To switch between development and production, change the [baseUrl] value.
class ApiConstants {
  ApiConstants._();

  /// Base URL for API requests
  /// 
  /// **Development Options:**
  /// - For web/Chrome: 'http://localhost:8000'
  /// - For Android emulator: 'http://10.0.2.2:8000'
  /// - For iOS simulator: 'http://localhost:8000'
  /// 
  /// **Production:**
  /// - 'https://farrell-bagoes-sigmaapp.pbp.cs.ui.ac.id'
  /// 
  /// Change this value to switch between environments.
  // static const String baseUrl = 'https://farrell-bagoes-sigmaapp.pbp.cs.ui.ac.id';
  static const String baseUrl = 'http://localhost:8000';
}

