import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/instagram_viewmodel.dart';
import '../../models/post.dart';
import '../../services/instagram_api_service.dart';
import '../../widgets/instagram_post_card.dart';

/// Instagram-style feed screen with images, likes, and captions
class InstagramFeedScreen extends StatefulWidget {
  const InstagramFeedScreen({super.key});

  @override
  State<InstagramFeedScreen> createState() => _InstagramFeedScreenState();
}

class _InstagramFeedScreenState extends State<InstagramFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InstagramViewModel>(context, listen: false).initialize();
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
    await Provider.of<InstagramViewModel>(context, listen: false).refreshPosts();
  }

  Future<void> _showApiStatus() async {
    final instagramViewModel = Provider.of<InstagramViewModel>(context, listen: false);
    final status = await instagramViewModel.checkApiStatus();
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Instagram API Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${status['status']}'),
              const SizedBox(height: 8),
              Text('Base URL: ${status['baseUrl'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Last Checked: ${status['lastChecked'] ?? 'N/A'}'),
              if (status['error'] != null) ...[
                const SizedBox(height: 8),
                Text('Error: ${status['error']}', style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Instagram Feed',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'logout') {
                    _handleLogout();
                  } else if (value == 'api_status') {
                    _showApiStatus();
                  } else if (value == 'refresh_api') {
                    final instagramViewModel = Provider.of<InstagramViewModel>(context, listen: false);
                    await instagramViewModel.refreshPosts();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Refreshed Instagram feed!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'api_status',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('API Status'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh_api',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Refresh Feed'),
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
      body: Consumer2<InstagramViewModel, AuthViewModel>(
        builder: (context, instagramViewModel, authViewModel, child) {
          if (instagramViewModel.isLoading && instagramViewModel.posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading Instagram feed...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          if (instagramViewModel.errorMessage != null && instagramViewModel.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load Instagram feed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    instagramViewModel.errorMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => instagramViewModel.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (instagramViewModel.posts.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No Instagram posts available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
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
            child: Column(
              children: [
                // API Status Banner
                if (!instagramViewModel.isApiAvailable)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.orange[900],
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off, color: Colors.orange[100], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Instagram API is offline - showing mock data',
                            style: TextStyle(
                              color: Colors.orange[100],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Instagram Posts List
                Expanded(
                  child: ListView.builder(
                    itemCount: instagramViewModel.posts.length,
                    itemBuilder: (context, index) {
                      final post = instagramViewModel.posts[index];
                      return InstagramPostCard(
                        post: post,
                        currentUserId: authViewModel.currentUser?.id ?? '',
                        onLike: () {
                          instagramViewModel.toggleLike(
                            postId: post.id,
                            userId: authViewModel.currentUser?.id ?? '',
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
