import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../models/post.dart';
import '../models/user.dart';
import '../services/hive_service.dart';

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
      _posts = await HiveService.getAllPosts();
      // If no posts exist, create some sample posts
      if (_posts.isEmpty) {
        await _createSamplePosts();
        _posts = await HiveService.getAllPosts();
      }
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
      if (!_isValidCaption(caption)) {
        _setError('Caption must be between 1 and 500 characters');
        return false;
      }

      // Create post
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        caption: caption,
        imageUrl: imagePath,
        likesCount: 0,
        likedBy: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      await HiveService.savePost(newPost);

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

  /// Delete a post
  Future<bool> deletePost(String postId) async {
    _setLoading(true);
    _clearError();

    try {
      // Remove from local storage
      await HiveService.deletePost(postId);
      
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
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        return await _saveImageToLocal(image);
      }
      return null;
    } catch (e) {
      _setError('Failed to pick image: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        return await _saveImageToLocal(image);
      }
      return null;
    } catch (e) {
      _setError('Failed to capture image: $e');
      return null;
    }
  }

  /// Get image file from path
  File? getImageFile(String? imagePath) {
    if (imagePath != null) {
      return File(imagePath);
    }
    return null;
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

  /// Validate caption
  bool _isValidCaption(String caption) {
    return caption.trim().isNotEmpty && caption.length <= 500;
  }

  /// Save image to local storage
  Future<String> _saveImageToLocal(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
    final filePath = path.join(directory.path, 'images', fileName);
    
    // Create images directory if it doesn't exist
    final imagesDir = Directory(path.dirname(filePath));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    // Copy image to local storage
    await File(image.path).copy(filePath);
    return filePath;
  }

  /// Create sample posts for demonstration
  Future<void> _createSamplePosts() async {
    final sampleUsers = [
      User(
        id: 'user_1',
        username: 'john_doe',
        email: 'john@example.com',
        profileImageUrl: 'https://picsum.photos/100/100?random=1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: 'user_2',
        username: 'jane_smith',
        email: 'jane@example.com',
        profileImageUrl: 'https://picsum.photos/100/100?random=2',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      User(
        id: 'user_3',
        username: 'demo_user',
        email: 'demo@example.com',
        profileImageUrl: 'https://picsum.photos/100/100?random=3',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    // Save sample users
    for (final user in sampleUsers) {
      await HiveService.saveUser(user);
    }

    final samplePosts = [
      Post(
        id: 'post_1',
        userId: 'user_1',
        caption: 'Beautiful sunset from my evening walk! 🌅',
        imageUrl: 'https://picsum.photos/400/400?random=1',
        likesCount: 42,
        likedBy: ['user_2', 'user_3'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        user: sampleUsers[0],
      ),
      Post(
        id: 'post_2',
        userId: 'user_2',
        caption: 'Homemade pasta night! 🍝 Nothing beats fresh ingredients.',
        imageUrl: 'https://picsum.photos/400/400?random=2',
        likesCount: 28,
        likedBy: ['user_1'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        user: sampleUsers[1],
      ),
      Post(
        id: 'post_3',
        userId: 'user_3',
        caption: 'Coffee and coding session ☕️ Perfect way to start the day!',
        imageUrl: 'https://picsum.photos/400/400?random=3',
        likesCount: 15,
        likedBy: ['user_1', 'user_2'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        user: sampleUsers[2],
      ),
    ];

    // Save sample posts
    for (final post in samplePosts) {
      await HiveService.savePost(post);
    }
  }

}
