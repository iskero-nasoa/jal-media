import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final _supabase = Supabase.instance.client;

  Future<bool> toggleLike(String postId) async {
    final userId = _supabase.auth.currentUser!.id;

    final existing = await _supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId);

    if ((existing as List).isEmpty) {
      await _supabase.from('likes').insert({
        'post_id': postId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true; // now liked
    } else {
      await _supabase
          .from('likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      return false; // now unliked
    }
  }

  Future<int> getLikeCount(String postId) async {
    final data = await _supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId);
    return (data as List).length;
  }
}
