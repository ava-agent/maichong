import 'package:flutter/material.dart';
import '../../../data/services/ai_service.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/ai/chat_bubble.dart';
import '../../widgets/ai/chat_input.dart';
import '../../widgets/ai/event_preview_dialog.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  bool _isLoading = false;
  bool _isTyping = false;
  bool _isAiInitialized = false;

  // Sample conversation starters
  final List<String> _suggestions = [
    '明天下午3点和小明喝咖啡',
    '下周五晚上7点生日派对',
    '今天有什么安排？',
    '创建一个提醒',
  ];

  @override
  void initState() {
    super.initState();
    _initAI();
    _addGreetingMessage();
  }

  Future<void> _initAI() async {
    final initialized = await _aiService.init();
    if (mounted) {
      setState(() {
        _isAiInitialized = initialized;
      });
    }
    if (!initialized) {
      _addSystemMessage('AI 服务未配置。请在环境变量中设置 DEEPSEEK_API_KEY 或 OPENAI_API_KEY。当前使用演示模式。');
    }
  }

  void _addGreetingMessage() {
    setState(() {
      _messages.add(ChatMessage(
        id: '1',
        message: '你好！我是你的 AI 助手。我可以帮你：\n\n• 创建、修改、删除事件\n• 查看你的时间线\n• 回答日程相关问题\n\n试试问我：明天下午3点和小明喝咖啡',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _addSystemMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message,
        isUser: false,
        timestamp: DateTime.now(),
        isSystem: true,
      ));
    });
  }

  Future<void> _handleSend(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      if (_isAiInitialized) {
        await _handleAIResponse(message);
      } else {
        await _handleDemoResponse(message);
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _isLoading = false;
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: '抱歉，发生了错误：$e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  /// Handle AI response with real API
  Future<void> _handleAIResponse(String userMessage) async {
    // First, try to extract event information
    final extractionResult = await _aiService.extractEventFromText(userMessage);

    setState(() {
      _isTyping = false;
    });

    if (extractionResult.isEventRelated && extractionResult.isConfident) {
      if (extractionResult.isComplete) {
        // Show event preview for confirmation
        _showEventPreview(extractionResult);
      } else {
        // Ask for missing information
        String clarification = '我理解你想创建：${extractionResult.title ?? '事件'}\n\n';
        if (extractionResult.missingFields != null && extractionResult.missingFields!.isNotEmpty) {
          clarification += '我还需要以下信息：\n';
          for (final field in extractionResult.missingFields!) {
            clarification += '• $field\n';
          }
        }
        if (extractionResult.clarifyingQuestions != null && extractionResult.clarifyingQuestions!.isNotEmpty) {
          clarification += '\n问题：\n';
          for (final question in extractionResult.clarifyingQuestions!) {
            clarification += '• $question\n';
          }
        }

        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            message: clarification,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    } else {
      // Not event-related or low confidence, use general chat
      final events = await StorageService().eventRepository.getAllEvents();
      final response = await _aiService.generateChatResponse(userMessage, userEvents: events);

      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  /// Show event preview dialog for user confirmation
  void _showEventPreview(EventExtractionResult result) {
    final startTime = _aiService.parseRelativeTime(result.startTime!) ?? DateTime.now();
    final endTime = result.endTime != null
        ? _aiService.parseRelativeTime(result.endTime!)
        : startTime.add(const Duration(hours: 1));

    final preview = EventPreview(
      title: result.title ?? '新事件',
      startTime: startTime,
      endTime: endTime,
      location: result.location,
      description: result.description,
    );

    showDialog(
      context: context,
      builder: (context) => EventPreviewDialog(
        preview: preview,
        onConfirm: (updatedPreview) async {
          Navigator.of(context).pop();
          await _createEvent(updatedPreview);
        },
        onEdit: (_) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请重新输入描述以修改事件信息')),
          );
        },
      ),
    );
  }

  /// Create the event after user confirmation
  Future<void> _createEvent(EventPreview preview) async {
    try {
      final event = preview.toEvent();
      await StorageService().eventRepository.createEvent(event);

      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: '✅ 已创建事件：${event.title}\n\n时间：${_formatDateTime(event.startTime)}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: '创建事件失败：$e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Handle demo response (when AI is not configured)
  Future<void> _handleDemoResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isTyping = false;
    });

    String response = _generateDemoResponse(userMessage);

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  String _generateDemoResponse(String message) {
    final lowerMessage = message.toLowerCase();

    // Event creation patterns
    if (lowerMessage.contains('创建') || lowerMessage.contains('添加')) {
      return '好的！我来帮你创建一个事件。请告诉我：\n\n• 事件标题\n• 时间（例如：明天下午3点）\n• 地点（可选）';
    }

    // Query patterns
    if (lowerMessage.contains('今天') && lowerMessage.contains('什么')) {
      return '让我看看你今天有什么安排...\n\n目前你今天还没有任何事件。要创建一个吗？';
    }

    if (lowerMessage.contains('明天') && (lowerMessage.contains('几点') || lowerMessage.contains('时间'))) {
      return '明天下午3点和小明喝咖啡，对吗？要添加到你的时间线吗？';
    }

    // Simple greeting
    if (lowerMessage.contains('你好') || lowerMessage.contains('嗨')) {
      return '你好！有什么可以帮你的吗？你可以试试说："明天下午3点开会"';
    }

    // Default
    return '我明白了！你想了解更多关于日程管理的信息，对吗？我可以帮你创建、修改或查询事件。\n\n💡 提示：配置 DEEPSEEK_API_KEY 或 OPENAI_API_KEY 环境变量以启用完整 AI 功能。';
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 助手'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('对话记录'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: _messages.isEmpty
                        ? const Text('暂无对话记录')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  msg.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(msg.isUser ? '用户' : 'AI'),
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addGreetingMessage();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // AI status indicator
          if (!_isAiInitialized)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI 服务未配置 - 使用演示模式',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TypingIndicator(),
                  );
                }

                final message = _messages[index];
                return ChatBubble(
                  message: message.message,
                  isUser: message.isUser,
                  timestamp: message.timestamp,
                  isSystem: message.isSystem ?? false,
                );
              },
            ),
          ),

          // Suggested replies (only when no active conversation)
          if (_messages.length <= 1 && !_isLoading)
            SuggestedReplies(
              suggestions: _suggestions,
              onSuggestionTap: (suggestion) => _handleSend(suggestion),
            ),

          // Input field
          ChatInput(
            hintText: '告诉 AI 你想做什么...',
            onSend: (message) => _handleSend(message),
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime? timestamp;
  final bool? isSystem;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    this.timestamp,
    this.isSystem,
  });
}
