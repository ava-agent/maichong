# 脉冲 (MaiChong)

> AI 原生生活节律协同助手

## 🎯 项目概述

脉冲是一款基于 Flutter 开发的 AI 原生生活节律协同助手，通过自然语言交互帮助用户管理时间线事件。

### 核心特性

- **AI 原生交互**: 使用自然语言创建、修改、查询事件
- **视觉时间线**: 替代传统日历网格的直观时间线视图
- **实时协作**: 基于 Supabase 的多人时间线同步
- **现代设计**: 参考豆包、千问等 AI 应用的设计语言

## 🎨 设计系统

### 颜色方案

```
主色渐变: #6366F1 → #8B5CF6 → #EC4899
AI 助手:  #06B6D4 → #22D3EE
```

### 设计规范

- 卡片圆角: 20px
- 按钮圆角: 14-16px
- Material 3 设计规范
- 渐变背景优先

## 🚀 快速开始

### 前置要求

- Flutter SDK 3.24.5+
- Dart 3.5.4+

### 安装 Flutter

1. 下载 Flutter SDK: [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. 添加 Flutter 到 PATH
3. 运行 `flutter doctor` 验证安装
4. 启用 Web 支持: `flutter config --enable-web`

### 运行应用

```bash
# 方法 1: 使用启动脚本
start.bat

# 方法 2: 手动运行
flutter pub get
flutter run -d chrome --web-port 8082
```

访问: http://localhost:8082

### 设计预览

在浏览器中打开 `web_preview.html` 可查看设计系统预览。

## 📁 项目结构

```
lib/
├── core/           # 核心配置（主题、样式）
├── data/           # 数据层（服务、仓库）
│   ├── repositories/
│   └── services/
├── domain/         # 领域模型
│   └── models/
└── presentation/   # UI 层
    ├── pages/      # 页面
    └── widgets/    # 组件
```

## 🛠️ 开发指南

### 代码规范

- 遵循 Flutter 官方样式指南
- 使用 `flutter_lints` 进行代码检查
- 组件文件命名使用 `snake_case`
- 类名使用 `PascalCase`

### 运行测试

```bash
flutter test
```

### 分析代码

```bash
flutter analyze
```

## 📝 功能清单

### Week 1: 单人时间线 ✅
- [x] 时间线视图
- [x] 事件 CRUD
- [x] 本地存储 (Hive)

### Week 2: 云同步 ✅
- [x] Supabase 集成
- [x] 实时同步
- [x] 邀请协作
- [x] 时间线分享

### Week 3: AI 助手 ✅
- [x] 自然语言事件提取
- [x] AI 对话界面
- [x] 冲突检测
- [x] 智能建议

### 设计优化 ✅
- [x] 现代渐变系统
- [x] 动画过渡效果
- [x] 响应式布局
- [x] 深色模式支持

## 🔧 环境变量

```bash
# Supabase (可选，用于云同步)
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# AI 服务 (可选，用于完整 AI 功能)
DEEPSEEK_API_KEY=your_deepseek_key
# 或
OPENAI_API_KEY=your_openai_key
```

## 📄 许可证

MIT License

---

**版本**: 0.1.0
**最后更新**: 2026-02-08

## 文档

- [项目状态报告](PROJECT_STATUS.md)
- [设计更新日志](DESIGN_UPDATE.md)
- [产品规划](../产品规划/)
