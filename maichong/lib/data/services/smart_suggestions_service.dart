import '../domain/models/event.dart';
import 'ai_service.dart';

/// Service for providing smart scheduling suggestions and conflict detection
class SmartSuggestionsService {
  final AIService _aiService = AIService();

  /// Detect conflicts between a potential event and existing events
  List<ScheduleConflict> detectConflicts(Event potentialEvent, List<Event> existingEvents) {
    final conflicts = <ScheduleConflict>[];

    for (final existing in existingEvents) {
      if (_hasTimeOverlap(potentialEvent, existing)) {
        conflicts.add(ScheduleConflict(
          conflictingEvent: existing,
          conflictType: _getConflictType(potentialEvent, existing),
          severity: _getConflictSeverity(potentialEvent, existing),
        ));
      }
    }

    // Sort by severity (high first)
    conflicts.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return conflicts;
  }

  /// Check if two events overlap in time
  bool _hasTimeOverlap(Event event1, Event event2) {
    final start1 = event1.startTime;
    final end1 = event1.endTime;
    final start2 = event2.startTime;
    final end2 = event2.endTime;

    // Events overlap if one starts before the other ends
    // and ends after the other starts
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  /// Determine the type of conflict
  ConflictType _getConflictType(Event event1, Event event2) {
    // Exact same time
    if (event1.startTime.isAtSameMomentAs(event2.startTime)) {
      return ConflictType.exactOverlap;
    }

    // One is contained within the other
    if ((event1.startTime.isAfter(event2.startTime) ||
            event1.startTime.isAtSameMomentAs(event2.startTime)) &&
        (event1.endTime.isBefore(event2.endTime) ||
            event1.endTime.isAtSameMomentAs(event2.endTime))) {
      return ConflictType.contained;
    }

    // Partial overlap
    return ConflictType.partialOverlap;
  }

  /// Get conflict severity based on overlap duration
  ConflictSeverity _getConflictSeverity(Event event1, Event event2) {
    final overlapStart = event1.startTime.isAfter(event2.startTime)
        ? event1.startTime
        : event2.startTime;
    final overlapEnd = event1.endTime.isBefore(event2.endTime)
        ? event1.endTime
        : event2.endTime;

    final overlapDuration = overlapEnd.difference(overlapStart);
    final event1Duration = event1.endTime.difference(event1.startTime);

    // If more than 50% of the event overlaps
    if (overlapDuration.inMinutes / event1Duration.inMinutes > 0.5) {
      return ConflictSeverity.high;
    }

    // If more than 25% overlaps
    if (overlapDuration.inMinutes / event1Duration.inMinutes > 0.25) {
      return ConflictSeverity.medium;
    }

    return ConflictSeverity.low;
  }

  /// Get smart time suggestions for a new event
  /// Returns a list of suggested time slots
  List<TimeSuggestion> getSuggestedTimeSlots({
    required DateTime preferredDate,
    required Duration duration,
    List<Event>? existingEvents,
    int maxSuggestions = 5,
  }) {
    final suggestions = <TimeSuggestion>[];
    final events = existingEvents ?? [];

    // Generate time slots throughout the day
    final slots = _generateTimeSlots(preferredDate, duration);

    for (final slot in slots) {
      if (suggestions.length >= maxSuggestions) break;

      final potentialEvent = Event(
        id: 'potential',
        title: 'Potential Event',
        startTime: slot.start,
        endTime: slot.end,
      );

      final conflicts = detectConflicts(potentialEvent, events);

      suggestions.add(TimeSuggestion(
        startTime: slot.start,
        endTime: slot.end,
        confidence: _calculateConfidence(slot, conflicts, preferredDate),
        conflicts: conflicts,
        reason: _getSuggestionReason(slot, conflicts, preferredDate),
      ));
    }

    // Sort by confidence
    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));

    return suggestions;
  }

  /// Generate time slots for a given date
  List<TimeSlot> _generateTimeSlots(DateTime date, Duration duration) {
    final slots = <TimeSlot>[];

    // Business hours: 9 AM to 9 PM
    final startOfDay = DateTime(date.year, date.month, date.day, 9, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 21, 0);

    // Generate hourly slots
    var current = startOfDay;
    while (current.add(duration).isBefore(endOfDay) ||
        current.add(duration).isAtSameMomentAs(endOfDay)) {
      slots.add(TimeSlot(
        start: current,
        end: current.add(duration),
      ));
      current = current.add(const Duration(hours: 1));
    }

    return slots;
  }

  /// Calculate confidence score for a time suggestion
  double _calculateConfidence(TimeSlot slot, List<ScheduleConflict> conflicts, DateTime preferredDate) {
    double score = 1.0;

    // Reduce score based on conflicts
    for (final conflict in conflicts) {
      switch (conflict.severity) {
        case ConflictSeverity.high:
          score -= 0.5;
          break;
        case ConflictSeverity.medium:
          score -= 0.3;
          break;
        case ConflictSeverity.low:
          score -= 0.1;
          break;
      }
    }

    // Boost score for preferred times (morning: 9-11, afternoon: 2-4)
    final hour = slot.start.hour;
    if ((hour >= 9 && hour < 11) || (hour >= 14 && hour < 16)) {
      score += 0.2;
    }

    // Boost score if it's today (user likely wants to schedule soon)
    if (slot.start.day == DateTime.now().day &&
        slot.start.month == DateTime.now().month &&
        slot.start.year == DateTime.now().year) {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Get human-readable reason for suggestion
  String _getSuggestionReason(TimeSlot slot, List<ScheduleConflict> conflicts, DateTime preferredDate) {
    if (conflicts.isEmpty) {
      final hour = slot.start.hour;
      if (hour >= 9 && hour < 12) {
        return '清爽的早晨时段';
      } else if (hour >= 12 && hour < 14) {
        return '午休时段';
      } else if (hour >= 14 && hour < 17) {
        return '高效的工作时段';
      } else if (hour >= 17 && hour < 19) {
        return '傍晚时光';
      } else {
        return '空闲时段';
      }
    }

    if (conflicts.length == 1) {
      return '仅有一个轻微冲突';
    }

    return '有 ${conflicts.length} 个潜在冲突';
  }

  /// Get smart suggestions for event completion
  /// based on similar past events or common patterns
  List<String> getEventCompletionSuggestions(String partialInput, {List<Event>? pastEvents}) {
    final suggestions = <String>[];

    // Common event prefixes
    final commonPrefixes = [
      '和', '与', '开会', '讨论', '会议', '午餐', '晚餐',
      '咖啡', '运动', '健身', '看电影', '购物',
    ];

    // Check if partial input matches any common prefix
    for (final prefix in commonPrefixes) {
      if (prefix.startsWith(partialInput) || partialInput.contains(prefix)) {
        suggestions.add(prefix);
      }
    }

    // Add suggestions from past events
    if (pastEvents != null) {
      final uniqueTitles = pastEvents.map((e) => e.title).toSet();
      for (final title in uniqueTitles) {
        if (title.toLowerCase().contains(partialInput.toLowerCase())) {
          suggestions.add(title);
        }
      }
    }

    return suggestions.toSet().take(5).toList();
  }

  /// Analyze user's schedule patterns and provide insights
  ScheduleInsights analyzeSchedulePatterns(List<Event> events) {
    if (events.isEmpty) {
      return ScheduleInsights(
        totalEvents: 0,
        busiestDay: null,
        averageEventsPerDay: 0,
        peakHours: [],
        suggestions: ['开始添加事件来建立你的时间线！'],
      );
    }

    // Count events by day of week
    final dayCounts = List.filled(7, 0);
    final hourCounts = List.filled(24, 0);

    for (final event in events) {
      dayCounts[event.startTime.weekday % 7]++;
      hourCounts[event.startTime.hour]++;
    }

    // Find busiest day
    final busiestDayIndex = dayCounts.indexOf(dayCounts.reduce((a, b) => a > b ? a : b));
    final days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    // Find peak hours
    final peakHours = <int>[];
    final maxHourCount = hourCounts.reduce((a, b) => a > b ? a : b);
    for (var i = 0; i < hourCounts.length; i++) {
      if (hourCounts[i] >= maxHourCount * 0.7) {
        peakHours.add(i);
      }
    }

    // Generate suggestions
    final suggestions = <String>[];

    if (dayCounts[5] + dayCounts[6] < dayCounts.reduce((a, b) => a + b) * 0.2) {
      suggestions.add('你的周末时间比较空闲，考虑安排一些休闲活动！');
    }

    if (hourCounts[12] + hourCounts[13] > 0) {
      suggestions.add('你经常在午休时间安排活动，注意劳逸结合！');
    }

    return ScheduleInsights(
      totalEvents: events.length,
      busiestDay: days[busiestDayIndex],
      averageEventsPerDay: events.length / 7,
      peakHours: peakHours,
      suggestions: suggestions,
    );
  }
}

/// Represents a scheduling conflict
class ScheduleConflict {
  final Event conflictingEvent;
  final ConflictType conflictType;
  final ConflictSeverity severity;

  ScheduleConflict({
    required this.conflictingEvent,
    required this.conflictType,
    required this.severity,
  });

  @override
  String toString() {
    return 'ScheduleConflict(event: ${conflictingEvent.title}, type: $conflictType, severity: $severity)';
  }
}

/// Type of conflict
enum ConflictType {
  exactOverlap, // Events start at exactly the same time
  contained, // One event is entirely within another
  partialOverlap, // Events partially overlap
}

/// Severity of conflict
enum ConflictSeverity {
  low, // Brief overlap or small portion affected
  medium, // Moderate overlap
  high, // Significant overlap or exact match
}

/// A time slot suggestion
class TimeSuggestion {
  final DateTime startTime;
  final DateTime endTime;
  final double confidence; // 0.0 to 1.0
  final List<ScheduleConflict> conflicts;
  final String reason;

  TimeSuggestion({
    required this.startTime,
    required this.endTime,
    required this.confidence,
    required this.conflicts,
    required this.reason,
  });

  @override
  String toString() {
    return 'TimeSuggestion(${startTime.hour}:${startTime.minute} - ${endTime.hour}:${endTime.minute}, confidence: $confidence)';
  }
}

/// A time slot
class TimeSlot {
  final DateTime start;
  final DateTime end;

  TimeSlot({required this.start, required this.end});
}

/// Insights about user's schedule patterns
class ScheduleInsights {
  final int totalEvents;
  final String? busiestDay;
  final double averageEventsPerDay;
  final List<int> peakHours;
  final List<String> suggestions;

  ScheduleInsights({
    required this.totalEvents,
    this.busiestDay,
    required this.averageEventsPerDay,
    required this.peakHours,
    required this.suggestions,
  });
}
