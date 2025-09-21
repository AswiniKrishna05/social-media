import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/post.dart';
import 'instagram_config.dart';

/// Instagram API service using Mockoon mock data
class InstagramApiService {
  // Mockoon Instagram API endpoint
  static const String _baseUrl = 'http://localhost:3000/v1';
  
  /// Fetch recent media from Instagram API
  static Future<List<Post>> fetchRecentMedia() async {
    try {
      // Check if API is available based on current configuration
      final isAvailable = await isApiAvailable();
      
      if (!isAvailable) {
        // Use mock data if API is not available
        return getMockInstagramData();
      }
      
      // Use the configured base URL
      final baseUrl = InstagramConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/geographies/1/media/recent'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> mediaList = data['data'] ?? [];
        
        return mediaList.map((media) => _convertInstagramMediaToPost(media)).toList();
      } else {
        throw Exception('Failed to fetch media: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API is not available
      return getMockInstagramData();
    }
  }

  /// Fetch user's media
  static Future<List<Post>> fetchUserMedia(String userId) async {
    try {
      // Check if API is available based on current configuration
      final isAvailable = await isApiAvailable();
      
      if (!isAvailable) {
        // Use mock data if API is not available
        return getMockInstagramData();
      }
      
      // Use the configured base URL
      final baseUrl = InstagramConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/media/recent'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> mediaList = data['data'] ?? [];
        
        return mediaList.map((media) => _convertInstagramMediaToPost(media)).toList();
      } else {
        throw Exception('Failed to fetch user media: ${response.statusCode}');
      }
    } catch (e) {
      return getMockInstagramData();
    }
  }

  /// Convert Instagram API media object to our Post model
  static Post _convertInstagramMediaToPost(Map<String, dynamic> media) {
    final caption = media['caption'] as Map<String, dynamic>?;
    final user = media['user'] as Map<String, dynamic>?;
    final likes = media['likes'] as Map<String, dynamic>?;
    final images = media['images'] as Map<String, dynamic>?;
    
    // Get the best quality image URL
    String? imageUrl;
    if (images != null) {
      // Try standard resolution first, then low resolution, then thumbnail
      final standardRes = images['standard_resolution'] as Map<String, dynamic>?;
      final lowRes = images['low_resolution'] as Map<String, dynamic>?;
      final thumbnail = images['thumbnail'] as Map<String, dynamic>?;
      
      imageUrl = standardRes?['url'] ?? lowRes?['url'] ?? thumbnail?['url'];
    }

    // Create user object
    User? userObj;
    if (user != null) {
      userObj = User(
        id: user['id']?.toString() ?? '',
        username: user['username'] ?? 'unknown_user',
        email: '${user['username']}@instagram.com',
        profileImageUrl: user['profile_picture'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
    }

    // Get like count and liked users
    int likesCount = 0;
    List<String> likedBy = [];
    if (likes != null) {
      likesCount = likes['count'] ?? 0;
      final likesData = likes['data'] as List<dynamic>?;
      if (likesData != null) {
        likedBy = likesData.map((like) => like['id']?.toString() ?? '').toList();
      }
    }

    return Post(
      id: media['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user?['id']?.toString() ?? '',
      caption: caption?['text'] ?? '',
      imageUrl: imageUrl,
      likesCount: likesCount,
      likedBy: likedBy,
      createdAt: DateTime.tryParse(media['created_time'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(media['created_time'] ?? '') ?? DateTime.now(),
      user: userObj,
    );
  }

  /// Mock Instagram data when API is not available
  static List<Post> getMockInstagramData() {
    final mockUsers = [
      User(
        id: 'ig_user_1',
        username: 'nature_lover',
        email: 'nature@instagram.com',
        profileImageUrl: 'https://picsum.photos/100/100?random=1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: 'ig_user_2',
        username: 'foodie_adventures',
        email: 'foodie@instagram.com',
        profileImageUrl: 'https://picsum.photos/100/100?random=2',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      User(
        id: 'ig_user_3',
        username: 'travel_diaries',
        email: 'travel@instagram.com',
        profileImageUrl: 'https://picsum.photos/100/100?random=3',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      User(
        id: 'ig_user_4',
        username: 'art_enthusiast',
        email: 'art@instagram.com',
        profileImageUrl: 'https://picsum.photos/100/100?random=4',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      User(
        id: 'ig_user_5',
        username: 'fitness_motivation',
        email: 'fitness@instagram.com',
        profileImageUrl: 'https://picsum.photos/100/100?random=5',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    final mockPosts = [
      {
        'id': 'ig_post_1',
        'userId': 'ig_user_1',
        'caption': 'Beautiful sunset from my evening hike! 🌅 Nature never fails to amaze me with its colors.',
        'imageUrl': 'https://picsum.photos/400/400?random=1',
        'likesCount': 1247,
        'likedBy': ['ig_user_2', 'ig_user_3'],
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'ig_post_2',
        'userId': 'ig_user_2',
        'caption': 'Homemade pasta night! 🍝 Nothing beats fresh ingredients and love in cooking.',
        'imageUrl': 'https://picsum.photos/400/400?random=2',
        'likesCount': 892,
        'likedBy': ['ig_user_1', 'ig_user_4'],
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        'id': 'ig_post_3',
        'userId': 'ig_user_3',
        'caption': 'Lost in the streets of Tokyo! 🏙️ Every corner tells a different story.',
        'imageUrl': 'https://picsum.photos/400/400?random=3',
        'likesCount': 2156,
        'likedBy': ['ig_user_1', 'ig_user_2', 'ig_user_5'],
        'createdAt': DateTime.now().subtract(const Duration(hours: 8)),
      },
      {
        'id': 'ig_post_4',
        'userId': 'ig_user_4',
        'caption': 'Morning coffee and creativity ☕️ Sometimes the best ideas come with the first sip.',
        'imageUrl': 'https://picsum.photos/400/400?random=4',
        'likesCount': 634,
        'likedBy': ['ig_user_3'],
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': 'ig_post_5',
        'userId': 'ig_user_5',
        'caption': 'Gym session complete! 💪 Consistency is the key to progress. What\'s your favorite workout?',
        'imageUrl': 'https://picsum.photos/400/400?random=5',
        'likesCount': 1789,
        'likedBy': ['ig_user_1', 'ig_user_2', 'ig_user_4'],
        'createdAt': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      },
      {
        'id': 'ig_post_6',
        'userId': 'ig_user_1',
        'caption': 'Mountain peak achieved! 🏔️ The view from up here makes every step worth it.',
        'imageUrl': 'https://picsum.photos/400/400?random=6',
        'likesCount': 3421,
        'likedBy': ['ig_user_2', 'ig_user_3', 'ig_user_4', 'ig_user_5'],
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': 'ig_post_7',
        'userId': 'ig_user_2',
        'caption': 'Dessert heaven! 🍰 Sometimes you need to treat yourself to something sweet.',
        'imageUrl': 'https://picsum.photos/400/400?random=7',
        'likesCount': 1567,
        'likedBy': ['ig_user_1', 'ig_user_3', 'ig_user_5'],
        'createdAt': DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      },
      {
        'id': 'ig_post_8',
        'userId': 'ig_user_3',
        'caption': 'Golden hour magic ✨ There\'s something special about this time of day.',
        'imageUrl': 'https://picsum.photos/400/400?random=8',
        'likesCount': 2890,
        'likedBy': ['ig_user_1', 'ig_user_2', 'ig_user_4', 'ig_user_5'],
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    return mockPosts.map((postData) {
      final user = mockUsers.firstWhere((u) => u.id == postData['userId']);
      return Post(
        id: postData['id'] as String,
        userId: postData['userId'] as String,
        caption: postData['caption'] as String,
        imageUrl: postData['imageUrl'] as String,
        likesCount: postData['likesCount'] as int,
        likedBy: List<String>.from(postData['likedBy'] as List),
        createdAt: postData['createdAt'] as DateTime,
        updatedAt: postData['createdAt'] as DateTime,
        user: user,
      );
    }).toList();
  }

  /// Check if Instagram API is available
  static Future<bool> isApiAvailable() async {
    return await InstagramConfig.isApiAvailable();
  }

  /// Get API status information
  static Future<Map<String, dynamic>> getApiStatus() async {
    try {
      return await InstagramConfig.getApiStatus();
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'lastChecked': DateTime.now().toIso8601String(),
      };
    }
  }
}
