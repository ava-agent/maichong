import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service for generating and managing share links
class ShareLinkService {
  /// Generate a unique invite link for a timeline
  String generateInviteLink({
    required String timelineId,
    required String timelineName,
  }) {
    // Generate a unique invite code
    final inviteCode = _generateInviteCode();

    // In production, this would be a real URL to your app
    // For now, we use a mock URL format
    return 'https://maichong.app/invite/$inviteCode?timeline=$timelineId';
  }

  /// Generate a short invite code (6 characters)
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No ambiguous chars
    final random = Random.secure();

    return List.generate(6, (index) {
      return chars[random.nextInt(chars.length)];
    }).join();
  }

  /// Parse an invite link to extract timeline ID and code
  Map<String, String>? parseInviteLink(String link) {
    // Mock parser for https://maichong.app/invite/CODE?timeline=ID
    final uri = Uri.tryParse(link);
    if (uri == null) return null;

    final pathSegments = uri.pathSegments;
    if (pathSegments.length < 2 || pathSegments[0] != 'invite') {
      return null;
    }

    final code = pathSegments[1];
    final timelineId = uri.queryParameters['timeline'];

    if (code.isEmpty || timelineId == null) {
      return null;
    }

    return {
      'code': code,
      'timelineId': timelineId,
    };
  }

  /// Copy invite link to clipboard
  Future<bool> copyInviteLinkToClipboard(BuildContext context, String link) async {
    try {
      await Clipboard.setData(ClipboardData(text: link));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('邀请链接已复制到剪贴板'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('复制失败: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  /// Validate an invite code format
  bool isValidInviteCode(String code) {
    if (code.length != 6) return false;

    // Check if all characters are valid
    const validChars = RegExp(r'^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]+$');
    return validChars.hasMatch(code);
  }
}

/// Data class for invite link information
class InviteLinkInfo {
  final String code;
  final String timelineId;
  final String timelineName;
  final DateTime createdAt;
  final int? maxUses;
  final int currentUses;

  InviteLinkInfo({
    required this.code,
    required this.timelineId,
    required this.timelineName,
    required this.createdAt,
    this.maxUses,
    this.currentUses = 0,
  });

  /// Check if the invite link has expired or reached max uses
  bool get isExpired {
    if (maxUses != null && currentUses >= maxUses!) {
      return true;
    }

    // Links expire after 30 days
    final expiryDate = createdAt.add(const Duration(days: 30));
    return DateTime.now().isAfter(expiryDate);
  }

  /// Get the full invite URL
  String get inviteUrl {
    return 'https://maichong.app/invite/$code?timeline=$timelineId';
  }

  InviteLinkInfo copyWith({
    String? code,
    String? timelineId,
    String? timelineName,
    DateTime? createdAt,
    int? maxUses,
    int? currentUses,
  }) {
    return InviteLinkInfo(
      code: code ?? this.code,
      timelineId: timelineId ?? this.timelineId,
      timelineName: timelineName ?? this.timelineName,
      createdAt: createdAt ?? this.createdAt,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
    );
  }
}
