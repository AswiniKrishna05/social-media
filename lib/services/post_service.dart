import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/post.dart';
import 'hive_service.dart';

/// Service class for handling post operations
class PostService {
  static const String _imagesFolder = 'post_images';

  /// Create a new post
  static Future<Post> createPost({
    required String userId,
    required String caption,
    String? imagePath,
  }) async {
    String? finalImagePath;
    
    // Copy image to app directory if provided
    if (imagePath != null) {
      finalImagePath = await _copyImageToAppDirectory(imagePath);
    }

    // Create post
    final post = Post.create(
      userId: userId,
      caption: caption,
      imageUrl: finalImagePath,
    );

    // Save post to local storage
    await HiveService.savePost(post);

    return post;
  }

  /// Get all posts with user information
  static List<Post> getAllPostsWithUsers() {
    final posts = HiveService.getAllPosts();
    
    // Populate user information for each post
    for (final post in posts) {
      post.user = HiveService.getUser(post.userId);
    }
    
    return posts;
  }

  /// Get posts by user ID with user information
  static List<Post> getPostsByUserWithUser(String userId) {
    final posts = HiveService.getPostsByUser(userId);
    
    // Populate user information for each post
    for (final post in posts) {
      post.user = HiveService.getUser(post.userId);
    }
    
    return posts;
  }

  /// Like or unlike a post
  static Future<Post> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final post = HiveService.getPost(postId);
    if (post == null) {
      throw Exception('Post not found');
    }

    // Toggle like
    final updatedPost = post.toggleLike(userId);

    // Save updated post
    await HiveService.savePost(updatedPost);

    return updatedPost;
  }

  /// Delete a post
  static Future<void> deletePost(String postId) async {
    final post = HiveService.getPost(postId);
    if (post != null && post.imageUrl != null) {
      // Delete associated image file
      await _deleteImageFile(post.imageUrl!);
    }
    
    await HiveService.deletePost(postId);
  }

  /// Pick image from gallery
  static Future<String?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return image?.path;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick image from camera
  static Future<String?> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return image?.path;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  /// Copy image to app directory and return the new path
  static Future<String> _copyImageToAppDirectory(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, _imagesFolder));
      
      // Create images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourcePath)}';
      final destinationPath = path.join(imagesDir.path, fileName);

      // Copy file
      await File(sourcePath).copy(destinationPath);

      return destinationPath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  /// Delete image file
  static Future<void> _deleteImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Log error but don't throw - image deletion failure shouldn't break the app
      // ignore: avoid_print
      print('Failed to delete image file: $e');
    }
  }

  /// Get image file from path
  static File? getImageFile(String? imagePath) {
    if (imagePath == null) return null;
    
    final file = File(imagePath);
    return file.existsSync() ? file : null;
  }

  /// Validate caption
  static bool isValidCaption(String caption) {
    return caption.trim().isNotEmpty && caption.length <= 500;
  }
}
