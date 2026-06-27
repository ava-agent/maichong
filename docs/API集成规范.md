# 脉冲项目 - API集成规范

> **注意**: 此文档为早期 Flutter 版本规划文档。实际项目已采用 **Vanilla JS + Vite** 实现。
> API 交互模式（Supabase CRUD、实时订阅、AI 聊天）仍然适用，但代码示例已过时。
> 请参考实际代码 `src/services/` 和 [技术架构设计](技术架构设计.md) 了解当前实现。

**版本**: 1.0 (早期规划)
**更新日期**: 2026年2月6日

---

## 目录

1. [架构概述](#架构概述)
2. [认证API](#认证api)
3. [时间线API](#时间线api)
4. [事件API](#事件api)
5. [成员管理API](#成员管理api)
6. [邀请API](#邀请api)
7. [AI服务API](#ai服务api)
8. [实时订阅](#实时订阅)
9. [错误处理](#错误处理)
10. [最佳实践](#最佳实践)

---

## 架构概述

### API分类

脉冲项目使用两类API:

| 类型 | 描述 | 示例 |
|------|------|------|
| **Supabase API** | 数据库CRUD操作 | 查询、创建、更新事件 |
| **外部API** | 第三方服务 | DeepSeek/OpenAI LLM |

### 通信方式

```
Flutter App
    │
    ├─► Supabase Client ──► Supabase Cloud (PostgreSQL)
    │
    └─► HTTP Client (Dio) ──► DeepSeek API
```

---

## 认证API

### Supabase Auth

Supabase提供内置认证服务，使用JWT Token。

#### 1. 注册

```dart
Future<AuthResponse> signUp(String email, String password) async {
  final response = await supabase.auth.signUp(
    email: email,
    password: password,
  );
  return response;
}
```

**请求**:
- `email`: string (邮箱)
- `password`: string (密码，最少6位)

**响应**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "email_confirmed_at": null
  }
}
```

#### 2. 登录

```dart
Future<AuthResponse> signIn(String email, String password) async {
  final response = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  return response;
}
```

**请求**:
- `email`: string
- `password`: string

**响应**: 同注册响应

#### 3. 登出

```dart
Future<void> signOut() async {
  await supabase.auth.signOut();
}
```

#### 4. 获取当前用户

```dart
User? get currentUser => supabase.auth.currentUser;
```

#### 5. 监听认证状态

```dart
StreamSubscription<AuthState> authSubscription;

void listenAuthState() {
  authSubscription = supabase.auth.onAuthStateChange.listen((data) {
    final AuthState event = data;
    final Session? session = event.session;
    // 处理认证状态变化
  });
}

@override
void dispose() {
  authSubscription.cancel();
}
```

---

## 时间线API

### 获取用户的时间线列表

```dart
Future<List<Timeline>> getTimelines() async {
  final userId = supabase.auth.currentUser!.id;

  final response = await supabase
      .from('timeline_members')
      .select('*, timelines(*)')
      .eq('user_id', userId);

  return response.map((json) => Timeline.fromJson(json)).toList();
}
```

**SQL等价查询**:
```sql
SELECT t.*, tm.role
FROM timelines t
JOIN timeline_members tm ON t.id = tm.timeline_id
WHERE tm.user_id = 'current_user_id'
ORDER BY t.updated_at DESC;
```

### 创建时间线

```dart
Future<Timeline> createTimeline(CreateTimelineDto dto) async {
  final response = await supabase
      .from('timelines')
      .insert({
        'title': dto.title,
        'description': dto.description,
        'owner_id': supabase.auth.currentUser!.id,
      })
      .select()
      .single();

  // 自动添加创建者为owner
  await supabase.from('timeline_members').insert({
    'timeline_id': response['id'],
    'user_id': supabase.auth.currentUser!.id,
    'role': 'owner',
  });

  return Timeline.fromJson(response);
}
```

**请求体**:
```json
{
  "title": "我的时间线",
  "description": "家庭日程安排",
  "is_public": false
}
```

### 更新时间线

```dart
Future<Timeline> updateTimeline(String id, UpdateTimelineDto dto) async {
  final response = await supabase
      .from('timelines')
      .update(dto.toJson())
      .eq('id', id)
      .select()
      .single();

  return Timeline.fromJson(response);
}
```

### 删除时间线

```dart
Future<void> deleteTimeline(String id) async {
  await supabase.from('timelines').delete().eq('id', id);
}
```

---

## 事件API

### 获取时间线的事件

```dart
Future<List<Event>> getEvents(String timelineId, {DateTime? since}) async {
  final query = supabase
      .from('events')
      .select()
      .eq('timeline_id', timelineId)
      .order('start_time', ascending: true);

  if (since != null) {
    query.gte('start_time', since.toIso8601String());
  }

  final response = await query;
  return response.map((json) => Event.fromJson(json)).toList();
}
```

**参数**:
- `timelineId`: string (时间线ID)
- `since`: DateTime? (可选，获取此时间之后的事件)

### 创建事件

```dart
Future<Event> createEvent(CreateEventDto dto) async {
  final response = await supabase
      .from('events')
      .insert({
        'timeline_id': dto.timelineId,
        'creator_id': supabase.auth.currentUser!.id,
        'title': dto.title,
        'description': dto.description,
        'start_time': dto.startTime.toIso8601String(),
        'end_time': dto.endTime.toIso8601String(),
        'location': dto.location,
        'is_all_day': dto.isAllDay,
        'color': dto.color ?? '#6366f1',
      })
      .select()
      .single();

  return Event.fromJson(response);
}
```

**请求体**:
```json
{
  "timeline_id": "uuid",
  "title": "团队会议",
  "description": "讨论Q1计划",
  "start_time": "2026-02-10T14:00:00Z",
  "end_time": "2026-02-10T15:00:00Z",
  "location": "会议室A",
  "is_all_day": false,
  "color": "#6366f1"
}
```

### 更新事件

```dart
Future<Event> updateEvent(String id, UpdateEventDto dto) async {
  final response = await supabase
      .from('events')
      .update(dto.toJson())
      .eq('id', id)
      .select()
      .single();

  return Event.fromJson(response);
}
```

### 删除事件

```dart
Future<void> deleteEvent(String id) async {
  await supabase.from('events').delete().eq('id', id);
}
```

---

## 成员管理API

### 获取时间线成员

```dart
Future<List<TimelineMember>> getMembers(String timelineId) async {
  final response = await supabase
      .from('timeline_members')
      .select('*, users!inner(email, display_name, avatar_url)')
      .eq('timeline_id', timelineId);

  return response.map((json) => TimelineMember.fromJson(json)).toList();
}
```

**响应**:
```json
[
  {
    "id": "member-uuid",
    "timeline_id": "timeline-uuid",
    "user_id": "user-uuid",
    "role": "owner",
    "joined_at": "2026-02-01T00:00:00Z",
    "users": {
      "email": "owner@example.com",
      "display_name": "组织者",
      "avatar_url": "https://..."
    }
  }
]
```

### 移除成员

```dart
Future<void> removeMember(String timelineId, String userId) async {
  await supabase
      .from('timeline_members')
      .delete()
      .eq('timeline_id', timelineId)
      .eq('user_id', userId);
}
```

### 更新成员角色

```dart
Future<void> updateMemberRole(String timelineId, String userId, String role) async {
  await supabase
      .from('timeline_members')
      .update({'role': role})
      .eq('timeline_id', timelineId)
      .eq('user_id', userId);
}
```

---

## 邀请API

### 创建邀请

```dart
Future<String> createInvite(String timelineId, {int? maxUses, DateTime? expiresAt}) async {
  final token = _generateInviteToken();

  await supabase.from('invitations').insert({
    'timeline_id': timelineId,
    'invite_token': token,
    'created_by': supabase.auth.currentUser!.id,
    'max_uses': maxUses ?? 1,
    'expires_at': expiresAt?.toIso8601String(),
  });

  // 生成分享链接
  final inviteUrl = 'maichong://join?token=$token';
  return inviteUrl;
}

String _generateInviteToken() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (i) => random.nextInt(256));
  return base64Url.encode(bytes);
}
```

### 验证并加入时间线

```dart
Future<Timeline> joinTimeline(String token) async {
  // 查询邀请
  final inviteResponse = await supabase
      .from('invitations')
      .select('*')
      .eq('invite_token', token)
      .single();

  final invite = Invitation.fromJson(inviteResponse);

  // 检查有效性
  if (invite.expiresAt != null && DateTime.now().isAfter(invite.expiresAt!)) {
    throw Exception('邀请已过期');
  }
  if (invite.usedCount >= invite.maxUses) {
    throw Exception('邀请已达使用上限');
  }

  // 添加成员
  await supabase.from('timeline_members').insert({
    'timeline_id': invite.timelineId,
    'user_id': supabase.auth.currentUser!.id,
    'role': 'member',
  });

  // 更新使用次数
  await supabase
      .from('invitations')
      .update({'used_count': invite.usedCount + 1})
      .eq('id', invite.id);

  // 返回时间线
  final timelineResponse = await supabase
      .from('timelines')
      .select()
      .eq('id', invite.timelineId)
      .single();

  return Timeline.fromJson(timelineResponse);
}
```

---

## AI服务API

### DeepSeek API

#### 配置

```dart
class AIService {
  final Dio _dio = Dio();
  final String apiKey;
  final String baseUrl = 'https://api.deepseek.com/v1';

  AIService(this.apiKey) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }
}
```

#### 解析日程

```dart
Future<ScheduleParseResult> parseSchedule(String userInput) async {
  final prompt = _buildParsePrompt(userInput);

  final response = await _dio.post(
    '/chat/completions',
    data: {
      'model': 'deepseek-chat',
      'messages': [
        {
          'role': 'system',
          'content': _getSystemPrompt(),
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'temperature': 0.3,
    },
  );

  final content = response.data['choices'][0]['message']['content'];
  return ScheduleParseResult.fromJson(jsonDecode(content));
}

String _getSystemPrompt() {
  return '''
你是一个智能日程助手。你的任务是将用户的自然语言输入解析为结构化的日程事件。

请严格按照JSON格式返回，包含以下字段:
- title: 事件标题 (string, 必需)
- startTime: 开始时间 (string, ISO8601格式, 必需)
- endTime: 结束时间 (string, ISO8601格式, 必需)
- location: 地点 (string, 可选)
- description: 描述 (string, 可选)

时间处理规则:
- "明天" 指明天
- "后天" 指后天
- "下周五" 指下一个周五
- "下午3点" 按24小时制处理为 15:00
- 相对时间如"3天后" 从当前时间计算

如果无法确定某些信息，请根据上下文合理推断。
''';
}
```

**请求示例**:
```json
{
  "model": "deepseek-chat",
  "messages": [
    {
      "role": "system",
      "content": "..."
    },
    {
      "role": "user",
      "content": "明天下午3点和小明在星巴克喝咖啡"
    }
  ],
  "temperature": 0.3
}
```

不要默认依赖 provider-specific 结构化输出请求字段。不同 OpenAI-compatible provider
对结构化输出支持不完全一致；生产实现应在 system prompt 中明确“只返回 JSON”，并在服务端
去除 Markdown code fence、提取首个 JSON object 后再做字段校验。

**响应示例**:
```json
{
  "choices": [{
    "message": {
      "content": "{\"title\":\"和小明喝咖啡\",\"startTime\":\"2026-02-07T15:00:00+08:00\",\"endTime\":\"2026-02-07T16:00:00+08:00\",\"location\":\"星巴克\",\"description\":\"\"}"
    }
  }],
  "usage": {
    "prompt_tokens": 150,
    "completion_tokens": 50,
    "total_tokens": 200
  }
}
```

#### 流式响应 (可选)

```dart
Stream<String> chatStream(String message) async* {
  final response = await _dio.post(
    '/chat/completions',
    data: {
      'model': 'deepseek-chat',
      'messages': [
        {'role': 'user', 'content': message}
      ],
      'stream': true,
    },
    options: Options(responseType: ResponseType.stream),
  );

  await for (final data in response.data.stream) {
    final lines = utf8.decode(data).split('\n');
    for (final line in lines) {
      if (line.startsWith('data: ')) {
        final content = line.substring(6);
        if (content == '[DONE]') return;
        final json = jsonDecode(content);
        final delta = json['choices'][0]['delta']['content'];
        if (delta != null) yield delta;
      }
    }
  }
}
```

---

## 实时订阅

### Supabase Realtime

使用WebSocket实现实时数据同步。

#### 订阅时间线更新

```dart
class RealtimeService {
  final SupabaseClient _client;
  final Ref _ref;
  RealtimeChannel? _timelineChannel;

  void subscribeToTimeline(String timelineId) {
    _timelineChannel = _client.channel("timeline:$timelineId");

    _timelineChannel!.on(
      RealtimeListenEventType.postgres_changes,
      ChannelFilter(
        event: '*',  // INSERT, UPDATE, DELETE
        schema: 'public',
        table: 'events',
        filter: 'timeline_id=eq.$timelineId',
      ),
      (payload, [ref]) {
        final eventType = payload['eventType'];
        final newRecord = payload['new'];
        final oldRecord = payload['old'];

        switch (eventType) {
          case 'INSERT':
            _ref.read(timelineEventsProvider.notifier).addEvent(
                  Event.fromJson(newRecord),
                );
            break;
          case 'UPDATE':
            _ref.read(timelineEventsProvider.notifier).updateEvent(
                  Event.fromJson(newRecord),
                );
            break;
          case 'DELETE':
            _ref.read(timelineEventsProvider.notifier).removeEvent(
                  oldRecord['id'],
                );
            break;
        }
      },
    ).subscribe();
  }

  void unsubscribe() {
    _timelineChannel?.unsubscribe();
    _timelineChannel = null;
  }
}
```

#### 订阅成员变化

```dart
void subscribeToMembers(String timelineId) {
  final channel = _client.channel("members:$timelineId");

  channel.on(
    RealtimeListenEventType.postgres_changes,
    ChannelFilter(
      event: '*',
      schema: 'public',
      table: 'timeline_members',
      filter: 'timeline_id=eq.$timelineId',
    ),
    (payload, [ref]) {
      // 处理成员变化
      final eventType = payload['eventType'];
      if (eventType == 'INSERT') {
        // 新成员加入 - 显示通知
      } else if (eventType == 'DELETE') {
        // 成员离开
      }
    },
  ).subscribe();
}
```

#### 处理连接状态

```dart
void subscribeWithStatus(String timelineId) {
  final channel = _client.channel("timeline:$timelineId")
    .onPostgresChanges(...)
    .subscribe((status, [error]) {
      switch (status) {
        case RealtimeSubscribeStatus.subscribed:
          // 连接成功
          debugPrint('实时连接已建立');
          break;
        case RealtimeSubscribeStatus.closed:
          // 连接关闭
          debugPrint('实时连接已关闭');
          break;
        case RealtimeSubscribeStatus.channelError:
          // 连接错误
          debugPrint('实时连接错误: $error');
          break;
      }
    });
}
```

---

## 错误处理

### 统一错误处理

```dart
class ApiClient {
  Future<T> request<T>(
    Future<Response> Function() requestFn,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await requestFn();
      return parser(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on PostgrestException catch (e) {
      throw _handleSupabaseError(e);
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('请求超时，请检查网络连接');
      case DioExceptionType.connectionError:
        return NetworkException('网络连接失败，请检查网络设置');
      case DioExceptionType.badResponse:
        return _handleHttpError(error.response!);
      default:
        return UnknownError(error.message ?? '未知错误');
    }
  }

  ApiException _handleHttpError(Response response) {
    switch (response.statusCode) {
      case 400:
        return BadRequestException('请求参数错误: ${response.data}');
      case 401:
        return UnauthorizedException('未授权，请重新登录');
      case 403:
        return ForbiddenException('无权限访问');
      case 404:
        return NotFoundException('资源不存在');
      case 429:
        return RateLimitException('请求过于频繁，请稍后再试');
      case 500:
        return ServerException('服务器错误，请稍后再试');
      default:
        return UnknownError('HTTP ${response.statusCode}: ${response.data}');
    }
  }

  ApiException _handleSupabaseError(PostgrestException error) {
    if (error.code == 'PGRST116') {
      return NotFoundException('资源不存在');
    }
    if (error.message.contains('duplicate key')) {
      return ConflictException('数据已存在');
    }
    return UnknownError(error.message);
  }
}

// 异常类定义
abstract class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class NetworkException extends ApiException {}
class TimeoutException extends ApiException {}
class BadRequestException extends ApiException {}
class UnauthorizedException extends ApiException {}
class ForbiddenException extends ApiException {}
class NotFoundException extends ApiException {}
class RateLimitException extends ApiException {}
class ServerException extends ApiException {}
class ConflictException extends ApiException {}
class UnknownError extends ApiException {}
```

### 使用示例

```dart
final apiClient = ApiClient();

try {
  final events = await apiClient.request(
    () => supabase.from('events').select(),
    (data) => (data as List).map((e) => Event.fromJson(e)).toList(),
  );
  // 处理成功
} on UnauthorizedException {
  // 跳转到登录页
  context.go('/login');
} on NetworkException catch (e) {
  // 显示网络错误提示
  showSnackBar(context, e.message);
} catch (e) {
  // 处理其他错误
  showSnackBar(context, '操作失败: $e');
}
```

---

## 最佳实践

### 1. 请求缓存

```dart
class CachedTimelineRepository {
  final TimelineRepository _remote;
  final TimelineRepository _local;

  Future<List<Event>> getEvents(String timelineId) async {
    // 先读取本地缓存
    final cached = await _local.getEvents(timelineId);
    if (cached.isNotEmpty) {
      // 异步更新缓存
      _updateCache(timelineId);
      return cached;
    }

    // 缓存为空，从远程获取
    final events = await _remote.getEvents(timelineId);
    await _local.saveEvents(timelineId, events);
    return events;
  }

  Future<void> _updateCache(String timelineId) async {
    try {
      final events = await _remote.getEvents(timelineId);
      await _local.saveEvents(timelineId, events);
    } catch (e) {
      // 静默失败
    }
  }
}
```

### 2. 乐观更新

```dart
Future<Event> createEvent(CreateEventDto dto) async {
  // 1. 立即更新UI
  final tempEvent = Event.temp(
    title: dto.title,
    startTime: dto.startTime,
    endTime: dto.endTime,
  );
  _ref.read(eventsProvider.notifier).addEvent(tempEvent);

  try {
    // 2. 发送API请求
    final event = await _apiClient.createEvent(dto);
    // 3. 替换临时数据
    _ref.read(eventsProvider.notifier).replaceEvent(tempEvent.id, event);
    return event;
  } catch (e) {
    // 4. 失败时回滚
    _ref.read(eventsProvider.notifier).removeEvent(tempEvent.id);
    rethrow;
  }
}
```

### 3. 重试策略

```dart
Future<T> withRetry<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(delay * attempt);
    }
  }
  throw StateError('unreachable');
}
```

### 4. 请求取消

```dart
class TimelineProvider {
  CancelToken? _cancelToken;

  Future<void> loadEvents() async {
    // 取消之前的请求
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    state = const AsyncValue.loading();

    try {
      final events = await _repository.getEvents(
        timelineId,
        cancelToken: _cancelToken,
      );
      state = AsyncValue.data(events);
    } catch (e, s) {
      if (!e is CancelException) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }
}
```

---

**文档版本**: 1.0
**最后更新**: 2026年2月6日
