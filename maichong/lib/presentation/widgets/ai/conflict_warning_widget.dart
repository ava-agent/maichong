import 'package:flutter/material.dart';
import '../../../data/services/smart_suggestions_service.dart';

/// Widget for displaying schedule conflict warnings
class ConflictWarningWidget extends StatelessWidget {
  final List<ScheduleConflict> conflicts;
  final VoidCallback onIgnore;
  final VoidCallback onReschedule;

  const ConflictWarningWidget({
    super.key,
    required this.conflicts,
    required this.onIgnore,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (conflicts.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasHighSeverity = conflicts.any((c) => c.severity == ConflictSeverity.high);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasHighSeverity
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasHighSeverity
              ? theme.colorScheme.error.withOpacity(0.5)
              : theme.colorScheme.tertiary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasHighSeverity ? Icons.warning : Icons.info,
                color: hasHighSeverity
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                hasHighSeverity ? '时间冲突' : '潜在冲突',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasHighSeverity
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...conflicts.map((conflict) => _buildConflictItem(context, conflict)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onIgnore,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasHighSeverity
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onTertiaryContainer,
                  ),
                  child: const Text('忽略'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: onReschedule,
                  style: FilledButton.styleFrom(
                    backgroundColor: hasHighSeverity
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                  ),
                  child: const Text('重新安排'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConflictItem(BuildContext context, ScheduleConflict conflict) {
    final theme = Theme.of(context);
    final event = conflict.conflictingEvent;

    String conflictText;
    switch (conflict.conflictType) {
      case ConflictType.exactOverlap:
        conflictText = '同时开始';
        break;
      case ConflictType.contained:
        conflictText = '时间段包含';
        break;
      case ConflictType.partialOverlap:
        conflictText = '部分重叠';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: conflict.severity == ConflictSeverity.high
                  ? theme.colorScheme.error
                  : conflict.severity == ConflictSeverity.medium
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)} • $conflictText',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasHighSeverity(conflict)
                        ? theme.colorScheme.onErrorContainer.withOpacity(0.8)
                        : theme.colorScheme.onTertiaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool hasHighSeverity(ScheduleConflict conflict) {
    return conflict.severity == ConflictSeverity.high;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget for displaying schedule insights and suggestions
class ScheduleInsightsWidget extends StatelessWidget {
  final ScheduleInsights insights;
  final VoidCallback onViewAnalytics;

  const ScheduleInsightsWidget({
    super.key,
    required this.insights,
    required this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (insights.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '智能建议',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
          if (insights.busiestDay != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onViewAnalytics,
              icon: const Icon(Icons.analytics),
              label: Text('查看完整分析 (${insights.busiestDay}最忙碌)'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget for displaying time slot suggestions
class TimeSuggestionsWidget extends StatelessWidget {
  final List<TimeSuggestion> suggestions;
  final ValueChanged<TimeSuggestion> onSuggestionTap;

  const TimeSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '推荐时段',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: suggestions.map((suggestion) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _TimeSuggestionChip(
                  suggestion: suggestion,
                  onTap: () => onSuggestionTap(suggestion),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TimeSuggestionChip extends StatelessWidget {
  final TimeSuggestion suggestion;
  final VoidCallback onTap;

  const _TimeSuggestionChip({
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final confidenceColor = suggestion.confidence > 0.7
        ? theme.colorScheme.primary
        : suggestion.confidence > 0.4
            ? theme.colorScheme.tertiary
            : theme.colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: confidenceColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: confidenceColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_formatTime(suggestion.startTime)} - ${_formatTime(suggestion.endTime)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              suggestion.reason,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (suggestion.conflicts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning,
                    size: 12,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${suggestion.conflicts.length} 个冲突',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
