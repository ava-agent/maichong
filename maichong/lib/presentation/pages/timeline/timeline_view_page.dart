import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/event_sync_service.dart';
import '../../../domain/models/event.dart';
import '../../widgets/timeline/event_card.dart';

class TimelineViewPage extends StatefulWidget {
  const TimelineViewPage({super.key});

  @override
  State<TimelineViewPage> createState() => _TimelineViewPageState();
}

class _TimelineViewPageState extends State<TimelineViewPage> {
  bool _isLoading = true;
  bool _isSyncing = false;
  List<Event> _events = [];
  Map<String, List<Event>> _eventsByDate = {};
  EventSyncService? _syncService;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _setupRealtimeSync();
  }

  @override
  void dispose() {
    _syncService?.unsubscribe();
    super.dispose();
  }

  void _setupRealtimeSync() {
    // Only setup if Supabase is configured
    if (!SupabaseService().isInitialized) {
      debugPrint('Supabase not configured, running in local-only mode');
      return;
    }

    _syncService = EventSyncService(
      onEventCreated: (event) {
        _handleRemoteEventChange('created', event);
      },
      onEventUpdated: (event) {
        _handleRemoteEventChange('updated', event);
      },
      onEventDeleted: (eventId) {
        _handleRemoteEventDeletion(eventId);
      },
    );

    try {
      _syncService!.subscribeToAllEvents();
    } catch (e) {
      // Fall back to local-only if sync fails
      debugPrint('Realtime sync failed: $e');
    }
  }

  void _handleRemoteEventChange(String type, Event event) {
    setState(() {
      // Remove existing event with same ID if exists
      _events.removeWhere((e) => e.id == event.id);

      // Add or update the event
      _events.add(event);

      // Re-sort and group
      _events.sort((a, b) => b.startTime.compareTo(a.startTime));
      _eventsByDate = _groupEventsByDate(_events);
    });
  }

  void _handleRemoteEventDeletion(String eventId) {
    setState(() {
      _events.removeWhere((e) => e.id == eventId);
      _eventsByDate = _groupEventsByDate(_events);
    });
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final events = await StorageService().eventRepository.getAllEvents();
      setState(() {
        _events = events;
        _eventsByDate = _groupEventsByDate(events);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载事件失败: $e')),
        );
      }
    }
  }

  Map<String, List<Event>> _groupEventsByDate(List<Event> events) {
    final grouped = <String, List<Event>>{};

    for (final event in events) {
      final dateKey = _getDateKey(event.startTime);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(event);
    }

    // Sort events within each date by start time
    for (final dateEvents in grouped.values) {
      dateEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return grouped;
  }

  String _getDateKey(DateTime date) {
    final today = DateTime.now();
    final eventDate = DateTime(date.year, date.month, date.day);
    final todayDate = DateTime(today.year, today.month, today.day);

    final diff = eventDate.difference(todayDate).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == -1) return '昨天';
    if (diff > 1 && diff < 7) return '${diff}天后';
    if (diff < -1 && diff > -7) return '${-diff}天前';

    return '${date.month}月${date.day}日';
  }

  void _handleDeleteEvent(Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除事件'),
        content: Text('确定要删除 "${event.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSyncing = true);
      try {
        await StorageService().eventRepository.deleteEvent(event.id);
        await _loadEvents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('事件已删除')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      } finally {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '还没有事件',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击 + 按钮创建你的第一个事件',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Sync indicator
    final syncIndicator = _isSyncing
        ? Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '同步中...',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: _eventsByDate.keys.length,
            itemBuilder: (context, index) {
              final dateKey = _eventsByDate.keys.elementAt(index);
              final dateEvents = _eventsByDate[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                    child: Text(
                      dateKey,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  // Events for this date
                  ...dateEvents.map((event) => EventCard(
                        event: event,
                        onDelete: () => _handleDeleteEvent(event),
                      )),
                  // Date divider
                  if (index < _eventsByDate.keys.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        syncIndicator,
      ],
    );
  }
}
