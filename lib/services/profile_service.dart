import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<UserModel> getProfile(String userId) async {
    final data = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile({
    required String userId,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _supabase.from('users').update(updates).eq('id', userId);

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(data);
  }

  Future<String> uploadAvatar(String userId, File imageFile) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName = '$userId/avatar.$fileExt';

    await _supabase.storage
        .from('avatars')
        .upload(fileName, imageFile, fileOptions: const FileOptions(upsert: true));

    return _supabase.storage.from('avatars').getPublicUrl(fileName);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final data = await _supabase
        .from('users')
        .select()
        .ilike('username', '%$query%')
        .limit(20);
    return (data as List).map((e) => UserModel.fromJson(e)).toList();
  }
}
