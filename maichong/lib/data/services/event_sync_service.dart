import 'package:flutter/foundation.dart';
import '../../domain/models/event.dart';

/// Simplified sync service for real-time event updates
/// Note: Real-time sync requires Supabase configuration and proper API setup
class EventSyncService {
  final Function(Event)? onEventCreated;
  final Function(Event)? onEventUpdated;
  final Function(String)? onEventDeleted;

  EventSyncService({
    this.onEventCreated,
    this.onEventUpdated,
    this.onEventDeleted,
  });

  /// Subscribe to real-time events for a timeline
  /// Note: This is a placeholder for when Supabase is properly configured
  void subscribeToTimelineEvents(String timelineId) {
    debugPrint('Real-time sync not yet implemented. Timeline ID: $timelineId');
  }

  /// Subscribe to all events for the current user
  void subscribeToAllEvents() {
    debugPrint('Real-time sync not yet implemented');
  }

  /// Unsubscribe from event updates
  Future<void> unsubscribe() async {
    debugPrint('Unsubscribed from real-time updates');
  }
}
