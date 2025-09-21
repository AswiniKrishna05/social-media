// import '../models/user.dart';
// import '../models/post.dart';
// import 'hive_service.dart';
//
// /// Service for creating and managing mock data for demonstration
// class MockDataService {
//   static const List<Map<String, dynamic>> _mockUsers = [
//     {
//       'username': 'john_doe',
//       'email': 'john@example.com',
//     },
//     {
//       'username': 'jane_smith',
//       'email': 'jane@example.com',
//     },
//     {
//       'username': 'alex_wilson',
//       'email': 'alex@example.com',
//     },
//     {
//       'username': 'sarah_jones',
//       'email': 'sarah@example.com',
//     },
//     {
//       'username': 'mike_brown',
//       'email': 'mike@example.com',
//     },
//   ];
//
//   static const List<Map<String, dynamic>> _mockPosts = [
//     {
//       'caption': 'Beautiful sunset from my hike today! 🌅 Nature never fails to amaze me.',
//       'likesCount': 24,
//       'likedBy': ['jane@example.com', 'alex@example.com', 'sarah@example.com'],
//     },
//     {
//       'caption': 'Just finished reading an amazing book! 📚 "The Psychology of Money" - highly recommend it to everyone.',
//       'likesCount': 18,
//       'likedBy': ['john@example.com', 'mike@example.com'],
//     },
//     {
//       'caption': 'Coffee and coding - the perfect combination! ☕️ Working on some exciting new features.',
//       'likesCount': 31,
//       'likedBy': ['jane@example.com', 'alex@example.com', 'sarah@example.com', 'mike@example.com'],
//     },
//     {
//       'caption': 'Weekend vibes! 🏖️ Sometimes you just need to disconnect and enjoy the simple things in life.',
//       'likesCount': 15,
//       'likedBy': ['john@example.com', 'alex@example.com'],
//     },
//     {
//       'caption': 'New recipe experiment! 🍝 Homemade pasta turned out better than expected. Cooking is such a therapeutic activity.',
//       'likesCount': 22,
//       'likedBy': ['jane@example.com', 'sarah@example.com', 'mike@example.com'],
//     },
//     {
//       'caption': 'Morning workout complete! 💪 Starting the day with energy and positivity. What\'s your favorite way to stay active?',
//       'likesCount': 28,
//       'likedBy': ['john@example.com', 'alex@example.com', 'sarah@example.com'],
//     },
//     {
//       'caption': 'Travel memories! ✈️ This photo brings back so many amazing memories from my trip to Japan last year.',
//       'likesCount': 35,
//       'likedBy': ['jane@example.com', 'alex@example.com', 'sarah@example.com', 'mike@example.com'],
//     },
//     {
//       'caption': 'Learning something new every day! 🎓 Just completed an online course on machine learning. The future is exciting!',
//       'likesCount': 19,
//       'likedBy': ['john@example.com', 'mike@example.com'],
//     },
//   ];
//
//   /// Initialize the app with mock data
//   static Future<void> initializeMockData() async {
//     // Check if mock data already exists
//     if (HiveService.getAllUsers().isNotEmpty) {
//       return; // Mock data already exists
//     }
//
//     // Create mock users
//     final users = <User>[];
//     for (int i = 0; i < _mockUsers.length; i++) {
//       final userData = _mockUsers[i];
//       final user = User.create(
//         username: userData['username'],
//         email: userData['email'],
//       );
//       users.add(user);
//       await HiveService.saveUser(user);
//     }
//
//     // Create mock posts
//     for (int i = 0; i < _mockPosts.length; i++) {
//       final postData = _mockPosts[i];
//       final userIndex = i % users.length; // Distribute posts among users
//       final user = users[userIndex];
//
//       // Create post with timestamp (older posts first)
//       final post = Post(
//         id: 'mock_post_${i + 1}',
//         userId: user.id,
//         caption: postData['caption'],
//         imageUrl: null, // No images for mock posts
//         likesCount: postData['likesCount'],
//         likedBy: postData['likedBy'],
//         createdAt: DateTime.now().subtract(Duration(days: i + 1, hours: i * 2)),
//         updatedAt: DateTime.now().subtract(Duration(days: i + 1, hours: i * 2)),
//         user: user,
//       );
//
//       await HiveService.savePost(post);
//     }
//   }
//
//   /// Add a few more mock posts for demonstration
//   static Future<void> addMoreMockPosts() async {
//     final users = HiveService.getAllUsers();
//     if (users.isEmpty) return;
//
//     final additionalPosts = [
//       {
//         'caption': 'Just discovered this amazing new café downtown! ☕️ The atmosphere is perfect for working remotely.',
//         'likesCount': 12,
//         'likedBy': [],
//       },
//       {
//         'caption': 'Weekend project complete! 🛠️ Built a small bookshelf for my home office. DIY projects are so satisfying!',
//         'likesCount': 16,
//         'likedBy': ['john@example.com'],
//       },
//       {
//         'caption': 'Movie night with friends! 🍿 Sometimes the best evenings are the simple ones with good company.',
//         'likesCount': 8,
//         'likedBy': ['jane@example.com', 'alex@example.com'],
//       },
//     ];
//
//     for (int i = 0; i < additionalPosts.length; i++) {
//       final postData = additionalPosts[i];
//       final user = users[i % users.length];
//
//       final post = Post.create(
//         userId: user.id,
//         caption: postData['caption'] as String,
//       );
//
//       // Set mock likes
//       final updatedPost = post.copyWith(
//         likesCount: postData['likesCount'] as int,
//         likedBy: postData['likedBy'] as List<String>,
//         createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
//         updatedAt: DateTime.now().subtract(Duration(hours: i + 1)),
//       );
//
//       await HiveService.savePost(updatedPost);
//     }
//   }
//
//   /// Clear all mock data (for testing purposes)
//   static Future<void> clearMockData() async {
//     await HiveService.clearAllData();
//   }
//
//   /// Check if mock data exists
//   static bool hasMockData() {
//     return HiveService.getAllUsers().isNotEmpty;
//   }
// }
