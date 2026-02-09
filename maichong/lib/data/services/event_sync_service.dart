import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/event.dart';
import 'supabase_service.dart';

/// Service for real-time event synchronization with Supabase
class EventSyncService {
  final Function(Event)? onEventCreated;
  final Function(Event)? onEventUpdated;
  final Function(String)? onEventDeleted;

  RealtimeChannel? _channel;
  bool _isSubscribed = false;

  EventSyncService({
    this.onEventCreated,
    this.onEventUpdated,
    this.onEventDeleted,
  });

  /// Subscribe to real-time events for a specific timeline
  void subscribeToTimelineEvents(String timelineId) {
    if (!SupabaseService().isInitialized) {
      debugPrint('Supabase not initialized, skipping real-time sync');
      return;
    }

    try {
      _channel = Supabase.instance.client.channel(
        'timeline_events_$timelineId',
        opts: RealtimeChannelConfig(
          key: 'timeline_id',
          eq: timelineId,
        ),
      );

      _channel?.on(
        RealtimeListenEventType.postgres_changes,
        event: 'events',
        schema: 'public',
        table: 'events',
        filter: RealtimeSubscribeFilter(
          type: RealtimeSubscribeFilterType.eq,
          column: 'timeline_id',
          value: timelineId,
        ),
        callback: (payload, [ref]) {
          _handleRealtimeEvent(payload);
        },
      ).subscribe();

      _isSubscribed = true;
      debugPrint('Subscribed to timeline events: $timelineId');
    } catch (e) {
      debugPrint('Failed to subscribe to timeline events: $e');
    }
  }

  /// Subscribe to all events for the current user
  void subscribeToAllEvents() {
    if (!SupabaseService().isInitialized) {
      debugPrint('Supabase not initialized, skipping real-time sync');
      return;
    }

    try {
      _channel = Supabase.instance.client.channel('user_events');

      _channel?.on(
        RealtimeListenEventType.postgres_changes,
        event: 'events',
        schema: 'public',
        callback: (payload, [ref]) {
          _handleRealtimeEvent(payload);
        },
      ).subscribe();

      _isSubscribed = true;
      debugPrint('Subscribed to all user events');
    } catch (e) {
      debugPrint('Failed to subscribe to user events: $e');
    }
  }

  /// Handle incoming real-time events
  void _handleRealtimeEvent(dynamic payload) {
    try {
      final eventType = payload['eventType'];
      final data = payload['new'] as Map<String, dynamic>?;
      final oldData = payload['old'] as Map<String, dynamic>?;

      switch (eventType) {
        case 'INSERT':
          if (data != null && onEventCreated != null) {
            final event = _mapToEvent(data);
            if (event != null) {
              onEventCreated(event);
            }
          }
          break;

        case 'UPDATE':
          if (data != null && onEventUpdated != null) {
            final event = _mapToEvent(data);
            if (event != null) {
              onEventUpdated(event);
            }
          }
          break;

        case 'DELETE':
          if (oldData != null && onEventDeleted != null) {
            final eventId = oldData['id'] as String?;
            if (eventId != null) {
              onEventDeleted(eventId);
            }
          }
          break;
      }
    } catch (e) {
      debugPrint('Error handling real-time event: $e');
    }
  }

  /// Map database record to Event domain model
  Event? _mapToEvent(Map<String, dynamic> data) {
    try {
      final startTimeRaw = data['start_time']?.toString();
      final endTimeRaw = data['end_time']?.toString();
      if (startTimeRaw == null || endTimeRaw == null) {
        return null;
      }

      return Event(
        id: data['id']?.toString() ?? '',
        title: data['title'] ?? '',
        description: data['description'],
        startTime: DateTime.parse(startTimeRaw),
        endTime: DateTime.parse(endTimeRaw),
        location: data['location'],
        color: (data['color'] ?? '#6366f1').toString(),
        isAllDay: data['is_all_day'] == true,
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'].toString())
            : null,
        updatedAt: data['updated_at'] != null
            ? DateTime.parse(data['updated_at'].toString())
            : null,
      );
    } catch (e) {
      debugPrint('Error mapping event: $e');
      return null;
    }
  }

  /// Unsubscribe from event updates
  Future<void> unsubscribe() async {
    if (_channel != null) {
      try {
        await _channel!.unsubscribe();
        await _channel?.unsubscribe();
        _isSubscribed = false;
        debugPrint('Unsubscribed from real-time updates');
      } catch (e) {
        debugPrint('Error unsubscribing: $e');
      }
    }
  }

  /// Check if currently subscribed
  bool get isSubscribed => _isSubscribed;
}
