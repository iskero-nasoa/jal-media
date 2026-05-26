import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../controllers/feed_controller.dart';
import 'avatar_widget.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTapProfile;
  final VoidCallback? onTapComments;

  const PostCard({
    super.key,
    required this.post,
    this.onTapProfile,
    this.onTapComments,
  });

  @override
  Widget build(BuildContext context) {
    final feedController = Get.find<FeedController>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: onTapProfile,
              child: Row(
                children: [
                  AvatarWidget(
                    imageUrl: post.author?.avatarUrl,
                    username: post.author?.username ?? '?',
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author?.username ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeago.format(post.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Post image
          if (post.imageUrl != null)
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),

          // Actions row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Obx(() {
              // Force rebuild when posts list changes
              final p = feedController.posts.firstWhere(
                (e) => e.id == post.id,
                orElse: () => post,
              );
              return Row(
                children: [
                  IconButton(
                    onPressed: () => feedController.toggleLike(p),
                    icon: Icon(
                      p.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: p.isLiked ? Colors.red : null,
                    ),
                  ),
                  Text(
                    '${p.likesCount}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onTapComments,
                    icon: const Icon(Icons.chat_bubble_outline),
                  ),
                  Text(
                    '${p.commentsCount}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }),
          ),

          // Caption
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: '${post.author?.username ?? ''} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: post.caption),
                  ],
                ),
              ),
            ),

          const Divider(height: 1),
        ],
      ),
    );
  }
}
