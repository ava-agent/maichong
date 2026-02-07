import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  SupabaseClient get client => Supabase.instance.client;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: _getUrl(),
        anonKey: _getAnonKey(),
        debug: kDebugMode,
      );
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  String _getUrl() {
    // TODO: Move to environment variables
    // For now, return empty - user needs to configure
    const url = String.fromEnvironment('SUPABASE_URL');
    if (url.isEmpty) {
      throw Exception(
        'SUPABASE_URL not configured. '
        'Please set environment variables or update the code.',
      );
    }
    return url;
  }

  String _getAnonKey() {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY not configured. '
        'Please set environment variables or update the code.',
      );
    }
    return key;
  }

  // Auth helpers
  bool get isAuthenticated => client.auth.currentSession != null;
  String? get currentUserId => client.auth.currentSession?.user.id;

  // Database table references
  static const String usersTable = 'users';
  static const String timelinesTable = 'timelines';
  static const String timelineMembersTable = 'timeline_members';
  static const String eventsTable = 'events';
  static const String invitationsTable = 'invitations';
}
