# Implementation Plan: 脉冲项目 - Week 0 项目初始化

## Task Type
- [x] Frontend (Flutter Web)
- [ ] Backend (Supabase)
- [ ] Fullstack (Parallel)

---

## Overview

本文档详细规划"脉冲"项目的Week 0初始化阶段，包括Flutter项目创建、开发环境配置、基础架构搭建，以及Web平台的特定配置。

**目标**: 创建一个可运行的Flutter Web项目，具备完整的项目结构和开发环境。

**平台优先级**: Web (Chrome/Edge浏览器)

---

## Technical Solution

### 架构概述
- **前端**: Flutter 3.24+ Web版本
- **状态管理**: Riverpod 3.0+ (代码生成)
- **路由**: go_router 13.0+
- **本地存储**: Hive 2.2+ (Web支持)
- **后端集成**: Supabase Flutter 2.0+ (后续Week 2集成)
- **开发环境**: VS Code + Flutter扩展

### Web特定考虑
- 使用`flutter build web`生成可部署的静态文件
- 配置CORS策略（如果需要本地API测试）
- 使用`flutter run -d chrome`进行开发调试

---

## Implementation Steps

### Step 1: 环境准备 (预计30分钟)

**任务**: 检查并安装Flutter开发环境

**操作**:
```bash
# 1. 检查Flutter是否已安装
flutter --version

# 2. 如果未安装，下载并安装Flutter SDK
# 访问: https://docs.flutter.dev/get-started/install/windows

# 3. 验证安装
flutter doctor -v

# 4. 启用Web支持
flutter config --enable-web

# 5. 验证Web支持
flutter devices
# 应该看到 Chrome 和 Edge
```

**验收标准**:
- `flutter --version` 显示 3.24.0 或更高版本
- `flutter devices` 列出 Chrome 浏览器

---

### Step 2: 创建Flutter项目 (预计15分钟)

**任务**: 创建Flutter项目并配置基础依赖

**操作**:
```bash
# 1. 在项目根目录创建Flutter项目
flutter create maichong \
  --org com.maichong \
  --description "AI-native life rhythm coordination assistant" \
  --platforms web

# 2. 进入项目目录
cd maichong

# 3. 创建.gitignore (如果不存在)
cat > .gitignore << 'EOF'
# Misc
*.log
.env

# Flutter/Dart
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/

# IDE
.vscode/
.idea/

# macOS
.DS_Store
EOF

# 4. 验证项目可运行
flutter run -d chrome
# 应该在Chrome中显示Flutter计数器应用
```

**验收标准**:
- 项目创建成功，`maichong/`目录存在
- `flutter run -d chrome` 可在浏览器中运行

---

### Step 3: 配置pubspec.yaml依赖 (预计20分钟)

**任务**: 添加项目所需的所有依赖

**操作**: 编辑 `maichong/pubspec.yaml`

```yaml
name: maichong
description: AI-native life rhythm coordination assistant.
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  # Flutter SDK
  flutter:
    sdk: flutter

  # 状态管理
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

  # 路由
  go_router: ^14.0.0

  # 代码生成
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # 本地存储
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.0

  # 网络请求 (Week 2使用)
  dio: ^5.4.0

  # Supabase (Week 2使用)
  supabase_flutter: ^2.0.0

  # AI服务 (Week 3使用)
  openai_dart: ^1.0.0

  # UI工具
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0

  # 工具库
  intl: ^0.19.0
  uuid: ^4.0.0
  url_launcher: ^6.2.0

  # Web特定
  web: ^0.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # 代码生成
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.0.0

  # 代码质量
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

**安装依赖**:
```bash
flutter pub get
```

**验收标准**:
- `flutter pub get` 无错误
- 依赖安装成功

---

### Step 4: 创建项目目录结构 (预计15分钟)

**任务**: 创建符合Clean Architecture的目录结构

**操作**:
```bash
# 在 maichong/ 目录下执行

# 创建目录结构
mkdir -p lib/{core/{constants,theme,utils,config},data/{models,repositories,datasources},domain/{entities,usecases,repositories},presentation/{providers,pages,widgets,routes},services}

# 创建资源目录
mkdir -p assets/{images,icons,fonts}
mkdir -p test/{unit,widget,integration}

# 创建占位文件 (保持空目录在git中)
touch assets/images/.gitkeep
touch assets/icons/.gitkeep
touch assets/fonts/.gitkeep

# 验证目录结构
tree -L 3 lib/
```

**验收标准**:
- 所有目录创建成功
- 目录结构与技术架构文档一致

---

### Step 5: 配置主题和颜色系统 (预计30分钟)

**任务**: 创建应用的主题配置

**文件**: `lib/core/theme/app_colors.dart`

```dart
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
```

**文件**: `lib/core/theme/app_text_styles.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class FontSizes {
  static const double displayLarge = 32.0;
  static const double displayMedium = 28.0;
  static const double displaySmall = 24.0;
  static const double headlineLarge = 20.0;
  static const double headlineMedium = 18.0;
  static const double headlineSmall = 16.0;
  static const double titleLarge = 16.0;
  static const double titleMedium = 14.0;
  static const double titleSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 10.0;
}

class FontWeights {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: FontSizes.displayLarge,
    fontWeight: FontWeights.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: FontSizes.headlineMedium,
    fontWeight: FontWeights.semiBold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: FontSizes.bodyLarge,
    fontWeight: FontWeights.regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: FontSizes.bodyMedium,
    fontWeight: FontWeights.regular,
    color: AppColors.textSecondary,
  );
}
```

**文件**: `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.gray900,
    );
  }
}
```

**验收标准**:
- 主题文件创建成功
- 颜色值与设计文档一致

---

### Step 6: 配置路由系统 (预计30分钟)

**任务**: 设置go_router路由配置

**文件**: `lib/presentation/routes/app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../presentation/pages/timeline/timeline_page.dart';
import '../../presentation/pages/settings/settings_page.dart';

part 'app_router.g.dart';

enum AppRoute {
  timeline,
  settings,
}

@riverpod
GoRouter goRouter(_) {
  return GoRouter(
    initialLocation: '/',
    routes: $routes,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面未找到: ${state.uri}'),
      ),
    ),
  );
}

// 临时占位页面，后续会创建
class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的时间线')),
      body: const Center(child: Text('时间线页面 - 待实现')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: const Center(child: Text('设置页面 - 待实现')),
    );
  }
}
```

**验收标准**:
- 路由配置创建成功
- 代码生成后可编译

---

### Step 7: 创建应用入口和根组件 (预计20分钟)

**任务**: 创建main.dart和app.dart

**文件**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const app = ProviderScope(child: App());
  runApp(app);
}
```

**文件**: `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: '脉冲 - 生活节律协同助手',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
```

**验收标准**:
- 应用可以启动
- 显示初始路由页面

---

### Step 8: 创建基础UI组件 (预计45分钟)

**任务**: 创建可复用的基础组件

**文件**: `lib/presentation/widgets/common/app_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_button.g.dart';

enum AppButtonType { primary, secondary, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(text);

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: isFullWidth ? const Size.fromHeight(48) : null,
          ),
          child: child,
        );

      case AppButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: isFullWidth ? const Size.fromHeight(48) : null,
          ),
          child: child,
        );

      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }
  }
}
```

**文件**: `lib/presentation/widgets/common/app_input.dart`

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_input.g.dart';

class AppInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool isRequired;
  final String? errorText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const AppInput({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.obscureText = false,
    this.isRequired = false,
    this.errorText,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label! + (widget.isRequired ? ' *' : ''),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            errorText: widget.errorText,
            suffixIcon: widget.suffixIcon,
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
```

**验收标准**:
- 基础组件创建完成
- 组件可在页面中使用

---

### Step 9: 创建欢迎页面 (预计30分钟)

**任务**: 创建项目启动后的第一个页面

**文件**: `lib/presentation/pages/welcome_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../widgets/common/app_button.dart';

part 'welcome_page.g.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo/图标
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.pulse_2,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              // 标题
              Text(
                '脉冲',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '生活节律协同助手',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // 描述
              Text(
                '一个以AI为原生驱动的智能日程管理工具，'
                '帮助您和亲密伙伴更好地协调生活节奏。',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // 开始按钮
              AppButton(
                text: '开始使用',
                isFullWidth: true,
                onPressed: () => context.go('/timeline'),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: '了解更多',
                type: AppButtonType.secondary,
                isFullWidth: true,
                onPressed: () {
                  // 显示关于对话框
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('关于脉冲'),
                      content: const Text(
                        '脉冲是一款AI原生的生活节律协同助手，'
                        '通过智能时间线和自然语言交互，'
                        '让日程管理变得前所未有的简单和有趣。',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('关闭'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // 版本信息
              Text(
                'v0.1.0',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**更新路由**: 修改 `lib/presentation/routes/app_router.dart`

```dart
// 在initialLocation改为 '/welcome'
@riverpod
GoRouter goRouter(_) {
  return GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        name: AppRoute.welcome.name,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/timeline',
        name: AppRoute.timeline.name,
        builder: (context, state) => const TimelinePage(),
      ),
      GoRoute(
        path: '/settings',
        name: AppRoute.settings.name,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    // ... 其他配置
  );
}
```

**验收标准**:
- 欢迎页面显示正确
- 点击"开始使用"跳转到时间线页面
- 点击"了解更多"显示对话框

---

### Step 10: 运行代码生成和测试 (预计15分钟)

**任务**: 生成代码并运行应用验证

**操作**:
```bash
# 1. 生成Riverpod代码
flutter pub run build_runner build --delete-conflicting-outputs

# 2. 运行应用
flutter run -d chrome

# 3. 验证功能
# - 应该看到欢迎页面
# - 点击"开始使用"跳转到时间线
# - URL从 /welcome 变为 /timeline
```

**验收标准**:
- 代码生成无错误
- 应用在Chrome中运行正常
- 页面导航工作正常

---

### Step 11: Git提交 (预计10分钟)

**任务**: 提交初始代码到Git仓库

**操作**:
```bash
# 1. 添加所有文件
git add .

# 2. 查看更改
git status

# 3. 提交
git commit -m "feat: initialize Flutter project with basic structure

- Set up Flutter Web project
- Configure dependencies (Riverpod, go_router, Hive)
- Create Clean Architecture folder structure
- Implement theme system (colors, text styles)
- Set up routing with go_router
- Create base UI components (AppButton, AppInput)
- Add welcome page with navigation

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

# 4. 推送到远程
git push origin main
```

**验收标准**:
- 代码已提交到Git
- 提交信息符合规范

---

## Key Files

| File | Operation | Description |
|------|-----------|-------------|
| `pubspec.yaml` | Modify | 添加所有项目依赖 |
| `lib/main.dart` | Create | 应用入口 |
| `lib/app.dart` | Create | 根组件 |
| `lib/core/theme/app_colors.dart` | Create | 颜色系统 |
| `lib/core/theme/app_text_styles.dart` | Create | 字体样式 |
| `lib/core/theme/app_theme.dart` | Create | 主题配置 |
| `lib/presentation/routes/app_router.dart` | Create | 路由配置 |
| `lib/presentation/widgets/common/app_button.dart` | Create | 按钮组件 |
| `lib/presentation/widgets/common/app_input.dart` | Create | 输入框组件 |
| `lib/presentation/pages/welcome_page.dart` | Create | 欢迎页面 |

---

## Directory Structure

```
maichong/
├── lib/
│   ├── main.dart                      # 应用入口
│   ├── app.dart                       # 根组件
│   ├── core/                          # 核心层
│   │   └── theme/                     # 主题
│   │       ├── app_colors.dart
│   │       ├── app_text_styles.dart
│   │       └── app_theme.dart
│   ├── data/                          # 数据层 (后续)
│   ├── domain/                        # 领域层 (后续)
│   ├── presentation/                  # 展示层
│   │   ├── pages/
│   │   │   ├── welcome_page.dart
│   │   │   ├── timeline/
│   │   │   └── settings/
│   │   ├── widgets/
│   │   │   └── common/
│   │   │       ├── app_button.dart
│   │   │       └── app_input.dart
│   │   └── routes/
│   │       └── app_router.dart
│   └── services/                      # 服务层 (后续)
├── assets/                            # 资源文件
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/                              # 测试 (后续)
├── pubspec.yaml                       # 依赖配置
└── .gitignore
```

---

## Risks and Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Flutter未安装或版本过低 | High | High | 提供详细安装步骤，版本检查 |
| 代码生成失败 | Medium | Medium | 确保依赖版本兼容，清理缓存 |
| Web运行异常 | Low | Medium | 使用chrome -d参数，检查浏览器兼容性 |
| 路由配置错误 | Low | Low | 使用go_router强类型路由 |

---

## Next Steps (Week 1)

完成Week 0后，继续执行:

1. **创建数据模型** - Event, Timeline实体
2. **实现本地存储** - Hive集成
3. **开发时间线UI** - 核心视图
4. **实现事件CRUD** - 创建、编辑、删除

---

## SESSION_ID (for /ccg:execute use)

```
CODEX_SESSION: N/A (本地规划)
GEMINI_SESSION: N/A (本地规划)
```

---

**计划版本**: 1.0
**创建日期**: 2026年2月6日
**预计完成时间**: 3-4小时
