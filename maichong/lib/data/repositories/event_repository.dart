import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/event.dart';

abstract class EventRepository {
  Future<List<Event>> getAllEvents();
  Future<Event?> getEventById(String id);
  Future<List<Event>> getEventsByDate(DateTime date);
  Future<Event> createEvent(Event event);
  Future<Event> updateEvent(Event event);
  Future<void> deleteEvent(String id);
  Future<void> clearAllEvents();
}

class EventRepositoryImpl implements EventRepository {
  late Box<Event> _eventBox;

  static const String _boxName = 'events';

  Future<void> init() async {
    try {
      _eventBox = await Hive.openBox<Event>(_boxName);
    } catch (e) {
      throw Exception('Failed to initialize EventRepository: $e');
    }
  }

  Box<Event> get box => _eventBox;

  @override
  Future<List<Event>> getAllEvents() async {
    try {
      final events = _eventBox.values.toList();
      // Sort by start time, descending (newest first)
      events.sort((a, b) => b.startTime.compareTo(a.startTime));
      return events;
    } catch (e) {
      throw Exception('Failed to get all events: $e');
    }
  }

  @override
  Future<Event?> getEventById(String id) async {
    try {
      return _eventBox.get(id);
    } catch (e) {
      throw Exception('Failed to get event by id: $e');
    }
  }

  @override
  Future<List<Event>> getEventsByDate(DateTime date) async {
    try {
      final allEvents = await getAllEvents();
      final targetDate = DateTime(date.year, date.month, date.day);

      return allEvents.where((event) {
        final eventDate = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );
        return eventDate.isAtSameMomentAs(targetDate);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get events by date: $e');
    }
  }

  @override
  Future<Event> createEvent(Event event) async {
    try {
      if (!event.isValid) {
        throw ArgumentError('Invalid event data');
      }
      await _eventBox.put(event.id, event);
      return event;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  @override
  Future<Event> updateEvent(Event event) async {
    try {
      if (!event.isValid) {
        throw ArgumentError('Invalid event data');
      }
      await _eventBox.put(event.id, event);
      return event;
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await _eventBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  @override
  Future<void> clearAllEvents() async {
    try {
      await _eventBox.clear();
    } catch (e) {
      throw Exception('Failed to clear all events: $e');
    }
  }

  // Get events for a date range
  Future<List<Event>> getEventsInRange(DateTime start, DateTime end) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.where((event) {
        return event.startTime.isBefore(end) && event.endTime.isAfter(start);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get events in range: $e');
    }
  }

  // Get upcoming events (from now onwards)
  Future<List<Event>> getUpcomingEvents({int limit = 10}) async {
    try {
      final allEvents = await getAllEvents();
      final now = DateTime.now();

      final upcoming = allEvents
          .where((event) => event.endTime.isAfter(now))
          .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

      return upcoming.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming events: $e');
    }
  }
}
