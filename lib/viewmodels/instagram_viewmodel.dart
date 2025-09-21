import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/instagram_api_service.dart';
import '../services/hive_service.dart';

/// ViewModel for Instagram API integration
class InstagramViewModel extends ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _isApiAvailable = false;

  // Getters
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get isApiAvailable => _isApiAvailable;
  int get postsCount => _posts.length;

  /// Initialize Instagram posts
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // Check API availability
      _isApiAvailable = await InstagramApiService.isApiAvailable();
      
      if (_isApiAvailable) {
        // Fetch from Instagram API
        await _fetchFromInstagramApi();
      } else {
        // Fallback to mock Instagram data
        await _loadMockInstagramData();
      }
    } catch (e) {
      _setError('Failed to load Instagram posts: $e');
      // Try to load mock data as fallback
      await _loadMockInstagramData();
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh Instagram posts
  Future<void> refreshPosts() async {
    _setRefreshing(true);
    _clearError();

    try {
      if (_isApiAvailable) {
        await _fetchFromInstagramApi();
      } else {
        await _loadMockInstagramData();
      }
    } catch (e) {
      _setError('Failed to refresh Instagram posts: $e');
    } finally {
      _setRefreshing(false);
    }
  }

  /// Fetch posts from Instagram API
  Future<void> _fetchFromInstagramApi() async {
    try {
      _posts = await InstagramApiService.fetchRecentMedia();
      
      // Save to local storage for offline access
      await _saveToLocal();
      
      notifyListeners();
    } catch (e) {
      throw Exception('Instagram API fetch failed: $e');
    }
  }

  /// Load mock Instagram data
  Future<void> _loadMockInstagramData() async {
    try {
      _posts = InstagramApiService.getMockInstagramData();
      notifyListeners();
    } catch (e) {
      throw Exception('Mock data load failed: $e');
    }
  }

  /// Save posts to local storage
  Future<void> _saveToLocal() async {
    try {
      // Save posts to local storage
      for (final post in _posts) {
        await HiveService.savePost(post);
        if (post.user != null) {
          await HiveService.saveUser(post.user!);
        }
      }
    } catch (e) {
      // Log error but don't throw - local save failure shouldn't break the app
      debugPrint('Failed to save Instagram posts to local storage: $e');
    }
  }

  /// Toggle like for a post
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      // Find the post and toggle like
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final updatedPost = post.toggleLike(userId);
        _posts[index] = updatedPost;
        
        // Save to local storage
        await HiveService.savePost(updatedPost);
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to toggle like: $e');
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

  /// Check Instagram API status
  Future<Map<String, dynamic>> checkApiStatus() async {
    try {
      _isApiAvailable = await InstagramApiService.isApiAvailable();
      final status = await InstagramApiService.getApiStatus();
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
