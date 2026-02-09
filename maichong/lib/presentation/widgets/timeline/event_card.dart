import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/event.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 现代AI助手风格事件卡片
/// 参考豆包、千问等应用的卡片设计
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onLongPress,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getEventColor().withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: _getEventColor().withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Time indicator with gradient
                  _buildTimeIndicator(context),

                  const SizedBox(width: 14),

                  // Content
                  Expanded(
                    child: _buildContent(context),
                  ),

                  // Delete button
                  if (onDelete != null)
                    _buildDeleteButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeIndicator(BuildContext context) {
    final hour = event.startTime.hour;
    final isPM = hour >= 12;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getEventColor().withOpacity(0.95),
            _getEventColor().withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$displayHour',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            event.startTime.minute.toString().padLeft(2, '0'),
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          event.title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Time range
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 13,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              _formatTimeRange(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        // Location (if any)
        if (event.location != null && event.location!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 13,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.location!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // Description (if any)
        if (event.description != null && event.description!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            event.description!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.errorLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.error.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Color _getEventColor() {
    return EventColors.get(event.category ?? 'default');
  }

  String _formatTimeRange() {
    final start = DateFormat('HH:mm').format(event.startTime);
    final end = DateFormat('HH:mm').format(event.endTime);

    if (event.startTime.year == event.endTime.year &&
        event.startTime.month == event.endTime.month &&
        event.startTime.day == event.endTime.day) {
      return '$start - $end';
    }

    return '$start ${DateFormat('M月d日').format(event.endTime)} $end';
  }
}

// Helper function to parse color from string
Color _parseColor(String? hexColor) {
  if (hexColor == null || hexColor.isEmpty) {
    return AppColors.primary;
  }

  try {
    final color = hexColor!.replaceAll('#', '');
    if (color.length == 6) {
      return Color(int.parse('FF$color', radix: 16));
    } else if (color.length == 8) {
      return Color(int.parse(color, radix: 16));
    }
  } catch (_) {
    // Return default color if parsing fails
  }
  return AppColors.primary;
}

// Compact version for tight spaces
class EventCardCompact extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCardCompact({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _parseColor(event.color).withOpacity(0.12),
              _parseColor(event.color).withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _parseColor(event.color).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 28,
              decoration: BoxDecoration(
                color: _parseColor(event.color),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimeCompact(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeCompact() {
    final start = DateFormat('HH:mm').format(event.startTime);
    final end = DateFormat('HH:mm').format(event.endTime);
    return '$start - $end';
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return AppColors.primary;
    }

    try {
      final color = hexColor!.replaceAll('#', '');
      if (color.length == 6) {
        return Color(int.parse('FF$color', radix: 16));
      } else if (color.length == 8) {
        return Color(int.parse(color, radix: 16));
      }
    } catch (_) {
      return AppColors.primary;
    }
    return AppColors.primary;
  }
}
