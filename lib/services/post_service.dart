import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class PostService {
  final _supabase = Supabase.instance.client;

  static const int _pageSize = 10;

  Future<List<PostModel>> getFeedPosts({int page = 0}) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    final data = await _supabase
        .from('posts')
        .select('*, users(id, username, avatar_url, email, bio, created_at)')
        .order('created_at', ascending: false)
        .range(page * _pageSize, (page + 1) * _pageSize - 1);

    final posts = (data as List).map((e) => PostModel.fromJson(e)).toList();

    // Attach likes/comments counts and liked status
    for (final post in posts) {
      await _attachPostMeta(post, currentUserId);
    }

    return posts;
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    final data = await _supabase
        .from('posts')
        .select('*, users(id, username, avatar_url, email, bio, created_at)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final posts = (data as List).map((e) => PostModel.fromJson(e)).toList();
    for (final post in posts) {
      await _attachPostMeta(post, currentUserId);
    }
    return posts;
  }

  Future<void> _attachPostMeta(PostModel post, String? currentUserId) async {
    final results = await Future.wait([
      _supabase
          .from('likes')
          .select('id')
          .eq('post_id', post.id),
      _supabase
          .from('comments')
          .select('id')
          .eq('post_id', post.id),
    ]);

    post.likesCount = (results[0] as List).length;
    post.commentsCount = (results[1] as List).length;

    if (currentUserId != null) {
      final likeCheck = await _supabase
          .from('likes')
          .select('id')
          .eq('post_id', post.id)
          .eq('user_id', currentUserId);
      post.isLiked = (likeCheck as List).isNotEmpty;
    }
  }

  Future<PostModel> createPost({
    required String userId,
    required File imageFile,
    String? caption,
  }) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _supabase.storage
        .from('posts')
        .upload(fileName, imageFile);

    final imageUrl = _supabase.storage.from('posts').getPublicUrl(fileName);

    final data = await _supabase
        .from('posts')
        .insert({
          'user_id': userId,
          'image_url': imageUrl,
          'caption': caption,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('*, users(id, username, avatar_url, email, bio, created_at)')
        .single();

    return PostModel.fromJson(data);
  }

  Future<void> deletePost(String postId) async {
    await _supabase.from('posts').delete().eq('id', postId);
  }
}
