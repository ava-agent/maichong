# 脉冲项目 - UI/UX设计规范

**版本**: 1.0
**更新日期**: 2026年2月6日

---

## 目录

1. [设计原则](#设计原则)
2. [颜色系统](#颜色系统)
3. [字体系统](#字体系统)
4. [间距系统](#间距系统)
5. [组件规范](#组件规范)
6. [页面规范](#页面规范)
7. [动画规范](#动画规范)
8. [响应式设计](#响应式设计)

---

## 设计原则

### 核心价值

| 原则 | 描述 | 示例 |
|------|------|------|
| **简洁** | 去除一切不必要的元素 | 最小化UI，突出内容 |
| **直观** | 操作符合用户直觉 | 手势自然，反馈及时 |
| **情感化** | 设计传递温暖感 | 圆润的形状，柔和的色彩 |
| **一致性** | 统一的视觉语言 | 所有页面遵循相同规则 |

### 设计关键词

- **流动**: 时间线如水流般自然
- **脉冲**: 节奏感，能量传递
- **连接**: 人与人，时间与生活的连接
- **温暖**: 亲密关系的温度

---

## 颜色系统

### 主色调

基于"脉冲"概念的活力色彩系统。

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // 主色 - 脉冲紫 (代表能量、活力)
  static const Color primary = Color(0xFF6366F1);      // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5);  // Indigo 600

  // 辅助色 - 温暖橙 (代表亲密、温暖)
  static const Color secondary = Color(0xFFF59E0B);    // Amber 500
  static const Color secondaryLight = Color(0xFFFBBF24); // Amber 400

  // 成功色
  static const Color success = Color(0xFF10B981);      // Emerald 500

  // 警告色
  static const Color warning = Color(0xFFF59E0B);      // Amber 500

  // 错误色
  static const Color error = Color(0xFFEF4444);        // Red 500

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
}
```

### 语义色

```dart
class SemanticColors {
  // 背景色
  static const Color background = Color(0xFFFAFAFA);     // gray50
  static const Color surface = Color(0xFFFFFFFF);        // 白色
  static const Color surfaceVariant = Color(0xFFF5F5F5); // gray100

  // 文字色
  static const Color textPrimary = Color(0xFF171717);    // gray900
  static const Color textSecondary = Color(0xFF525252);  // gray600
  static const Color textTertiary = Color(0xFFA3A3A3);   // gray400
  static const Color textInverse = Color(0xFFFFFFFF);

  // 分割线
  static const Color divider = Color(0xFFE5E5E5);       // gray200

  // 叠加层
  static const Color overlay = Color(0x80000000);       // 50% 黑色
  static const Color focus = Color(0x806366F1);         // 50% 主色
}
```

### 事件颜色

```dart
class EventColors {
  static const Map<String, Color> colors = {
    'work': Color(0xFF6366F1),      // 蓝色 - 工作
    'personal': Color(0xFF10B981),  // 绿色 - 个人
    'social': Color(0xFFF59E0B),    // 橙色 - 社交
    'family': Color(0xFFEC4899),    // 粉色 - 家庭
    'health': Color(0xFF8B5CF6),    // 紫色 - 健康
    'default': Color(0xFF6B7280),   // 灰色 - 默认
  };

  static Color get(String key) => colors[key] ?? colors['default']!;
}
```

### 暗色模式

```dart
class DarkColors {
  static const Color background = Color(0xFF171717);    // gray900
  static const Color surface = Color(0xFF262626);       // gray800
  static const Color surfaceVariant = Color(0xFF404040); // gray700

  static const Color textPrimary = Color(0xFFFAFAFA);   // gray50
  static const Color textSecondary = Color(0xFFD4D4D4); // gray300
  static const Color textTertiary = Color(0xFFA3A3A3);  // gray400

  static const Color divider = Color(0xFF404040);       // gray700
}
```

---

## 字体系统

### 字体家族

```dart
class AppFonts {
  // 主字体 - Inter (现代、清晰)
  static const String primary = 'Inter';

  // 代码字体 - JetBrains Mono
  static const String mono = 'JetBrainsMono';
}
```

### 字体大小

```dart
class FontSizes {
  static const double displayLarge = 32.0;   // H1
  static const double displayMedium = 28.0;  // H2
  static const double displaySmall = 24.0;   // H3

  static const double headlineLarge = 20.0;  // H4
  static const double headlineMedium = 18.0;
  static const double headlineSmall = 16.0;

  static const double titleLarge = 16.0;     // 标题
  static const double titleMedium = 14.0;
  static const double titleSmall = 12.0;

  static const double bodyLarge = 16.0;      // 正文
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;

  static const double labelLarge = 14.0;     // 标签
  static const double labelMedium = 12.0;
  static const double labelSmall = 10.0;
}
```

### 字重

```dart
class FontWeights {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
```

### 文本样式

```dart
class AppTextStyles {
  // 显示文字
  static const TextStyle displayLarge = TextStyle(
    fontSize: FontSizes.displayLarge,
    fontWeight: FontWeights.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: FontSizes.displayMedium,
    fontWeight: FontWeights.bold,
    letterSpacing: -0.25,
  );

  // 标题
  static const TextStyle headlineLarge = TextStyle(
    fontSize: FontSizes.headlineLarge,
    fontWeight: FontWeights.semiBold,
  );

  // 正文
  static const TextStyle bodyLarge = TextStyle(
    fontSize: FontSizes.bodyLarge,
    fontWeight: FontWeights.regular,
    height: 1.5,
  );

  // 标签
  static const TextStyle labelMedium = TextStyle(
    fontSize: FontSizes.labelMedium,
    fontWeight: FontWeights.medium,
    letterSpacing: 0.5,
  );
}
```

---

## 间距系统

使用8px基准网格。

```dart
class Spacing {
  static const double unit = 8.0;

  static const double xs = 0.5 * unit;   // 4px
  static const double sm = 1 * unit;     // 8px
  static const double md = 2 * unit;     // 16px
  static const double lg = 3 * unit;     // 24px
  static const double xl = 4 * unit;     // 32px
  static const double xxl = 6 * unit;    // 48px
  static const double xxxl = 8 * unit;   // 64px
}
```

### 内边距

```dart
class Padding {
  static const double allSmall = Spacing.sm;
  static const double allMedium = Spacing.md;
  static const double allLarge = Spacing.lg;

  // 卡片内边距
  static const double card = Spacing.md;
  // 按钮内边距
  static const double buttonVertical = 12.0;
  static const double buttonHorizontal = Spacing.lg;
}
```

---

## 组件规范

### 按钮

#### 主按钮 (Primary Button)

```dart
AppButton(
  text: '创建事件',
  onPressed: () {},
  type: AppButtonType.primary,
)
```

**样式规范**:
- 高度: 44px
- 圆角: 12px
- 字体: 14px Medium
- 内边距: 12px 24px
- 主色背景，白色文字

#### 次要按钮 (Secondary Button)

- 透明背景，主色边框
- 主色文字

#### 文字按钮 (Text Button)

- 透明背景
- 主色文字
- 无内边距，仅左右间距

### 输入框

```dart
AppInput(
  label: '事件标题',
  placeholder: '输入事件标题',
  onChanged: (value) {},
)
```

**样式规范**:
- 高度: 48px
- 圆角: 8px
- 边框: 1px gray200
- 标签: 12px, 灰色
- 输入文字: 14px
- 内边距: 12px 16px

**状态**:
- 默认: 灰色边框
- 聚焦: 主色边框 (2px)
- 错误: 红色边框 + 错误提示
- 禁用: 灰色背景

### 卡片

```dart
EventCard(
  event: event,
  onTap: () {},
)
```

**样式规范**:
- 圆角: 16px
- 内边距: 16px
- 背景色: 白色
- 阴影: 0 1px 3px rgba(0,0,0,0.1)
- 左侧色条: 4px宽，事件颜色

### 聊天气泡

**用户气泡**:
- 右对齐
- 主色背景
- 白色文字
- 圆角: 右下角直角，其他12px

**AI气泡**:
- 左对齐
- gray100背景
- 灰色文字
- 圆角: 左下角直角，其他12px

---

## 页面规范

### 时间线页面 (TimelinePage)

```
┌────────────────────────────────────┐
│ ← 我的时间线        +  筛选       │  AppBar
├────────────────────────────────────┤
│                                    │
│  今天 2月6日                       │  日期分组
│  ┌────────────────────────────┐   │
│  │ ▌ 团队会议                 │   │  事件卡片
│  │ 🕐 14:00 - 15:00           │   │
│  │ 📍 会议室A                 │   │
│  └────────────────────────────┘   │
│                                    │
│  明天 2月7日                       │
│  ┌────────────────────────────┐   │
│  │ ▌ 咖啡约会                 │   │
│  │ 🕐 15:00 - 16:00           │   │
│  └────────────────────────────┘   │
│                                    │
└────────────────────────────────────┘
│        [+]                         │  FAB
└────────────────────────────────────┘
```

### AI聊天页面 (AIChatPage)

```
┌────────────────────────────────────┐
│ ← AI助手                   ⚙️     │  AppBar
├────────────────────────────────────┤
│                                    │
│     💬 想创建什么事件？            │  AI欢迎消息
│                                    │
│     "明天下午3点开会"              │
│     "和客户午餐"                   │  建议快捷回复
│     "这周末有什么安排"             │
│                                    │
│ ┌────────────────────────────┐    │
│ │ 明天下午3点和小明喝咖啡    │    │  用户消息
│ │                    14:30   │    │  (右侧)
│ └────────────────────────────┘    │
│                                    │
│ ┌────────────────────────────┐    │
│ │ 好的，我来帮你创建事件     │    │  AI消息
│ │ 📅 明天 15:00-16:00        │    │  (左侧)
│ │ ☕ 和小明喝咖啡             │    │
│ │ ┌──────────┬──────────┐    │    │
│ │ │ 确认创建 │  编辑    │    │
│ └────────────────────────────┘    │
│                                    │
├────────────────────────────────────┤
│ [📎]  输入消息...          [发送] │  输入框
└────────────────────────────────────┘
```

### 创建事件页面 (CreateEventPage)

```
┌────────────────────────────────────┐
│ ← 创建事件              取消 | 保存 │  AppBar
├────────────────────────────────────┤
│                                    │
│  事件标题 *                        │
│  ┌────────────────────────────┐   │
│  │ 团队会议                    │   │  输入框
│  └────────────────────────────┘   │
│                                    │
│  时间 *                            │
│  ┌─────────────┬─────────────┐   │
│  │  2月10日    │   14:00     │   │  时间选择
│  ├─────────────┼─────────────┤   │
│  │  至         │   15:00     │   │
│  └─────────────┴─────────────┘   │
│  □ 全天事件                        │
│                                    │
│  地点                              │
│  ┌────────────────────────────┐   │
│  │ 会议室A        📍          │   │
│  └────────────────────────────┘   │
│                                    │
│  描述                              │
│  ┌────────────────────────────┐   │
│  │ 讨论Q1季度计划              │   │  多行输入
│  │                             │   │
│  └────────────────────────────┘   │
│                                    │
│  颜色                              │
│  ○ ● ○ ○ ○ ○                     │  颜色选择器
│                                    │
└────────────────────────────────────┘
```

---

## 动画规范

### 动画时长

```dart
class Durations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 500);
}
```

### 动画曲线

```dart
class Curves {
  static const Curve defaultCurve = Cubic(0.4, 0.0, 0.2, 1.0); // easeInOut
  static const Curve enter = Cubic(0.0, 0.0, 0.2, 1.0);      // easeOut
  static const Curve exit = Cubic(0.4, 0.0, 1.0, 1.0);       // easeIn
}
```

### 页面转场

```dart
// 淡入淡出
pageBuilder: (context, animation, secondaryAnimation) {
  return FadeTransition(
    opacity: animation,
    child: const NextPage(),
  );
}

// 滑动进入
pageBuilder: (context, animation, secondaryAnimation) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  final tween = Tween(begin: begin, end: end);
  final curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  );
  return SlideTransition(
    position: tween.animate(curvedAnimation),
    child: const NextPage(),
  );
}
```

### 微交互动画

```dart
// 按钮点击缩放
onTapDown: (_) => setState(() => scale = 0.95),
onTapUp: (_) => setState(() => scale = 1.0),
onTapCancel: () => setState(() => scale = 1.0),

// 卡片进入动画
AnimatedContainer(
  duration: Durations.normal,
  curve: Curves.easeInOut,
  transform: Matrix4.identity()..scale(isVisible ? 1.0 : 0.8),
  opacity: isVisible ? 1.0 : 0.0,
  child: EventCard(event: event),
)
```

### 加载动画

```dart
// 使用标准进度指示器
const CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
  strokeWidth: 3,
)

// 脉冲动画 (适合AI思考状态)
PulseAnimation(
  child: Icon(Icons.smart_toy, color: AppColors.primary),
)
```

---

## 响应式设计

### 断点

```dart
class Breakpoints {
  static const double mobile = 375;   // 小屏手机
  static const double tablet = 768;   // 平板
  static const double desktop = 1024; // 桌面
}
```

### 自适应布局

```dart
// 根据屏幕宽度调整布局
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.tablet) {
      return MobileLayout();
    } else if (width < Breakpoints.desktop) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  }
}
```

### 字体缩放

```dart
// 支持系统字体缩放
Text(
  '标题',
  style: TextStyle(
    fontSize: 16.scaleSp, // 根据系统设置缩放
  ),
)
```

---

## 可访问性

### 最小触控尺寸

```dart
class MinTouchTarget {
  static const double size = 44.0; // iOS标准
}
```

### 颜色对比度

- 正文文字: 至少4.5:1
- 大文字(18px+): 至少3:1
- UI组件: 至少3:1

### 语义标签

```dart
Semantics(
  label: '创建新事件',
  button: true,
  child: FloatingActionButton(
    onPressed: _createEvent,
    child: const Icon(Icons.add),
  ),
)
```

---

## 设计资产

### 图标

使用Material Icons，补充自定义SVG图标。

```dart
// 常用图标
class AppIcons {
  static const IconData add = Icons.add;
  static const IconData event = Icons.event;
  static const IconData smartToy = Icons.smart_toy;
  static const IconData location = Icons.location_on;
  static const IconData time = Icons.access_time;
  static const IconData share = Icons.share;
}
```

### 插图

- 空状态插图
- 错误状态插图
- 欢迎插图
- 引导页插图

---

**文档版本**: 1.0
**最后更新**: 2026年2月6日
**参考文件**: `设计稿1/`, `设计稿2_交互稿/`
