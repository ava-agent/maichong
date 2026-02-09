import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/event.dart';

abstract class EventRepositoryRemote {
  Future<List<Event>> getEventsByTimeline(String timelineId);
  Future<Event?> getEventById(String id);
  Future<Event> createEvent(Event event);
  Future<Event> updateEvent(Event event);
  Future<void> deleteEvent(String id);
  Future<List<Event>> getEventsInRange(DateTime start, DateTime end);
}

class EventRepositoryRemoteImpl implements EventRepositoryRemote {
  final SupabaseClient _client;

  EventRepositoryRemoteImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<String> _ensureDefaultTimelineId(String userId) async {
    try {
      final existing = await _client
          .from('user_timelines')
          .select('id')
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (existing != null && existing['id'] != null) {
        return existing['id'].toString();
      }
    } catch (_) {
      // fall through to create
    }

    final created = await _client
        .from('timelines')
        .insert({
          'name': '我的时间线',
          'description': '默认时间线',
          'owner_id': userId,
        })
        .select()
        .single();

    return created['id'].toString();
  }

  @override
  Future<List<Event>> getEventsByTimeline(String timelineId) async {
    try {
      final response = await _client
          .from('events')
          .select('*')
          .eq('timeline_id', timelineId)
          .order('start_time', ascending: false);

      final list = response as List;
      return list.map((json) => Event.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  @override
  Future<Event?> getEventById(String id) async {
    try {
      final response = await _client
          .from('events')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return Event.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  @override
  Future<Event> createEvent(Event event) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final timelineId = await _ensureDefaultTimelineId(userId);

      final data = {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'start_time': event.startTime.toIso8601String(),
        'end_time': event.endTime.toIso8601String(),
        'location': event.location,
        'color': event.color,
        'is_all_day': event.isAllDay,
        'timeline_id': timelineId,
        'creator_id': userId,
      };

      final response = await _client
          .from('events')
          .insert(data)
          .select()
          .single();

      return Event.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  @override
  Future<Event> updateEvent(Event event) async {
    try {
      final data = {
        'title': event.title,
        'description': event.description,
        'start_time': event.startTime.toIso8601String(),
        'end_time': event.endTime.toIso8601String(),
        'location': event.location,
        'color': event.color,
        'is_all_day': event.isAllDay,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('events')
          .update(data)
          .eq('id', event.id)
          .select()
          .single();

      return Event.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await _client.from('events').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  @override
  Future<List<Event>> getEventsInRange(DateTime start, DateTime end) async {
    try {
      final response = await _client
          .from('events')
          .select('*')
          .gte('start_time', start.toIso8601String())
          .lte('end_time', end.toIso8601String())
          .order('start_time', ascending: false);

      final list = response as List;
      return list.map((json) => Event.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      throw Exception('Failed to get events in range: $e');
    }
  }
}
