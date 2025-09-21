// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../viewmodels/api_post_viewmodel.dart';
// import '../../models/post.dart';
// import 'add_post_screen.dart';
// import '../../widgets/post_card.dart';
//
// /// Feed screen that fetches posts from API
// class ApiFeedScreen extends StatefulWidget {
//   const ApiFeedScreen({super.key});
//
//   @override
//   State<ApiFeedScreen> createState() => _ApiFeedScreenState();
// }
//
// class _ApiFeedScreenState extends State<ApiFeedScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ApiPostViewModel>(context, listen: false).initialize();
//     });
//   }
//
//   Future<void> _handleLogout() async {
//     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
//     await authViewModel.signOut();
//
//     if (mounted) {
//       Navigator.of(context).pushReplacementNamed('/login');
//     }
//   }
//
//   Future<void> _handleRefresh() async {
//     await Provider.of<ApiPostViewModel>(context, listen: false).refreshPosts();
//   }
//
//   Future<void> _showApiStatus() async {
//     final apiViewModel = Provider.of<ApiPostViewModel>(context, listen: false);
//     final status = await apiViewModel.checkApiStatus();
//
//     if (mounted) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('API Status'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Status: ${status['status']}'),
//               const SizedBox(height: 8),
//               Text('Base URL: ${status['baseUrl'] ?? 'N/A'}'),
//               const SizedBox(height: 8),
//               Text('Last Checked: ${status['lastChecked'] ?? 'N/A'}'),
//               if (status['error'] != null) ...[
//                 const SizedBox(height: 8),
//                 Text('Error: ${status['error']}', style: const TextStyle(color: Colors.red)),
//               ],
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Social Media (API)',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Theme.of(context).primaryColor,
//         elevation: 0,
//         actions: [
//           Consumer<AuthViewModel>(
//             builder: (context, authViewModel, child) {
//               return PopupMenuButton<String>(
//                 icon: const Icon(Icons.more_vert, color: Colors.white),
//                 onSelected: (value) async {
//                   if (value == 'logout') {
//                     _handleLogout();
//                   } else if (value == 'api_status') {
//                     _showApiStatus();
//                   } else if (value == 'refresh_api') {
//                     final apiViewModel = Provider.of<ApiPostViewModel>(context, listen: false);
//                     await apiViewModel.refreshPosts();
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Refreshed from API!'),
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                     }
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                     value: 'api_status',
//                     child: Row(
//                       children: [
//                         Icon(Icons.info_outline, color: Colors.blue),
//                         SizedBox(width: 8),
//                         Text('API Status'),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'refresh_api',
//                     child: Row(
//                       children: [
//                         Icon(Icons.refresh, color: Colors.green),
//                         SizedBox(width: 8),
//                         Text('Refresh from API'),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'logout',
//                     child: Row(
//                       children: [
//                         Icon(Icons.logout, color: Colors.red),
//                         SizedBox(width: 8),
//                         Text('Logout'),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//       body: Consumer2<ApiPostViewModel, AuthViewModel>(
//         builder: (context, apiViewModel, authViewModel, child) {
//           if (apiViewModel.isLoading && apiViewModel.posts.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Fetching posts from API...'),
//                 ],
//               ),
//             );
//           }
//
//           if (apiViewModel.errorMessage != null && apiViewModel.posts.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 80,
//                     color: Colors.red[300],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Failed to load posts',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     apiViewModel.errorMessage!,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[500],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () => apiViewModel.initialize(),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           if (apiViewModel.posts.isEmpty) {
//             return RefreshIndicator(
//               onRefresh: _handleRefresh,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.7,
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.cloud_off,
//                           size: 80,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No posts available',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           apiViewModel.isApiAvailable
//                               ? 'Pull down to refresh from API'
//                               : 'API is offline - showing local data',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton.icon(
//                           onPressed: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => const AddPostScreen(),
//                               ),
//                             );
//                           },
//                           icon: const Icon(Icons.add),
//                           label: const Text('Create Post'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(context).primaryColor,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }
//
//           return RefreshIndicator(
//             onRefresh: _handleRefresh,
//             child: Column(
//               children: [
//                 // API Status Banner
//                 if (!apiViewModel.isApiAvailable)
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(8),
//                     color: Colors.orange[100],
//                     child: Row(
//                       children: [
//                         Icon(Icons.cloud_off, color: Colors.orange[800], size: 16),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             'API is offline - showing local data',
//                             style: TextStyle(
//                               color: Colors.orange[800],
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 // Posts List
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: apiViewModel.posts.length,
//                     itemBuilder: (context, index) {
//                       final post = apiViewModel.posts[index];
//                       return PostCard(
//                         post: post,
//                         currentUserId: authViewModel.currentUser?.id ?? '',
//                         onLike: () {
//                           apiViewModel.toggleLike(
//                             postId: post.id,
//                             userId: authViewModel.currentUser?.id ?? '',
//                           );
//                         },
//                         onDelete: () {
//                           _showDeleteDialog(context, post, apiViewModel);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => const AddPostScreen(),
//             ),
//           );
//         },
//         backgroundColor: Theme.of(context).primaryColor,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
//
//   void _showDeleteDialog(BuildContext context, Post post, ApiPostViewModel apiViewModel) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Post'),
//         content: const Text('Are you sure you want to delete this post?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.of(context).pop();
//               final success = await apiViewModel.deletePost(post.id);
//               if (success && context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Post deleted successfully'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               }
//             },
//             child: const Text(
//               'Delete',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
