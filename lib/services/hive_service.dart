import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/post.dart';

/// Service class for managing Hive database operations
class HiveService {
  static const String _usersBoxName = 'users';
  static const String _postsBoxName = 'posts';
  static const String _authBoxName = 'auth';

  static Box<User>? _usersBox;
  static Box<Post>? _postsBox;
  static Box<String>? _authBox;

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(PostAdapter());

    // Get application documents directory
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);

    // Open boxes
    _usersBox = await Hive.openBox<User>(_usersBoxName);
    _postsBox = await Hive.openBox<Post>(_postsBoxName);
    _authBox = await Hive.openBox<String>(_authBoxName);
  }

  /// Get users box
  static Box<User> get usersBox {
    if (_usersBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return _usersBox!;
  }

  /// Get posts box
  static Box<Post> get postsBox {
    if (_postsBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return _postsBox!;
  }

  /// Get auth box
  static Box<String> get authBox {
    if (_authBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return _authBox!;
  }

  /// Save user to local storage
  static Future<void> saveUser(User user) async {
    await usersBox.put(user.id, user);
  }

  /// Get user by ID
  static User? getUser(String userId) {
    return usersBox.get(userId);
  }

  /// Get all users
  static List<User> getAllUsers() {
    return usersBox.values.toList();
  }

  /// Save post to local storage
  static Future<void> savePost(Post post) async {
    await postsBox.put(post.id, post);
  }

  /// Get post by ID
  static Post? getPost(String postId) {
    return postsBox.get(postId);
  }

  /// Get all posts sorted by creation date (newest first)
  static List<Post> getAllPosts() {
    final posts = postsBox.values.toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  /// Get posts by user ID
  static List<Post> getPostsByUser(String userId) {
    final posts = postsBox.values.where((post) => post.userId == userId).toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  /// Delete post
  static Future<void> deletePost(String postId) async {
    await postsBox.delete(postId);
  }

  /// Save current user session
  static Future<void> saveCurrentUser(String userId) async {
    await authBox.put('current_user_id', userId);
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return authBox.get('current_user_id');
  }

  /// Get current user
  static User? getCurrentUser() {
    final userId = getCurrentUserId();
    if (userId != null) {
      return getUser(userId);
    }
    return null;
  }

  /// Clear current user session
  static Future<void> clearCurrentUser() async {
    await authBox.delete('current_user_id');
  }

  /// Check if user is logged in
  static bool isUserLoggedIn() {
    return getCurrentUserId() != null;
  }

  /// Clear all data (for testing or logout)
  static Future<void> clearAllData() async {
    await usersBox.clear();
    await postsBox.clear();
    await authBox.clear();
  }

  /// Close all boxes
  static Future<void> close() async {
    await _usersBox?.close();
    await _postsBox?.close();
    await _authBox?.close();
  }
}
