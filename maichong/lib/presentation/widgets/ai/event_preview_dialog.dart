import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/services/ai_service.dart';
import '../../../data/services/smart_suggestions_service.dart';
import '../../../data/services/storage_service.dart';
import 'conflict_warning_widget.dart';

/// Dialog for previewing and confirming AI-extracted events
class EventPreviewDialog extends StatefulWidget {
  final EventPreview preview;
  final void Function(EventPreview preview) onConfirm;
  final void Function(EventPreview preview) onEdit;

  const EventPreviewDialog({
    super.key,
    required this.preview,
    required this.onConfirm,
    required this.onEdit,
  });

  @override
  State<EventPreviewDialog> createState() => _EventPreviewDialogState();
}

class _EventPreviewDialogState extends State<EventPreviewDialog> {
  final SmartSuggestionsService _suggestionsService = SmartSuggestionsService();
  List<ScheduleConflict> _conflicts = [];
  bool _isLoadingConflicts = true;
  bool _showConflicts = true;
  late EventPreview _preview;

  @override
  void initState() {
    super.initState();
    _preview = widget.preview;
    _checkConflicts();
  }

  Future<void> _checkConflicts() async {
    final events = await StorageService().eventRepository.getAllEvents();
    final potentialEvent = _preview.toEvent();

    final conflicts = _suggestionsService.detectConflicts(potentialEvent, events);

    if (mounted) {
      setState(() {
        _conflicts = conflicts;
        _isLoadingConflicts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _conflicts.any((c) => c.severity == ConflictSeverity.high)
                ? Icons.warning
                : Icons.event,
            color: _conflicts.any((c) => c.severity == ConflictSeverity.high)
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('确认事件'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _preview.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Time
            _buildInfoRow(
              context,
              Icons.access_time,
              '时间',
              _formatTimeRange(_preview.startTime, _preview.endTime),
            ),

            // Location
            if (_preview.location != null && _preview.location!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                Icons.location_on,
                '地点',
                _preview.location!,
              ),
            ],

            // Description
            if (_preview.description != null && _preview.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                Icons.description,
                '描述',
                _preview.description!,
              ),
            ],

            const SizedBox(height: 16),

            // AI info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI 已从你的描述中提取事件信息',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Conflict warnings
            if (_isLoadingConflicts)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_conflicts.isNotEmpty && _showConflicts) ...[
              const SizedBox(height: 16),
              ConflictWarningWidget(
                conflicts: _conflicts,
                onIgnore: () {
                  setState(() => _showConflicts = false);
                },
                onReschedule: () {
                  _showTimeSuggestions();
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => widget.onEdit(_preview),
          child: const Text('编辑'),
        ),
        FilledButton(
          onPressed: _conflicts.any((c) => c.severity == ConflictSeverity.high)
              ? null
              : () => widget.onConfirm(_preview),
          style: FilledButton.styleFrom(
            backgroundColor: _conflicts.any((c) => c.severity == ConflictSeverity.high)
                ? theme.colorScheme.surfaceContainerHighest
                : null,
          ),
          child: Text(_conflicts.any((c) => c.severity == ConflictSeverity.high)
              ? '存在冲突'
              : '确认创建'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimeRange(DateTime start, DateTime? end) {
    final formatter = DateFormat('M月d日 EEE HH:mm', 'zh_CN');
    final startStr = formatter.format(start);

    if (end != null) {
      final endStr = DateFormat('HH:mm').format(end);
      // If same day
      if (start.year == end.year && start.month == end.month && start.day == end.day) {
        return '$startStr - $endStr';
      }
      return '$startStr - ${formatter.format(end)}';
    }

    return startStr;
  }

  Future<void> _showTimeSuggestions() async {
    final events = await StorageService().eventRepository.getAllEvents();
    final duration = (_preview.endTime ?? _preview.startTime.add(const Duration(hours: 1)))
        .difference(_preview.startTime);

    final suggestions = _suggestionsService.getSuggestedTimeSlots(
      preferredDate: _preview.startTime,
      duration: duration,
      existingEvents: events,
      maxSuggestions: 5,
    );

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '鎺ㄨ崘鏃堕棿',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (suggestions.isEmpty)
                  Text(
                    '鏆傛棤鎺ㄨ崘锛岃鎵嬪姩淇敼鏃堕棿銆?',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  ...suggestions.map((s) {
                    final timeRange = _formatTimeRange(s.startTime, s.endTime);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(timeRange),
                      subtitle: Text(
                        s.reason,
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Text('${(s.confidence * 100).round()}%'),
                      onTap: () {
                        setState(() {
                          _preview = _preview.copyWith(
                            startTime: s.startTime,
                            endTime: s.endTime,
                          );
                          _showConflicts = true;
                          _isLoadingConflicts = true;
                        });
                        Navigator.of(context).pop();
                        _checkConflicts();
                      },
                    );
                  }),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('鍏抽棴'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
