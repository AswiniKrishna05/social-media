import 'package:http/http.dart' as http;

class InstagramConfig {
  // API Mode Configuration
  static const InstagramApiMode _apiMode = InstagramApiMode.mockData;
  
  // API Endpoints
  static const String _mockoonUrl = 'http://localhost:3000/v1';
  static const String _jsonPlaceholderUrl = 'https://jsonplaceholder.typicode.com';
  static const String _reqResUrl = 'https://reqres.in/api';
  static const String _realInstagramUrl = 'https://graph.instagram.com/v18.0';
  
  /// Get the current API mode
  static InstagramApiMode get apiMode => _apiMode;
  
  /// Get the base URL for the current API mode
  static String get baseUrl {
    switch (_apiMode) {
      case InstagramApiMode.mockoon:
        return _mockoonUrl;
      case InstagramApiMode.jsonPlaceholder:
        return _jsonPlaceholderUrl;
      case InstagramApiMode.reqRes:
        return _reqResUrl;
      case InstagramApiMode.realInstagram:
        return _realInstagramUrl;
      case InstagramApiMode.mockData:
      default:
        return ''; // No URL needed for mock data
    }
  }
  
  /// Check if API is available based on current mode
  static Future<bool> isApiAvailable() async {
    switch (_apiMode) {
      case InstagramApiMode.mockData:
        return false; // Always use mock data
      case InstagramApiMode.mockoon:
        return await _checkMockoonServer();
      case InstagramApiMode.jsonPlaceholder:
        return await _checkJsonPlaceholder();
      case InstagramApiMode.reqRes:
        return await _checkReqRes();
      case InstagramApiMode.realInstagram:
        return await _checkRealInstagram();
    }
  }
  
  /// Get API status information
  static Future<Map<String, dynamic>> getApiStatus() async {
    final isAvailable = await isApiAvailable();
    return {
      'mode': _apiMode.name,
      'status': isAvailable ? 'online' : 'offline',
      'baseUrl': baseUrl,
      'lastChecked': DateTime.now().toIso8601String(),
      'description': _getModeDescription(),
    };
  }
  
  /// Get description for current mode
  static String _getModeDescription() {
    switch (_apiMode) {
      case InstagramApiMode.mockData:
        return 'Using built-in mock data (no server required)';
      case InstagramApiMode.mockoon:
        return 'Mockoon mock server (requires local server on port 3000)';
      case InstagramApiMode.jsonPlaceholder:
        return 'JSONPlaceholder public API (free, no auth required)';
      case InstagramApiMode.reqRes:
        return 'ReqRes public API (free, no auth required)';
      case InstagramApiMode.realInstagram:
        return 'Real Instagram Graph API (requires authentication)';
    }
  }
  
  /// Check Mockoon server availability
  static Future<bool> _checkMockoonServer() async {
    try {
      final response = await http.get(
        Uri.parse('$_mockoonUrl/geographies/1/media/recent'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Check JSONPlaceholder availability
  static Future<bool> _checkJsonPlaceholder() async {
    try {
      final response = await http.get(
        Uri.parse('$_jsonPlaceholderUrl/posts'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Check ReqRes availability
  static Future<bool> _checkReqRes() async {
    try {
      final response = await http.get(
        Uri.parse('$_reqResUrl/users'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Check Real Instagram API availability
  static Future<bool> _checkRealInstagram() async {
    // This would require proper authentication
    // For now, return false as it needs API keys
    return false;
  }
}

/// Available API modes
enum InstagramApiMode {
  mockData,        // Use built-in mock data (default)
  mockoon,         // Local Mockoon server
  jsonPlaceholder, // JSONPlaceholder public API
  reqRes,          // ReqRes public API
  realInstagram,   // Real Instagram Graph API
}
