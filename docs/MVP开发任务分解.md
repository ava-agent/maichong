# 脉冲项目 - MVP开发任务分解

> **注意**: 此文档为早期规划阶段编写。MVP 已完成并部署至 https://maichong.vercel.app 。
> 实际实现采用 Vanilla JS + Vite（而非 Flutter），但任务分解逻辑仍有参考价值。

**基于**: 脉冲-行动计划.md 中的3周MVP计划
**版本**: 1.0 (早期规划)
**更新日期**: 2026年2月6日

---

## 任务说明

本文档将3周MVP计划分解为具体的、可执行的开发任务。

### 任务优先级定义
- **P0 (必须)**: MVP核心功能，阻塞其他任务
- **P1 (重要)**: 主要功能，影响用户体验
- **P2 (可选)**: 优化项，可延后

### 任务状态标识
- [ ] 待开始
- [x] 已完成
- [~] 进行中
- [!] 被阻塞

---

## Week 1: 单机脉冲 - 可视化时间线

### 第1-2天: 项目基础结构

#### 1.1 项目初始化 (P0)
- [ ] 创建Flutter项目 `flutter create maichong`
- [ ] 配置pubspec.yaml依赖清单
  - [ ] flutter_riverpod (状态管理)
  - [ ] go_router (路由)
  - [ ] supabase_flutter (后端集成)
  - [ ] freezed + json_serializable (代码生成)
  - [ ] hive (本地存储)
- [ ] 创建目录结构
  - [ ] core/ (核心配置)
  - [ ] data/ (数据层)
  - [ ] domain/ (领域层)
  - [ ] presentation/ (展示层)
  - [ ] services/ (服务层)
- [ ] 配置主题和颜色系统
- [ ] 配置路由系统

**验收标准**: 项目可运行，显示欢迎页面

#### 1.2 本地数据模型 (P0)
- [ ] 定义Event数据模型
  ```dart
  class Event {
    String id;
    String title;
    String? description;
    DateTime startTime;
    DateTime endTime;
    String? location;
    String color;
  }
  ```
- [ ] 定义Timeline数据模型
- [ ] 创建Hive本地存储适配器
- [ ] 实现EventRepository本地实现
- [ ] 编写数据模型单元测试

**验收标准**: 可创建、读取、更新、删除本地事件

#### 1.3 基础UI组件 (P0)
- [ ] 创建AppScaffold (统一页面框架)
- [ ] 创建AppButton组件
- [ ] 创建AppInput组件
- [ ] 创建LoadingOverlay组件
- [ ] 创建DatePicker组件
- [ ] 创建TimePicker组件

**验收标准**: 组件库文档完整，Storybook演示

---

### 第3-4天: 时间线视图

#### 1.4 时间线核心视图 (P0)
- [ ] 创建TimelineView页面
- [ ] 实现垂直滚动时间轴
- [ ] 实现日期分组显示
- [ ] 创建EventCard组件
  - [ ] 标题显示
  - [ ] 时间范围显示
  - [ ] 地点显示
  - [ ] 颜色标识
- [ ] 实现空状态提示
- [ ] 添加下拉刷新
- [ ] 添加无限滚动 (分页加载历史事件)

**验收标准**: 时间线可滚动，正确显示事件

#### 1.5 事件创建/编辑功能 (P0)
- [ ] 创建CreateEventDialog
- [ ] 实现表单验证
  - [ ] 标题非空
  - [ ] 结束时间晚于开始时间
- [ ] 实现时间选择器
- [ ] 实现颜色选择器
- [ ] 创建EditEventPage
- [ ] 实现事件更新逻辑
- [ ] 添加删除确认对话框

**验收标准**: 可创建、编辑、删除事件，数据持久化到本地

---

### 第5天: 导航和交互

#### 1.6 应用导航 (P0)
- [ ] 定义路由表
  - [ ] /timeline - 时间线主页
  - [ ] /event/create - 创建事件
  - [ ] /event/edit/:id - 编辑事件
  - [ ] /settings - 设置页面
- [ ] 实现底部导航栏
  - [ ] 时间线Tab
  - [ ] 设置Tab
- [ ] 实现页面转场动画

**验收标准**: 可在页面间导航，状态保持

#### 1.7 设置页面 (P1)
- [ ] 创建SettingsPage
- [ ] 实现主题切换 (亮色/暗色)
- [ ] 实现数据清除功能
- [ ] 显示应用信息

**验收标准**: 设置功能可用

---

## Week 2: 协作脉冲 - 实时同步

### 第6-7天: Supabase集成

#### 2.1 Supabase项目配置 (P0)
- [ ] 创建Supabase项目
- [ ] 执行数据库迁移
  - [ ] 创建users表
  - [ ] 创建timelines表
  - [ ] 创建events表
  - [ ] 创建timeline_members表
- [ ] 配置Row Level Security (RLS)
  - [ ] 定义访问策略
  - [ ] 测试权限控制
- [ ] 在Flutter中初始化Supabase

**验收标准**: Supabase连接成功，可执行基础查询

#### 2.2 用户认证系统 (P0)
- [ ] 创建LoginPage
- [ ] 创建RegisterPage
- [ ] 实现邮箱注册
- [ ] 实现邮箱登录
- [ ] 实现邮箱验证流程
- [ ] 实现忘记密码
- [ ] 实现登出功能
- [ ] 创建AuthProvider (Riverpod)
- [ ] 实现认证状态持久化

**验收标准**: 用户可注册、登录、登出

---

### 第8-9天: 数据同步

#### 2.3 Repository层重构 (P0)
- [ ] 创建Repository接口定义
- [ ] 实现TimelineRepository
  - [ ] getTimelines() - 获取用户的时间线列表
  - [ ] createTimeline() - 创建时间线
  - [ ] updateTimeline() - 更新时间线
  - [ ] deleteTimeline() - 删除时间线
- [ ] 实现EventRepository
  - [ ] getEvents(timelineId) - 获取时间线的事件
  - [ ] createEvent() - 创建事件
  - [ ] updateEvent() - 更新事件
  - [ ] deleteEvent() - 删除事件
- [ ] 实现本地缓存策略
  - [ ] 先读本地，再同步远程
  - [ ] 乐观更新
  - [ ] 错误回滚

**验收标准**: 数据可读写，有缓存机制

#### 2.4 实时同步 (P0)
- [ ] 配置Supabase Realtime
  - [ ] 启用表的Replication
  - [ ] 配置订阅频道
- [ ] 实现RealtimeService
  - [ ] subscribeToTimeline(timelineId)
  - [ ] subscribeToEvents(timelineId)
  - [ ] 自动重连机制
- [ ] 集成到TimelineProvider
- [ ] 添加同步状态指示器
- [ ] 处理冲突解决 (Last-Write-Wins)

**验收标准**: 多客户端修改实时同步

---

### 第10天: 协作功能

#### 2.5 时间线成员管理 (P0)
- [ ] 创建TimelineMembersPage
- [ ] 实现成员列表显示
- [ ] 实现角色显示 (owner, admin, member)
- [ ] 创建InviteDialog (生成邀请链接)
- [ ] 创建JoinTimelinePage (通过链接加入)
- [ ] 实现移除成员功能 (仅owner)
- [ ] 创建InvitationRepository

**验收标准**: 可邀请成员、显示成员、移除成员

#### 2.6 用户资料 (P1)
- [ ] 创建UserProfilePage
- [ ] 实现头像上传 (Supabase Storage)
- [ ] 实现昵称编辑
- [ ] 显示加入的时间线列表

**验收标准**: 用户可管理个人资料

---

## Week 3: 智能脉冲 - AI助手

### 第11-12天: AI对话界面

#### 3.1 AI聊天UI (P0)
- [ ] 创建AIChatPage
- [ ] 创建ChatBubble组件
  - [ ] 用户消息样式
  - [ ] AI消息样式
  - [ ] 打字动画效果
- [ ] 创建ChatInput组件
  - [ ] 文本输入框
  - [ ] 发送按钮
  - [ ] 语音输入按钮 (占位)
- [ ] 实现消息列表滚动
- [ ] 添加建议快捷回复
- [ ] 创建ChatHistory本地存储

**验收标准**: 可发送消息，显示对话历史

#### 3.2 AI服务集成 (P0)
- [ ] 配置DeepSeek/OpenAI API
- [ ] 创建AIService
  - [ ] parseSchedule() - 解析自然语言为事件
  - [ ] chat() - 通用对话
- [ ] 实现流式响应 (SSE)
- [ ] 添加错误处理和重试
- [ ] 实现速率限制
- [ ] 创建AIProvider (Riverpod)

**验收标准**: AI可响应，解析结果正确

---

### 第13-14天: 智能功能

#### 3.3 自然语言创建事件 (P0)
- [ ] 设计Prompt工程
  - [ ] 事件提取
  - [ ] 时间识别
  - [ ] 地点识别
- [ ] 实现结果预览UI
  - [ ] 显示解析后的事件
  - [ ] 确认/取消按钮
  - [ ] 编辑功能
- [ ] 处理边界情况
  - [ ] 时间模糊 ("明天下午")
  - [ ] 相对时间 ("3天后")
  - [ ] 多事件 ("周五看电影, 周六吃饭")
- [ ] 添加示例引导
  - [ ] "明天下午3点和小明喝咖啡"
  - [ ] "下周五晚上7点生日派对"

**验收标准**: 自然语言可正确转换为事件

#### 3.4 AI辅助功能 (P1)
- [ ] 智能建议
  - [ ] 空闲时间推荐
  - [ ] 事件冲突提醒
- [ ] 快捷操作
  - [ ] "今天有什么安排?"
  - [ ] "这周空闲时间"
- [ ] 事件相关操作
  - [ ] "取消明天下午的会议"
  - [ ] "把周五的聚会改到周六"

**验收标准**: AI可理解复杂指令

---

### 第15天: 分享功能 (基础版本)

#### 3.5 分享图片生成 (P0)
- [ ] 创建ShareService
- [ ] 实现时间线截图
  - [ ] 使用flutter screenshot
  - [ ] 或使用repaintboundary
- [ ] 创建分享预览页
- [ ] 添加分享模板
  - [ ] 默认模板
  - [ ] 精简模板
- [ ] 集成平台分享
  - [ ] Android: share_plus
  - [ ] iOS: UIActivityViewController

**验收标准**: 可生成并分享时间线图片

---

## 补充任务 (按需插入)

### 测试任务
- [ ] 为每个Repository编写单元测试
- [ ] 为每个Provider编写单元测试
- [ ] 为关键Widget编写Widget测试
- [ ] 编写端到端测试 (集成测试)
- [ ] 目标测试覆盖率: 70%+

### 文档任务
- [ ] 编写API文档
- [ ] 编写组件使用文档
- [ ] 编写部署文档

### 优化任务 (P2)
- [ ] 添加启动画面
- [ ] 添加引导页
- [ ] 优化动画性能
- [ ] 减少包体积
- [ ] 添加错误日志收集

---

## 里程碑检查点

### Week 1结束检查
- [ ] 可在本地创建、编辑、删除事件
- [ ] 时间线正确显示
- [ ] 数据持久化到本地
- [ ] 通过所有单元测试

### Week 2结束检查
- [ ] 用户可注册、登录
- [ ] 可创建和加入共享时间线
- [ ] 多人修改实时同步
- [ ] 数据安全(RLS)配置正确

### Week 3结束检查
- [ ] AI可解析自然语言创建事件
- [ ] 对话体验流畅
- [ ] 可生成分享图片
- [ ] MVP功能完整

---

## 任务依赖关系图

```
Week 1:
项目初始化 → 数据模型 → UI组件
       ↓
    时间线视图 → 事件CRUD → 导航

Week 2:
Supabase配置 → 用户认证 → Repository重构
       ↓
    实时同步 ← ← ← ← ← ← ← ←
       ↓
    成员管理

Week 3:
AI聊天UI → AI服务集成 → 智能解析
       ↓
    分享功能
```

---

## 风险和缓解措施

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| Supabase实时不稳定 | 同步功能受影响 | 降级到手动刷新 |
| AI解析准确率低 | 用户体验差 | 添加编辑步骤兜底 |
| 开发进度延误 | MVP无法按时完成 | 砍掉P2任务 |
| 跨平台兼容问题 | 特定平台体验差 | 优先支持Web和Android |

---

## 开发规范

### Git提交规范
```
feat: 新功能
fix: 修复bug
refactor: 重构
test: 测试
docs: 文档
chore: 构建/工具

示例: feat(timeline): 实现事件创建功能
```

### 分支策略
- `main` - 生产代码
- `develop` - 开发主分支
- `feature/*` - 功能分支
- `fix/*` - 修复分支

### Code Review
- 所有代码需要PR合并
- 至少一人审核
- 通过CI检查

---

## 资源分配建议

| 角色 | 人数 | 主要职责 |
|------|------|----------|
| 前端开发 | 2 | UI/业务逻辑 |
| 后端集成 | 1 | Supabase/AI集成 |
| 测试 | 1 | 编写测试用例 |
| 设计 | 1 | UI设计支持 |

---

**文档版本**: 1.0
**最后更新**: 2026年2月6日
**负责人**: 开发团队
