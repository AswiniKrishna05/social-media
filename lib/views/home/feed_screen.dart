import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/post_viewmodel.dart';
import '../../models/post.dart';
import '../../services/mock_data_service.dart';
import 'add_post_screen.dart';
import '../../widgets/post_card.dart';

/// Main feed screen displaying all posts
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostViewModel>(context, listen: false).initialize();
    });
  }

  Future<void> _handleLogout() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _handleRefresh() async {
    await Provider.of<PostViewModel>(context, listen: false).refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Social Media',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'logout') {
                    _handleLogout();
                  } else if (value == 'add_samples') {
                    final postViewModel = Provider.of<PostViewModel>(context, listen: false);
                    // await MockDataService.addMoreMockPosts();
                    await postViewModel.refreshPosts();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added more sample posts!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else if (value == 'api_feed') {
                    Navigator.of(context).pushNamed('/api-feed');
                  } else if (value == 'instagram_feed') {
                    Navigator.of(context).pushNamed('/instagram-feed');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add_samples',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Add Sample Posts'),
                      ],
                    ),
                  ),
                  // const PopupMenuItem(
                  //   value: 'api_feed',
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.cloud, color: Colors.green),
                  //       SizedBox(width: 8),
                  //       Text('API Feed'),
                  //     ],
                  //   ),
                  // ),
                  const PopupMenuItem(
                    value: 'instagram_feed',
                    child: Row(
                      children: [
                        Icon(Icons.photo_camera, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Instagram Feed'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<PostViewModel, AuthViewModel>(
        builder: (context, postViewModel, authViewModel, child) {
          if (postViewModel.isLoading && postViewModel.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (postViewModel.posts.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share something!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AddPostScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            // await MockDataService.addMoreMockPosts();
                            // await postViewModel.refreshPosts();
                            // if (context.mounted) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(
                            //       content: Text('Added more sample posts!'),
                            //       backgroundColor: Colors.green,
                            //     ),
                            //   );
                            // }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Add Sample Posts'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: postViewModel.posts.length,
              itemBuilder: (context, index) {
                final post = postViewModel.posts[index];
                return PostCard(
                  post: post,
                  currentUserId: authViewModel.currentUser?.id ?? '',
                  onLike: () {
                    postViewModel.toggleLike(
                      postId: post.id,
                      userId: authViewModel.currentUser?.id ?? '',
                    );
                  },
                  onDelete: () {
                    _showDeleteDialog(context, post, postViewModel);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPostScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Post post, PostViewModel postViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await postViewModel.deletePost(post.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
