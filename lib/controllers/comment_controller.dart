import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';
import 'auth_controller.dart';

class CommentController extends GetxController {
  final CommentService _commentService = CommentService();

  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  Future<void> loadComments(String postId) async {
    isLoading.value = true;
    try {
      comments.value = await _commentService.getComments(postId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load comments',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    isSending.value = true;
    try {
      final comment = await _commentService.addComment(
        postId: postId,
        text: text.trim(),
      );
      comments.add(comment);
    } catch (e) {
      Get.snackbar('Error', 'Failed to post comment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> deleteComment(String commentId) async {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;

    final comment = comments.firstWhere((c) => c.id == commentId);
    if (comment.userId != currentUserId) return;

    try {
      await _commentService.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete comment',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
