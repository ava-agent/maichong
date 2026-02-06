import 'package:flutter/material.dart';

/// 脉冲应用颜色系统
/// 基于设计文档: docs/UI-UX设计规范.md
class AppColors {
  // 主色 - 脉冲紫
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // 辅助色 - 温暖橙
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFBBF24);

  // 语义色
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // 中性色
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray900 = Color(0xFF171717);

  // 语义颜色
  static const Color background = gray50;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray400;
  static const Color divider = gray200;
}

/// 事件颜色映射
class EventColors {
  static const Map<String, Color> colors = {
    'work': Color(0xFF6366F1),
    'personal': Color(0xFF10B981),
    'social': Color(0xFFF59E0B),
    'family': Color(0xFFEC4899),
    'health': Color(0xFF8B5CF6),
    'default': Color(0xFF6B7280),
  };

  static Color get(String key) => colors[key] ?? colors['default']!;
}
