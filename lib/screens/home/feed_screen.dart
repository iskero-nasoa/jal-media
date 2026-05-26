import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/feed_controller.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/post_card.dart';
import '../comments/comments_screen.dart';
import '../profile/profile_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feedController = Get.find<FeedController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jal Media', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Obx(() {
        if (feedController.isLoading.value && feedController.posts.isEmpty) {
          return const LoadingIndicator();
        }

        if (feedController.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No posts yet',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('Be the first to share something!',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
              feedController.loadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: feedController.loadFeed,
            child: ListView.builder(
              itemCount: feedController.posts.length +
                  (feedController.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == feedController.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final post = feedController.posts[index];
                return PostCard(
                  post: post,
                  onTapProfile: () => Get.to(() =>
                      ProfileScreen(userId: post.userId)),
                  onTapComments: () => Get.to(
                    () => CommentsScreen(post: post),
                    transition: Transition.downToUp,
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<AuthController>().logout();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
