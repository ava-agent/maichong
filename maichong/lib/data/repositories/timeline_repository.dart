import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TimelineRepository {
  Future<List<Map<String, dynamic>>> getTimelines();
  Future<Map<String, dynamic>?> getTimelineById(String id);
  Future<Map<String, dynamic>> createTimeline(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateTimeline(String id, Map<String, dynamic> data);
  Future<void> deleteTimeline(String id);
  Future<List<Map<String, dynamic>>> getUserTimelines(String userId);
}

class TimelineRepositoryImpl implements TimelineRepository {
  final SupabaseClient _client;

  TimelineRepositoryImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> getTimelines() async {
    try {
      final response = await _client
          .from('timelines')
          .select('*, timeline_members!inner(role)')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to get timelines: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getTimelineById(String id) async {
    try {
      final response = await _client
          .from('timelines')
          .select('*')
          .eq('id', id)
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      if (e.toString().contains('Not found')) {
        return null;
      }
      throw Exception('Failed to get timeline: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createTimeline(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('timelines')
          .insert(data)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to create timeline: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateTimeline(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('timelines')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to update timeline: $e');
    }
  }

  @override
  Future<void> deleteTimeline(String id) async {
    try {
      await _client.from('timelines').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete timeline: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserTimelines(String userId) async {
    try {
      final response = await _client
          .from('timelines')
          .select('*, timeline_members!inner(role, user_id)')
          .order('created_at', ascending: false);

      final results = List<Map<String, dynamic>>.from(response as List);

      // Filter to only timelines where user is a member
      return results.where((timeline) {
        final members = timeline['timeline_members'] as List?;
        if (members == null) return false;
        return members.any((m) => m['user_id'] == userId);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user timelines: $e');
    }
  }
}
