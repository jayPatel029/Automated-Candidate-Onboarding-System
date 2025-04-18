class Config {
  // Set this to true for local development, false for production
  static const bool isLocal = false;

  // Base URLs
  static const String localBaseUrl = 'http://127.0.0.1:5000';
  static const String productionBaseUrl = 'https://formparser-backend.onrender.com';

  // Get the current base URL based on environment
  static String get baseUrl => isLocal ? localBaseUrl : productionBaseUrl;

  // API Endpoints
  static String get processEndpoint => '$baseUrl/process';
  static String get healthEndpoint => '$baseUrl/health';
  static String get checkRenderEndpoint => '$baseUrl/checkrender';
  static String get fetchAllDataEndpoint => '$baseUrl/fetch_all_data';
} 