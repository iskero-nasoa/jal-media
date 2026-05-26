import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/comment_controller.dart';
import '../../controllers/feed_controller.dart';
import '../../models/post_model.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/comment_tile.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/post_card.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel post;

  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _textController = TextEditingController();
  late final CommentController _commentController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _commentController = Get.put(CommentController());
    _commentController.loadComments(widget.post.id);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    // Update comment count in feed on close
    if (Get.isRegistered<FeedController>()) {
      final idx = Get.find<FeedController>()
          .posts
          .indexWhere((p) => p.id == widget.post.id);
      if (idx != -1) {
        Get.find<FeedController>().posts[idx].commentsCount =
            _commentController.comments.length;
        Get.find<FeedController>().posts.refresh();
      }
    }
    Get.delete<CommentController>();
    super.dispose();
  }

  void _sendComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    await _commentController.addComment(
      postId: widget.post.id,
      text: text,
    );

    // Scroll to bottom after sending
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          // Post preview
          PostCard(
            post: widget.post,
            onTapComments: null,
          ),

          const Divider(height: 1),

          // Comments list
          Expanded(
            child: Obx(() {
              if (_commentController.isLoading.value) {
                return const LoadingIndicator();
              }

              if (_commentController.comments.isEmpty) {
                return const Center(
                  child: Text('No comments yet. Be the first!',
                      style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: _commentController.comments.length,
                itemBuilder: (context, index) {
                  final comment = _commentController.comments[index];
                  return CommentTile(
                    comment: comment,
                    currentUserId: currentUserId,
                    onDelete: comment.userId == currentUserId
                        ? () => _showDeleteConfirmation(comment.id)
                        : null,
                  );
                },
              );
            }),
          ),

          // Comment input
          Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey.shade200)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                AvatarWidget(
                  imageUrl: authController.currentUser.value?.avatarUrl,
                  username: authController.currentUser.value?.username ?? '?',
                  radius: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      isDense: true,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => IconButton(
                      onPressed: _commentController.isSending.value
                          ? null
                          : _sendComment,
                      icon: _commentController.isSending.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String commentId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _commentController.deleteComment(commentId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

