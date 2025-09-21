import '../models/user.dart';
import '../models/post.dart';

/// Service for handling API calls to fetch posts and user data
class ApiService {
  // Mock API base URL (in a real app, this would be your actual API endpoint)
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  
  // Simulated API endpoints for our social media app
  static const String _postsEndpoint = '/posts';
  static const String _usersEndpoint = '/users';
  static const String _photosEndpoint = '/photos';

  /// Fetch posts from API
  static Future<List<Post>> fetchPosts() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would make actual HTTP requests:
      // final response = await http.get(Uri.parse('$_baseUrl$_postsEndpoint'));
      
      // For demonstration, we'll return mock API data
      return _getMockApiPosts();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  /// Fetch users from API
  static Future<List<User>> fetchUsers() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real app, you would make actual HTTP requests:
      // final response = await http.get(Uri.parse('$_baseUrl$_usersEndpoint'));
      
      // For demonstration, we'll return mock API data
      return _getMockApiUsers();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Create a new post via API
  static Future<Post> createPost({
    required String userId,
    required String caption,
    String? imageUrl,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would make a POST request:
      // final response = await http.post(
      //   Uri.parse('$_baseUrl$_postsEndpoint'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'userId': userId,
      //     'title': caption,
      //     'body': caption,
      //   }),
      // );

      // For demonstration, return a mock created post
      return Post.create(
        userId: userId,
        caption: caption,
        imageUrl: imageUrl,
      );
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  /// Like a post via API
  static Future<Post> likePost({
    required String postId,
    required String userId,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real app, you would make a PUT/PATCH request:
      // final response = await http.patch(
      //   Uri.parse('$_baseUrl$_postsEndpoint/$postId/like'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'userId': userId}),
      // );

      // For demonstration, return success
      throw UnimplementedError('Like functionality should be handled locally');
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  /// Delete a post via API
  static Future<void> deletePost(String postId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would make a DELETE request:
      // final response = await http.delete(
      //   Uri.parse('$_baseUrl$_postsEndpoint/$postId'),
      // );

      // For demonstration, return success
      return;
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  /// Mock API data - simulates what would come from a real API
  static List<Post> _getMockApiPosts() {
    final mockApiData = [
      {
        'id': 'api_post_1',
        'userId': 'api_user_1',
        'title': 'Amazing sunset from my evening walk! 🌅',
        'body': 'Amazing sunset from my evening walk! 🌅 The colors were absolutely breathtaking today. Nature never fails to amaze me with its beauty.',
        'likes': 42,
        'likedBy': ['api_user_2', 'api_user_3', 'api_user_4'],
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'api_post_2',
        'userId': 'api_user_2',
        'title': 'Just finished an incredible book! 📚',
        'body': 'Just finished an incredible book! 📚 "Atomic Habits" by James Clear. The insights about building good habits and breaking bad ones are game-changing. Highly recommend it to everyone!',
        'likes': 28,
        'likedBy': ['api_user_1', 'api_user_3'],
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'id': 'api_post_3',
        'userId': 'api_user_3',
        'title': 'Coffee and coding session ☕️💻',
        'body': 'Coffee and coding session ☕️💻 Working on some exciting new features for our app. The combination of caffeine and problem-solving is unbeatable!',
        'likes': 35,
        'likedBy': ['api_user_1', 'api_user_2', 'api_user_4', 'api_user_5'],
        'createdAt': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      },
      {
        'id': 'api_post_4',
        'userId': 'api_user_4',
        'title': 'Weekend adventure complete! 🏔️',
        'body': 'Weekend adventure complete! 🏔️ Hiked to the summit and the view was absolutely worth every step. Sometimes you need to disconnect from technology and reconnect with nature.',
        'likes': 51,
        'likedBy': ['api_user_1', 'api_user_2', 'api_user_3', 'api_user_5'],
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'api_post_5',
        'userId': 'api_user_5',
        'title': 'New recipe experiment! 🍳',
        'body': 'New recipe experiment! 🍳 Tried making homemade ramen from scratch today. The broth took 6 hours to prepare but the result was incredible. Cooking is such a therapeutic activity.',
        'likes': 33,
        'likedBy': ['api_user_1', 'api_user_3', 'api_user_4'],
        'createdAt': DateTime.now().subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
      },
      {
        'id': 'api_post_6',
        'userId': 'api_user_1',
        'title': 'Morning workout done! 💪',
        'body': 'Morning workout done! 💪 Starting the day with energy and positivity. What\'s your favorite way to stay active? I\'m always looking for new workout ideas!',
        'likes': 29,
        'likedBy': ['api_user_2', 'api_user_4', 'api_user_5'],
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'api_post_7',
        'userId': 'api_user_2',
        'title': 'Travel memories flooding back ✈️',
        'body': 'Travel memories flooding back ✈️ This photo brings back so many amazing memories from my trip to Japan last year. The culture, the food, the people - everything was perfect.',
        'likes': 47,
        'likedBy': ['api_user_1', 'api_user_3', 'api_user_4', 'api_user_5'],
        'createdAt': DateTime.now().subtract(const Duration(days: 2, hours: 5)).toIso8601String(),
      },
      {
        'id': 'api_post_8',
        'userId': 'api_user_3',
        'title': 'Learning never stops! 🎓',
        'body': 'Learning never stops! 🎓 Just completed an online course on machine learning. The future of AI is exciting and I want to be part of it. What are you learning these days?',
        'likes': 38,
        'likedBy': ['api_user_1', 'api_user_2', 'api_user_5'],
        'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
    ];

    final users = _getMockApiUsers();
    
    return mockApiData.map((data) {
      final user = users.firstWhere(
        (u) => u.id == data['userId'],
        orElse: () => users.first,
      );
      
      return Post(
        id: data['id'] as String,
        userId: data['userId'] as String,
        caption: data['body'] as String,
        imageUrl: null,
        likesCount: data['likes'] as int,
        likedBy: List<String>.from(data['likedBy'] as List),
        createdAt: DateTime.parse(data['createdAt'] as String),
        updatedAt: DateTime.parse(data['createdAt'] as String),
        user: user,
      );
    }).toList();
  }

  /// Mock API users data
  static List<User> _getMockApiUsers() {
    return [
      User(
        id: 'api_user_1',
        username: 'alex_chen',
        email: 'alex@api.com',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: 'api_user_2',
        username: 'sarah_wilson',
        email: 'sarah@api.com',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      User(
        id: 'api_user_3',
        username: 'mike_rodriguez',
        email: 'mike@api.com',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      User(
        id: 'api_user_4',
        username: 'emma_taylor',
        email: 'emma@api.com',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      User(
        id: 'api_user_5',
        username: 'david_kim',
        email: 'david@api.com',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  /// Check if API is available (simulate network check)
  static Future<bool> isApiAvailable() async {
    try {
      // Simulate network check
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app, you would ping your API:
      // final response = await http.get(Uri.parse('$_baseUrl/health'));
      // return response.statusCode == 200;
      
      // For demonstration, always return true
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get API status information
  static Future<Map<String, dynamic>> getApiStatus() async {
    try {
      final isAvailable = await isApiAvailable();
      return {
        'status': isAvailable ? 'online' : 'offline',
        'baseUrl': _baseUrl,
        'lastChecked': DateTime.now().toIso8601String(),
        'endpoints': {
          'posts': '$_baseUrl$_postsEndpoint',
          'users': '$_baseUrl$_usersEndpoint',
          'photos': '$_baseUrl$_photosEndpoint',
        },
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'lastChecked': DateTime.now().toIso8601String(),
      };
    }
  }
}
