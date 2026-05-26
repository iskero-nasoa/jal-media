import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/post_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/post_model.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../comments/comments_screen.dart';
import '../post/create_post_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _profileController;
  List<PostModel> _userPosts = [];
  bool _postsLoading = true;

  @override
  void initState() {
    super.initState();
    _profileController = Get.find<ProfileController>();
    _profileController.loadProfile(widget.userId);
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _postsLoading = true);
    try {
      final posts = await Get.find<PostController>().getUserPosts(widget.userId);
      if (mounted) setState(() => _userPosts = posts);
    } catch (_) {}
    if (mounted) setState(() => _postsLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isOwnProfile = widget.userId == authController.currentUser.value?.id;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              _profileController.profileUser.value?.username ?? 'Profile',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Get.to(() => const EditProfileScreen()),
            ),
        ],
      ),
      body: Obx(() {
        if (_profileController.isLoading.value) return const LoadingIndicator();
        final user = _profileController.profileUser.value;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _profileController.loadProfile(widget.userId);
            await _loadPosts();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar with edit button
                      Stack(
                        children: [
                          AvatarWidget(
                            imageUrl: user.avatarUrl,
                            username: user.username,
                            radius: 48,
                          ),
                          if (isOwnProfile)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _profileController
                                    .uploadAvatar(widget.userId),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: const Icon(Icons.camera_alt,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.username,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          user.bio!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Post count
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.grid_on, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${_userPosts.length} Posts',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      if (isOwnProfile) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => Get.to(() => const CreatePostScreen()),
                          icon: const Icon(Icons.add),
                          label: const Text('New Post'),
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Divider(),
                    ],
                  ),
                ),
              ),

              // Posts grid
              if (_postsLoading)
                const SliverToBoxAdapter(child: LoadingIndicator())
              else if (_userPosts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.photo_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text('No posts yet',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = _userPosts[index];
                      return GestureDetector(
                        onTap: () => Get.to(() => CommentsScreen(post: post)),
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey.shade200),
                          errorWidget: (context, url, error) =>
                              Container(color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image)),
                        ),
                      );
                    },
                    childCount: _userPosts.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
