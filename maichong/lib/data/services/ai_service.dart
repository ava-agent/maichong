import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/models/event.dart';

/// AI Service for natural language processing and event creation
/// Supports DeepSeek and OpenAI APIs
class AIService {
  static const String _deepSeekBaseUrl = 'https://api.deepseek.com/v1';
  static const String _openAIBaseUrl = 'https://api.openai.com/v1';

  String? _apiKey;
  String _provider = 'deepseek'; // 'deepseek' or 'openai'
  bool _isInitialized = false;

  /// Get the base URL based on provider
  String get _baseUrl => _provider == 'openai' ? _openAIBaseUrl : _deepSeekBaseUrl;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized && _apiKey != null && _apiKey!.isNotEmpty;

  /// Initialize the AI service with API key
  /// Returns true if initialization successful
  Future<bool> init() async {
    // For now, check environment variable or use placeholder
    // In production, this would read from secure storage or environment
    _apiKey = const String.fromEnvironment('DEEPSEEK_API_KEY',
      defaultValue: '',
    );

    // Try OpenAI key as fallback
    if (_apiKey!.isEmpty) {
      _apiKey = const String.fromEnvironment('OPENAI_API_KEY',
        defaultValue: '',
      );
      if (_apiKey!.isNotEmpty) {
        _provider = 'openai';
      }
    }

    _isInitialized = _apiKey!.isNotEmpty;
    return _isInitialized;
  }

  /// Parse natural language input to extract event information
  /// Returns a map with extracted event data
  Future<EventExtractionResult> extractEventFromText(String userInput) async {
    if (!isInitialized) {
      throw Exception('AI service not initialized. Please configure API key.');
    }

    final systemPrompt = _buildEventExtractionPrompt();
    final response = await _chat(userInput, systemPrompt: systemPrompt);

    return _parseEventResponse(response);
  }

  /// Generate AI response for general chat
  Future<String> generateChatResponse(String userMessage, {List<Event>? userEvents}) async {
    if (!isInitialized) {
      throw Exception('AI service not initialized. Please configure API key.');
    }

    String systemPrompt = '''你是脉冲（Mài Chōng），一个AI原生的生活节奏协调助手。

你的职责：
1. 帮助用户创建、修改、删除事件
2. 回答关于用户时间线的问题
3. 提供智能的时间安排建议

回复风格：
- 友好、简洁、专业
- 使用中文
- 当需要更多信息时，明确询问
- 如果检测到事件创建意图，引导用户提供完整信息

当前用户的事件数量：${userEvents?.length ?? 0}''';

    return await _chat(userMessage, systemPrompt: systemPrompt);
  }

  /// Send chat completion request to API
  Future<String> _chat(String userMessage, {required String systemPrompt}) async {
    final dio = Dio();
    final response = await dio.post(
      '$_baseUrl/chat/completions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
      ),
      data: {
        'model': _provider == 'openai' ? 'gpt-4o-mini' : 'deepseek-chat',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': 0.7,
        'max_tokens': 1000,
      },
    );

    if (response.statusCode == 200) {
      return response.data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('AI API error: ${response.statusCode} - ${response.data}');
    }
  }

  /// Build the system prompt for event extraction
  String _buildEventExtractionPrompt() {
    return '''你是事件提取专家。分析用户的自然语言输入，提取事件信息。

返回格式（JSON）：
{
  "is_event_related": true/false,
  "title": "事件标题",
  "description": "详细描述（可选）",
  "start_time": "ISO 8601格式或相对时间描述",
  "end_time": "ISO 8601格式或持续时间",
  "location": "地点（可选）",
  "confidence": 0.0-1.0,
  "missing_fields": ["字段名列表"],
  "clarifying_questions": ["需要询问的问题"]
}

规则：
- 如果不是事件相关，is_event_related设为false
- 时间可以是"明天下午3点"这样的相对时间
- 如果信息不完整，在missing_fields中列出
- 提供clarifying_questions来询问缺失信息
- confidence表示提取信息的置信度

示例：
输入："明天下午3点和小明喝咖啡"
输出：{
  "is_event_related": true,
  "title": "和小明喝咖啡",
  "start_time": "明天15:00",
  "end_time": "明天16:00",
  "location": null,
  "confidence": 0.9,
  "missing_fields": [],
  "clarifying_questions": []
}''';
  }

  /// Parse the AI response into EventExtractionResult
  EventExtractionResult _parseEventResponse(String response) {
    try {
      // Extract JSON from response (handle markdown code blocks)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch == null) {
        return EventExtractionResult(
          isEventRelated: false,
          confidence: 0.0,
        );
      }

      final jsonStr = jsonMatch.group(0)!;
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      return EventExtractionResult(
        isEventRelated: json['is_event_related'] as bool? ?? false,
        title: json['title'] as String?,
        description: json['description'] as String?,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        location: json['location'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        missingFields: (json['missing_fields'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        clarifyingQuestions: (json['clarifying_questions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );
    } catch (e) {
      return EventExtractionResult(
        isEventRelated: false,
        confidence: 0.0,
        error: 'Failed to parse AI response: $e',
      );
    }
  }

  /// Parse relative time to DateTime
  DateTime? parseRelativeTime(String timeStr) {
    final now = DateTime.now();

    // Handle "今天" (today)
    if (timeStr.contains('今天')) {
      return _parseTimeOnDate(now, timeStr);
    }

    // Handle "明天" (tomorrow)
    if (timeStr.contains('明天')) {
      final tomorrow = now.add(const Duration(days: 1));
      return _parseTimeOnDate(tomorrow, timeStr);
    }

    // Handle "后天" (day after tomorrow)
    if (timeStr.contains('后天')) {
      final dayAfter = now.add(const Duration(days: 2));
      return _parseTimeOnDate(dayAfter, timeStr);
    }

    // Handle "下周" (next week)
    if (timeStr.contains('下周')) {
      final nextWeek = now.add(const Duration(days: 7));
      return _parseTimeOnDate(nextWeek, timeStr);
    }

    return null;
  }

  DateTime _parseTimeOnDate(DateTime date, String timeStr) {
    // Extract time like "15:00", "下午3点", "3点"
    final timeMatch = RegExp(r'(\d{1,2})[:：点](\d{0,2})').firstMatch(timeStr);
    if (timeMatch != null) {
      var hour = int.parse(timeMatch.group(1)!);
      final minute = timeMatch.group(2) != null && timeMatch.group(2)!.isNotEmpty
          ? int.parse(timeMatch.group(2)!)
          : 0;

      // Handle 下午/上午
      if (timeStr.contains('下午') && hour < 12) {
        hour += 12;
      }

      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    // Default to 9 AM if no time specified
    return DateTime(date.year, date.month, date.day, 9, 0);
  }
}

/// Result of event extraction from natural language
class EventExtractionResult {
  final bool isEventRelated;
  final String? title;
  final String? description;
  final String? startTime;
  final String? endTime;
  final String? location;
  final double confidence;
  final List<String>? missingFields;
  final List<String>? clarifyingQuestions;
  final String? error;

  EventExtractionResult({
    required this.isEventRelated,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.location,
    required this.confidence,
    this.missingFields,
    this.clarifyingQuestions,
    this.error,
  });

  /// Check if the extraction is complete (no missing fields)
  bool get isComplete => missingFields == null || missingFields!.isEmpty;

  /// Check if confidence is high enough to proceed
  bool get isConfident => confidence >= 0.7;

  @override
  String toString() {
    return 'EventExtractionResult(isEventRelated: $isEventRelated, title: $title, '
        'confidence: $confidence, missingFields: $missingFields)';
  }
}

/// Event preview data for confirmation dialog
class EventPreview {
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? description;

  EventPreview({
    required this.title,
    required this.startTime,
    this.endTime,
    this.location,
    this.description,
  });

  EventPreview copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
  }) {
    return EventPreview(
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      description: description ?? this.description,
    );
  }

  /// Convert to Event domain model
  Event toEvent() {
    return Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      startTime: startTime,
      endTime: endTime ?? startTime.add(const Duration(hours: 1)),
      location: location,
      description: description,
    );
  }
}
