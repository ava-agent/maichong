import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../domain/models/event.dart';

/// Service for sharing timeline events
class ShareService {
  /// Share timeline on web using Web Share API
  Future<bool> shareTimeline({
    required String title,
    required String description,
    required String url,
  }) async {
    try {
      // Check if Web Share API is supported
      if (html.window.navigator.containsKey('share')) {
        final shareData = html.ShareData(
          title: title,
          text: description,
          url: url,
        );
        await html.window.navigator.share!(shareData);
        return true;
      } else {
        // Fallback: copy to clipboard
        return await copyToClipboard(
          '$title\n$description\n$url',
        );
      }
    } catch (e) {
      debugPrint('Share failed: $e');
      return false;
    }
  }

  /// Copy text to clipboard
  Future<bool> copyToClipboard(String text) async {
    try {
      await html.window.navigator.clipboard?.writeText(text);
      return true;
    } catch (e) {
      debugPrint('Clipboard copy failed: $e');
      return false;
    }
  }

  /// Generate shareable text for events
  String generateEventsShareText(List<Event> events, {String? title}) {
    final buffer = StringBuffer();

    if (title != null) {
      buffer.writeln('📅 $title');
      buffer.writeln();
    }

    buffer.writeln('我的时间线安排：');
    buffer.writeln();

    // Group events by date
    final grouped = _groupEventsByDate(events);

    for (final entry in grouped.entries) {
      buffer.writeln('📌 ${entry.key}');
      for (final event in entry.value) {
        buffer.writeln('  • ${event.title} ${_formatTime(event.startTime)}');
        if (event.location != null) {
          buffer.writeln('    📍 ${event.location}');
        }
      }
      buffer.writeln();
    }

    buffer.writeln('——');
    buffer.writeln('来自脉冲 - AI原生生活节律协同助手');

    return buffer.toString();
  }

  /// Generate shareable image (screenshot functionality)
  /// Note: This is a simplified version for web
  Future<Uint8List?> captureTimelineAsImage(
    GlobalKey key, {
    double? pixelRatio,
  }) async {
    try {
      // This is a placeholder for screenshot functionality
      // In production, you would use a package like `screenshot` or `html2canvas`
      // For Flutter web, this requires additional setup

      debugPrint('Screenshot capture requested for key: ${key.toString()}');
      return null; // Placeholder - requires screenshot package
    } catch (e) {
      debugPrint('Screenshot failed: $e');
      return null;
    }
  }

  /// Download timeline as text file
  Future<bool> downloadAsFile(List<Event> events, String filename) async {
    try {
      final content = generateEventsShareText(events);
      final bytes = utf8.encode(content);
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

  /// Generate iCalendar file for events
  Future<bool> downloadAsIcs(List<Event> events, String filename) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('BEGIN:VCALENDAR');
      buffer.writeln('VERSION:2.0');
      buffer.writeln('PRODID:-//Pulse//CN');
      buffer.writeln('CALSCALE:GREGORIAN');
      buffer.writeln('METHOD:PUBLISH');

      for (final event in events) {
        buffer.writeln('BEGIN:VEVENT');
        buffer.writeln('DTSTART:${_formatIcsTime(event.startTime)}');
        buffer.writeln('DTEND:${_formatIcsTime(event.endTime)}');
        buffer.writeln('SUMMARY:${event.title}');
        if (event.description != null) {
          buffer.writeln('DESCRIPTION:${event.description}');
        }
        if (event.location != null) {
          buffer.writeln('LOCATION:${event.location}');
        }
        buffer.writeln('UID:${event.id}@pulse.app');
        buffer.writeln('END:VEVENT');
      }

      buffer.writeln('END:VCALENDAR');

      final bytes = utf8.encode(buffer.toString());
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
      debugPrint('ICS download failed: $e');
      return false;
    }
  }

  /// Share on social media (opens in new tab)
  void shareOnSocialMedia(String platform, {String? text, String? url}) {
    final encodedText = Uri.encodeComponent(text ?? '');
    final encodedUrl = Uri.encodeComponent(url ?? '');

    String shareUrl;

    switch (platform.toLowerCase()) {
      case 'weibo':
        shareUrl = 'https://service.weibo.com/share/share.php?title=$encodedText&url=$encodedUrl';
        break;
      case 'wechat':
        // WeChat doesn't have web share API
        // Show QR code or copy link instead
        copyToClipboard(text ?? url ?? '');
        return;
      case 'twitter':
        shareUrl = 'https://twitter.com/intent/tweet?text=$encodedText&url=$encodedUrl';
        break;
      case 'facebook':
        shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=$encodedUrl';
        break;
      default:
        return;
    }

    html.window.open(shareUrl, '_blank');
  }

  Map<String, List<Event>> _groupEventsByDate(List<Event> events) {
    final grouped = <String, List<Event>>{};

    for (final event in events) {
      final dateKey = _formatDateKey(event.startTime);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(event);
    }

    return grouped;
  }

  String _formatDateKey(DateTime date) {
    final today = DateTime.now();
    final eventDate = DateTime(date.year, date.month, date.day);
    final todayDate = DateTime(today.year, today.month, today.day);

    final diff = eventDate.difference(todayDate).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == -1) return '昨天';

    return '${date.month}月${date.day}日';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatIcsTime(DateTime time) {
    return '${time.year.toString().padLeft(4, '0')}'
           '${time.month.toString().padLeft(2, '0')}'
           '${time.day.toString().padLeft(2, '0')}'
           'T'
           '${time.hour.toString().padLeft(2, '0')}'
           '${time.minute.toString().padLeft(2, '0')}'
           '${time.second.toString().padLeft(2, '0')}';
  }
}

/// Represents a share option
class ShareOption {
  final String id;
  final String label;
  final IconData icon;
  final String? color;

  const ShareOption({
    required this.id,
    required this.label,
    required this.icon,
    this.color,
  });
}

/// Common share options
class ShareOptions {
  static const weibo = ShareOption(
    id: 'weibo',
    label: '微博',
    icon: Icons.wechat,
    color: '#E6162D',
  );

  static const wechat = ShareOption(
    id: 'wechat',
    label: '微信',
    icon: Icons.wechat,
    color: '#07C160',
  );

  static const copy = ShareOption(
    id: 'copy',
    label: '复制链接',
    icon: Icons.link,
  );

  static const download = ShareOption(
    id: 'download',
    label: '导出文本',
    icon: Icons.download,
  );

  static const ics = ShareOption(
    id: 'ics',
    label: '导出日历',
    icon: Icons.calendar_month,
  );

  static const more = ShareOption(
    id: 'more',
    label: '更多',
    icon: Icons.more_horiz,
  );

  static const standardOptions = [
    weibo,
    wechat,
    copy,
    download,
    ics,
    more,
  ];
}
