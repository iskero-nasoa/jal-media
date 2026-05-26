import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/like_service.dart';

class FeedController extends GetxController {
  final PostService _postService = PostService();
  final LikeService _likeService = LikeService();

  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  int _currentPage = 0;

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  Future<void> loadFeed() async {
    isLoading.value = true;
    _currentPage = 0;
    hasMore.value = true;
    try {
      final result = await _postService.getFeedPosts(page: 0);
      posts.value = result;
      if (result.length < 10) hasMore.value = false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load feed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    try {
      _currentPage++;
      final result = await _postService.getFeedPosts(page: _currentPage);
      if (result.isEmpty) {
        hasMore.value = false;
      } else {
        posts.addAll(result);
        if (result.length < 10) hasMore.value = false;
      }
    } catch (_) {
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> toggleLike(PostModel post) async {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;

    // Optimistic update
    posts[index].isLiked = !posts[index].isLiked;
    posts[index].likesCount += posts[index].isLiked ? 1 : -1;
    posts.refresh();

    try {
      await _likeService.toggleLike(post.id);
    } catch (_) {
      // Rollback on error
      posts[index].isLiked = !posts[index].isLiked;
      posts[index].likesCount += posts[index].isLiked ? 1 : -1;
      posts.refresh();
    }
  }

  void addNewPost(PostModel post) {
    posts.insert(0, post);
  }
}
