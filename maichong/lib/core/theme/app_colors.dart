import 'package:flutter/material.dart';

/// 现代AI助手风格颜色系统
/// 参考豆包、千问等AI应用的设计语言
class AppColors {
  // 主色渐变 - 科技紫到蓝
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryContainer = Color(0xFFE0E7FF);

  // 渐变色系
  static const Color gradientStart = Color(0xFF6366F1); // 紫色
  static const Color gradientMiddle = Color(0xFF8B5CF6); // 紫罗兰
  static const Color gradientEnd = Color(0xFFEC4899); // 粉色

  // AI助手专属色 - 智能青
  static const Color aiPrimary = Color(0xFF06B6D4);
  static const Color aiSecondary = Color(0xFF22D3EE);
  static const Color aiAccent = Color(0xFF67E8F9);

  // 辅助色 - 温暖橙
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryLight = Color(0xFFFBBF24);

  // 语义色 - 现代化
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // 背景色系 - 柔和现代
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = Color(0xFFF3F4F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);

  // 文字色系 - 高对比度
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFFCBD5E1);

  // 中性色
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // 分割线和边框
  static const Color divider = Color(0xFFE2E8F0);
  static const Color outline = Color(0xFFCBD5E1);

  // 阴影色
  static const Color shadow = Color(0x0A000000);
  static const Color shadowLight = Color(0x05000000);

  // 渐变定义
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMiddle, gradientEnd],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [aiPrimary, aiSecondary],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
  );
}

/// 事件颜色映射 - 更鲜艳现代
class EventColors {
  static const Map<String, Color> colors = {
    'work': Color(0xFF6366F1),      // 靛蓝
    'personal': Color(0xFF10B981),   // 翠绿
    'social': Color(0xFFF97316),     // 橙色
    'family': Color(0xFFEC4899),     // 粉色
    'health': Color(0xFF06B6D4),     // 青色
    'learning': Color(0xFF8B5CF6),   // 紫色
    'entertainment': Color(0xFFF43F5E), // 玫红
    'default': Color(0xFF6366F1),
  };

  static Color get(String key) => colors[key] ?? colors['default']!;

  /// 获取事件卡片的渐变色
  static LinearGradient getGradient(String key) {
    final color = get(key);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color,
        color.withOpacity(0.7),
      ],
    );
  }
}
