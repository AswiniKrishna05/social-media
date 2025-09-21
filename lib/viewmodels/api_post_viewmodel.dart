import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';

/// ViewModel for handling API-based post operations
class ApiPostViewModel extends ChangeNotifier {
  List<Post> _posts = [];
  List<User> _users = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _isApiAvailable = false;

  // Getters
  List<Post> get posts => _posts;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get isApiAvailable => _isApiAvailable;
  int get postsCount => _posts.length;

  /// Initialize posts from API
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // Check API availability
      _isApiAvailable = await ApiService.isApiAvailable();
      
      if (_isApiAvailable) {
        // Fetch from API
        await _fetchFromApi();
      } else {
        // Fallback to local data
        await _loadFromLocal();
      }
    } catch (e) {
      _setError('Failed to load posts: $e');
      // Try to load from local storage as fallback
      await _loadFromLocal();
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh posts from API
  Future<void> refreshPosts() async {
    _setRefreshing(true);
    _clearError();

    try {
      if (_isApiAvailable) {
        await _fetchFromApi();
      } else {
        await _loadFromLocal();
      }
    } catch (e) {
      _setError('Failed to refresh posts: $e');
    } finally {
      _setRefreshing(false);
    }
  }

  /// Fetch posts and users from API
  Future<void> _fetchFromApi() async {
    try {
      // Fetch users and posts in parallel
      final futures = await Future.wait([
        ApiService.fetchUsers(),
        ApiService.fetchPosts(),
      ]);

      _users = futures[0] as List<User>;
      _posts = futures[1] as List<Post>;

      // Save to local storage for offline access
      await _saveToLocal();
      
      notifyListeners();
    } catch (e) {
      throw Exception('API fetch failed: $e');
    }
  }

  /// Load posts from local storage
  Future<void> _loadFromLocal() async {
    try {
      _posts = []; // remove any local posts
      _users = [];
      notifyListeners();
    } catch (e) {
      throw Exception('Local load failed: $e');
    }
  }


  /// Save posts to local storage
  Future<void> _saveToLocal() async {
    try {
      // Save users
      for (final user in _users) {
        await HiveService.saveUser(user);
      }
      
      // Save posts
      for (final post in _posts) {
        await HiveService.savePost(post);
      }
    } catch (e) {
      // Log error but don't throw - local save failure shouldn't break the app
      debugPrint('Failed to save to local storage: $e');
    }
  }

  /// Create a new post via API
  Future<bool> createPost({
    required String userId,
    required String caption,
    String? imagePath,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isApiAvailable) {
        // Create via API
        final newPost = await ApiService.createPost(
          userId: userId,
          caption: caption,
          imageUrl: imagePath,
        );

        // Add to local list
        _posts.insert(0, newPost);
        
        // Save to local storage
        await HiveService.savePost(newPost);
      } else {
        // Create locally when API is unavailable
        final newPost = Post.create(
          userId: userId,
          caption: caption,
          imageUrl: imagePath,
        );

        _posts.insert(0, newPost);
        await HiveService.savePost(newPost);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create post: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle like for a post
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      if (_isApiAvailable) {
        // In a real app, you would call the API here
        // await ApiService.likePost(postId: postId, userId: userId);
        
        // For now, handle locally
        final updatedPost = await _toggleLikeLocally(postId, userId);
        
        // Update in the list
        final index = _posts.indexWhere((post) => post.id == postId);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
      } else {
        // Handle locally when API is unavailable
        final updatedPost = await _toggleLikeLocally(postId, userId);
        
        final index = _posts.indexWhere((post) => post.id == postId);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
      }
    } catch (e) {
      _setError('Failed to toggle like: $e');
    }
  }

  /// Toggle like locally
  Future<Post> _toggleLikeLocally(String postId, String userId) async {
    final post = HiveService.getPost(postId);
    if (post == null) {
      throw Exception('Post not found');
    }

    final updatedPost = post.toggleLike(userId);
    await HiveService.savePost(updatedPost);
    return updatedPost;
  }

  /// Delete a post via API
  Future<bool> deletePost(String postId) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isApiAvailable) {
        await ApiService.deletePost(postId);
      }
      
      // Remove from local storage and list
      await HiveService.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete post: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get posts by user ID
  List<Post> getPostsByUser(String userId) {
    return _posts.where((post) => post.userId == userId).toList();
  }

  /// Get post by ID
  Post? getPostById(String postId) {
    try {
      return _posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }

  /// Check API status
  Future<Map<String, dynamic>> checkApiStatus() async {
    try {
      _isApiAvailable = await ApiService.isApiAvailable();
      final status = await ApiService.getApiStatus();
      return status;
    } catch (e) {
      _isApiAvailable = false;
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set refreshing state
  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
