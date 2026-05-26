import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

class CommentService {
  final _supabase = Supabase.instance.client;

  Future<List<CommentModel>> getComments(String postId) async {
    final data = await _supabase
        .from('comments')
        .select('*, users(id, username, avatar_url, email, bio, created_at)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => CommentModel.fromJson(e)).toList();
  }

  Future<CommentModel> addComment({
    required String postId,
    required String text,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('comments')
        .insert({
          'post_id': postId,
          'user_id': userId,
          'text': text,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('*, users(id, username, avatar_url, email, bio, created_at)')
        .single();

    return CommentModel.fromJson(data);
  }

  Future<void> deleteComment(String commentId) async {
    await _supabase.from('comments').delete().eq('id', commentId);
  }
}
