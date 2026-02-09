import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'dart:convert';
import '../domain/models/event.dart';

/// Service for capturing timeline as shareable image
class TimelineCaptureService {
  /// Generate shareable image data URL from timeline events
  Future<String?> generateTimelineImage({
    required List<Event> events,
    required String timelineName,
    ThemeData? theme,
  }) async {
    try {
      // Create an HTML canvas to draw the timeline
      final canvas = html.CanvasElement(width: 600, height: 800);
      final ctx = canvas.getContext('2d') as html.CanvasRenderingContext2D;

      // Background
      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(0, 0, 600, 800);

      // Draw header
      _drawHeader(ctx, timelineName);

      // Draw events
      _drawEvents(ctx, events);

      // Draw footer
      _drawFooter(ctx);

      // Convert to data URL
      final dataUrl = canvas.toDataURL('image/png');

      return dataUrl;
    } catch (e) {
      debugPrint('Failed to generate timeline image: $e');
      return null;
    }
  }

  void _drawHeader(html.CanvasRenderingContext2D ctx, String timelineName) {
    // Top gradient background
    final gradient = ctx.createLinearGradient(0, 0, 0, 200);
    gradient.addColorStop(0, '#6366f1');
    gradient.addColorStop(1, '#8b5cf6');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 600, 180);

    // Title
    ctx.fillStyle = '#FFFFFF';
    ctx.font = 'bold 32px system-ui, -apple-system, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(timelineName, 300, 80);

    // Subtitle
    ctx.font = '18px system-ui, -apple-system, sans-serif';
    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    final now = DateTime.now();
    final dateStr = '${now.year}年${now.month}月${now.day}日';
    ctx.fillText(dateStr, 300, 115);

    // Pulse icon (circle)
    ctx.beginPath();
    ctx.arc(300, 150, 8, 0, 6.28318);
    ctx.fillStyle = '#FFFFFF';
    ctx.fill();

    // Pulse rings
    ctx.beginPath();
    ctx.arc(300, 150, 16, 0, 6.28318);
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
    ctx.lineWidth = 2;
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(300, 150, 24, 0, 6.28318);
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.15)';
    ctx.stroke();
  }

  void _drawEvents(html.CanvasRenderingContext2D ctx, List<Event> events) {
    if (events.isEmpty) {
      ctx.fillStyle = '#6B7280';
      ctx.font = '18px system-ui, -apple-system, sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('暂无事件', 300, 300);
      return;
    }

    var yPosition = 230;

    // Group by date
    final grouped = <String, List<Event>>{};
    for (final event in events) {
      final dateKey = _formatDateKey(event.startTime);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(event);
    }

    // Draw up to 6 events
    int eventCount = 0;
    for (final entry in grouped.entries) {
      if (eventCount >= 6) break;

      // Date header
      ctx.fillStyle = '#6366f1';
      ctx.font = 'bold 16px system-ui, -apple-system, sans-serif';
      ctx.textAlign = 'left';
      ctx.fillText(entry.key, 60, yPosition);

      yPosition += 30;

      // Events for this date
      for (final event in entry.value) {
        if (eventCount >= 6) break;

        _drawEventCard(ctx, event, yPosition);
        yPosition += 85;
        eventCount++;
      }

      yPosition += 10;
    }

    if (events.length > 6) {
      ctx.fillStyle = '#9CA3AF';
      ctx.font = '14px system-ui, -apple-system, sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('还有 ${events.length - 6} 个事件...', 300, yPosition);
    }
  }

  void _drawEventCard(html.CanvasRenderingContext2D ctx, Event event, double y) {
    final x = 50.0;
    final width = 500.0;
    final height = 75.0;

    // Card background
    ctx.fillStyle = '#F3F4F6';
    _roundRect(ctx, x, y, width, height, 12);
    ctx.fill();

    // Time indicator (left)
    ctx.fillStyle = '#6366f1';
    _roundRect(ctx, x, y, 8, height, 12);
    ctx.fill();

    // Time text
    ctx.fillStyle = '#374151';
    ctx.font = 'bold 14px system-ui, -apple-system, sans-serif';
    ctx.textAlign = 'left';
    final timeStr = '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
    ctx.fillText(timeStr, x + 24, y + 28);

    // Event title
    ctx.fillStyle = '#111827';
    ctx.font = 'bold 16px system-ui, -apple-system, sans-serif';

    // Truncate title if too long
    var title = event.title;
    if (title.length > 20) {
      title = '${title.substring(0, 17)}...';
    }
    ctx.fillText(title, x + 24, y + 50);

    // Location (if any)
    if (event.location != null && event.location!.isNotEmpty) {
      ctx.fillStyle = '#6B7280';
      ctx.font = '12px system-ui, -apple-system, sans-serif';
      var location = event.location!;
      if (location.length > 35) {
        location = '${location.substring(0, 32)}...';
      }
      ctx.fillText('📍 $location', x + 24, y + 68);
    }
  }

  void _roundRect(html.CanvasRenderingContext2D ctx, double x, double y, double w, double h, double r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + w, y, x + w, y + h, r);
    ctx.arcTo(x + w, y + h, x, y + h, r);
    ctx.arcTo(x, y + h, x, y, r);
    ctx.arcTo(x, y, x + w, y, r);
    ctx.closePath();
  }

  void _drawFooter(html.CanvasRenderingContext2D ctx) {
    ctx.fillStyle = '#F3F4F6';
    ctx.fillRect(0, 750, 600, 50);

    ctx.fillStyle = '#6B7280';
    ctx.font = '12px system-ui, -apple-system, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText('由 脉冲 (Mài Chōng) 生成 - 同步每次脉冲', 300, 780);
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final eventDate = DateTime(date.year, date.month, date.day);
    final todayDate = DateTime(now.year, now.month, now.day);
    final diff = eventDate.difference(todayDate).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == -1) return '昨天';

    return '${date.month}月${date.day}日';
  }

  /// Download the generated image
  Future<bool> downloadImage(String dataUrl, String filename) async {
    try {
      // Convert data URL to blob
      final base64 = dataUrl.split(',').last;
      final bytes = base64Decode(base64);

      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement()
        ..href = url
        ..download = filename
        ..style.display = 'none';

      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      return true;
    } catch (e) {
      debugPrint('Download failed: $e');
      return false;
    }
  }

  /// Copy image to clipboard (if supported)
  Future<bool> copyToClipboard(String dataUrl) async {
    try {
      // Convert data URL to blob
      final base64 = dataUrl.split(',').last;
      final bytes = base64Decode(base64);

      final blob = html.Blob([bytes], type: 'image/png');

      final clipboardItem = html.ClipboardItem(
        {'image/png': blob}.jsify() as dynamic,
      );

      await html.window.navigator.clipboard?.write([clipboardItem]);

      return true;
    } catch (e) {
      debugPrint('Copy to clipboard failed: $e');
      return false;
    }
  }
}
