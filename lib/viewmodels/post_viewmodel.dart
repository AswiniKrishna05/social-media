import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/post_service.dart';

/// ViewModel for handling post operations and state
class PostViewModel extends ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get postsCount => _posts.length;

  /// Initialize posts from local storage
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      _posts = PostService.getAllPostsWithUsers();
    } catch (e) {
      _setError('Failed to load posts: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh posts from local storage
  Future<void> refreshPosts() async {
    await initialize();
  }

  /// Create a new post
  Future<bool> createPost({
    required String userId,
    required String caption,
    String? imagePath,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate caption
      if (!PostService.isValidCaption(caption)) {
        _setError('Caption must be between 1 and 500 characters');
        return false;
      }

      // Create post
      final newPost = await PostService.createPost(
        userId: userId,
        caption: caption,
        imagePath: imagePath,
      );

      // Add to posts list
      _posts.insert(0, newPost);
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
      final updatedPost = await PostService.toggleLike(
        postId: postId,
        userId: userId,
      );

      // Update post in the list
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to toggle like: $e');
    }
  }

  /// Delete a post
  Future<bool> deletePost(String postId) async {
    _setLoading(true);
    _clearError();

    try {
      await PostService.deletePost(postId);
      
      // Remove from posts list
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

  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      return await PostService.pickImageFromGallery();
    } catch (e) {
      _setError('Failed to pick image: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      return await PostService.pickImageFromCamera();
    } catch (e) {
      _setError('Failed to capture image: $e');
      return null;
    }
  }

  /// Get image file from path
  dynamic getImageFile(String? imagePath) {
    return PostService.getImageFile(imagePath);
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
