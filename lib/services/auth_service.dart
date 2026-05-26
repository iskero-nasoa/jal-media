import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign up failed: no user returned');
    }

    // Create profile row in users table
    await _supabase.from('users').insert({
      'id': response.user!.id,
      'email': email,
      'username': username,
      'created_at': DateTime.now().toIso8601String(),
    });

    final profile = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    return UserModel.fromJson(profile);
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign in failed');
    }

    final profile = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    return UserModel.fromJson(profile);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data != null ? UserModel.fromJson(data) : null;
  }
}
