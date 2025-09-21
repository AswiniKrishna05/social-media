/// API Configuration and Authentication
class ApiConfig {
  // API Configuration
  static const String _baseUrl = 'https://your-api-endpoint.com/api/v1';
  
  // API Key (in production, store this securely)
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  
  // Alternative: Load from environment variables
  // static const String _apiKey = String.fromEnvironment('API_KEY');
  
  /// Get the base URL for API requests
  static String get baseUrl => _baseUrl;
  
  /// Get API key for authentication
  static String get apiKey => _apiKey;
  
  /// Get authentication headers
  static Map<String, String> get authHeaders => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Get headers for API requests
  static Map<String, String> getHeaders({
    Map<String, String>? additionalHeaders,
  }) {
    final headers = Map<String, String>.from(authHeaders);
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }
  
  /// Check if API key is configured
  static bool get isApiKeyConfigured => _apiKey != 'YOUR_API_KEY_HERE';
  
  /// Get API endpoints
  static const String postsEndpoint = '/posts';
  static const String usersEndpoint = '/users';
  static const String authEndpoint = '/auth';
  static const String uploadEndpoint = '/upload';
}
