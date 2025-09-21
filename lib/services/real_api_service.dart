import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/post.dart';
import 'api_config.dart';

/// Real API service with authentication
class RealApiService {
  /// Fetch posts from real API
  static Future<List<Post>> fetchPosts() async {
    try {
      if (!ApiConfig.isApiKeyConfigured) {
        throw Exception('API key not configured. Please set your API key in ApiConfig.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}'),
        headers: ApiConfig.authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _postFromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  /// Fetch users from real API
  static Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}'),
        headers: ApiConfig.authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _userFromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  /// Create a new post via real API
  static Future<Post> createPost({
    required String userId,
    required String caption,
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}'),
        headers: ApiConfig.authHeaders,
        body: jsonEncode({
          'userId': userId,
          'caption': caption,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return _postFromJson(data);
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  /// Like a post via real API
  static Future<Post> likePost({
    required String postId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}/$postId/like'),
        headers: ApiConfig.authHeaders,
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _postFromJson(data);
      } else {
        throw Exception('Failed to like post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  /// Delete a post via real API
  static Future<void> deletePost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}/$postId'),
        headers: ApiConfig.authHeaders,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  /// Authenticate user and get API token
  static Future<String> authenticate({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authEndpoint}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] ?? data['access_token'];
      } else {
        throw Exception('Authentication failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Authentication request failed: $e');
    }
  }

  /// Upload image to API
  static Future<String> uploadImage(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadEndpoint}'),
      );

      // Add API key to headers
      request.headers.addAll(ApiConfig.authHeaders);

      // Add image file
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        return data['imageUrl'] ?? data['url'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  /// Check API health
  static Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
        headers: ApiConfig.authHeaders,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Convert JSON to Post object
  static Post _postFromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      caption: json['caption'] ?? json['body'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? json['liked_by'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
    );
  }

  /// Convert JSON to User object
  static User _userFromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    );
  }
}
