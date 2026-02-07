import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<bool> get authStateChanges;
  bool get isAuthenticated;
  String? get currentUserId;
  User? get currentUser;

  Future<void> signUp(String email, String password, {String? nickname});
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateProfile({String? nickname, String? avatarUrl});
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;
  final _authStateController = BehaviorSubject<bool>.seeded(false);

  AuthRepositoryImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client {
    // Initialize auth state
    _authStateController.add(isAuthenticated);
  }

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;

  @override
  String? get currentUserId => _client.auth.currentSession?.user.id;

  @override
  User? get currentUser => _client.auth.currentSession?.user;

  @override
  Future<void> signUp(
    String email,
    String password, {
    String? nickname,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: nickname != null ? {'nickname': nickname} : null,
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      // Create user profile in public.users table
      final userId = response.user!.id;
      await _client.from('users').insert({
        'id': userId,
        'email': email,
        if (nickname != null) 'nickname': nickname,
      });

      _authStateController.add(true);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Sign in failed');
      }

      _authStateController.add(true);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _authStateController.add(false);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  @override
  Future<void> updateProfile({
    String? nickname,
    String? avatarUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _client.from('users').update({
        if (nickname != null) 'nickname': nickname,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
