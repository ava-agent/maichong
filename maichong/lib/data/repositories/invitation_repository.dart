import 'package:supabase_flutter/supabase_flutter.dart';

abstract class InvitationRepository {
  Future<List<Map<String, dynamic>>> getPendingInvitations();
  Future<Map<String, dynamic>> createInvitation(
    String timelineId,
    String email, {
    String role = 'member',
  });
  Future<void> acceptInvitation(String invitationId);
  Future<void> rejectInvitation(String invitationId);
  Future<void> cancelInvitation(String invitationId);
  Future<Map<String, dynamic>?> getInvitationByCode(String code);
}

class InvitationRepositoryImpl implements InvitationRepository {
  final SupabaseClient _client;

  InvitationRepositoryImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    try {
      final userId = _client.auth.currentSession?.user.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('invitations')
          .select('*, timelines(*), users!inviter_id(*)')
          .eq('invitee_email', _client.auth.currentUser?.email)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final list = response as List;
      return list.map((json) => Map<String, dynamic>.from(json)).toList();
    } catch (e) {
      throw Exception('Failed to get invitations: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createInvitation(
    String timelineId,
    String email, {
    String role = 'member',
  }) async {
    try {
      final userId = _client.auth.currentSession?.user.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'timeline_id': timelineId,
        'inviter_id': userId,
        'invitee_email': email,
        'role': role,
        'status': 'pending',
      };

      final response = await _client
          .from('invitations')
          .insert(data)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to create invitation: $e');
    }
  }

  @override
  Future<void> acceptInvitation(String invitationId) async {
    try {
      // Get invitation details
      final invitation = await _client
          .from('invitations')
          .select('*')
          .eq('id', invitationId)
          .single();

      // Update invitation status
      await _client
          .from('invitations')
          .update({'status': 'accepted'})
          .eq('id', invitationId);

      // Add user as timeline member
      await _client.from('timeline_members').insert({
        'timeline_id': invitation['timeline_id'],
        'user_id': _client.auth.currentSession?.user.id,
        'role': invitation['role'] ?? 'member',
      });
    } catch (e) {
      throw Exception('Failed to accept invitation: $e');
    }
  }

  @override
  Future<void> rejectInvitation(String invitationId) async {
    try {
      await _client
          .from('invitations')
          .update({'status': 'rejected'})
          .eq('id', invitationId);
    } catch (e) {
      throw Exception('Failed to reject invitation: $e');
    }
  }

  @override
  Future<void> cancelInvitation(String invitationId) async {
    try {
      await _client
          .from('invitations')
          .update({'status': 'cancelled'})
          .eq('id', invitationId);
    } catch (e) {
      throw Exception('Failed to cancel invitation: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getInvitationByCode(String code) async {
    try {
      // Extract ID from code (assuming code is the invitation ID)
      final response = await _client
          .from('invitations')
          .select('*, timelines(*), users!inviter_id(*)')
          .eq('id', code)
          .eq('status', 'pending')
          .maybeSingle();

      if (response == null) return null;

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to get invitation: $e');
    }
  }
}
