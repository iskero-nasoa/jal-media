import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/comment_model.dart';
import 'avatar_widget.dart';

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final String? currentUserId;
  final VoidCallback? onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    this.currentUserId,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = comment.userId == currentUserId;
    final author = comment.author;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarWidget(
            imageUrl: author?.avatarUrl,
            username: author?.username ?? '?',
            radius: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${author?.username ?? 'Unknown'} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment.text),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeago.format(comment.createdAt),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isOwner && onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
