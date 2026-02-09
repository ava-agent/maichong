import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_chat_bubble.dart';
import 'event_preview_dialog.dart';
import 'chat_input.dart';
import '../../../data/services/ai_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
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

  void _clearChat() {
    setState(() {
      _messages.clear();
      _isLoading = false;
      _isTyping = false;
    });
    _addGreetingMessage();
  }

  Future<void> _copyChatHistory() async {
    final buffer = StringBuffer();
    for (final msg in _messages) {
      final role = msg.isUser ? 'User' : 'AI';
      buffer.writeln('[$role] ${msg.message}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('对话已复制到剪贴板')),
      );
    }
  }

  Future<void> _showMenu() async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('清空对话'),
                onTap: () {
                  Navigator.of(context).pop();
                  _clearChat();
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('复制对话'),
                onTap: () {
                  Navigator.of(context).pop();
                  _copyChatHistory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('AI 状态'),
                subtitle: Text(_isAiInitialized ? '已连接' : '演示模式'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
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

  Future<void> _handleAIResponse(String userMessage) async {
    final extractionResult = await _aiService.extractEventFromText(userMessage);

    setState(() {
      _isTyping = false;
    });

    if (extractionResult.isEventRelated && extractionResult.isConfident) {
      if (extractionResult.isComplete) {
        _showEventPreview(extractionResult);
      } else {
        String clarification = '我理解你想创建：${extractionResult.title ?? '事件'}\n\n我还需要以下信息：\n';
        if (extractionResult.missingFields != null && extractionResult.missingFields!.isNotEmpty) {
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
        },
      ),
    );
  }

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
    return '${dt.month}月${dt.day}日 ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleDemoResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isTyping = false;
    });

    String response = _generateResponse(userMessage);

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

  String _generateResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('创建') || lowerMessage.contains('添加')) {
      return '好的！我来帮你创建一个事件。请告诉我：\n\n• 事件标题\n• 时间（例如：明天下午3点）\n• 地点（可选）';
    }

    if (lowerMessage.contains('今天') && lowerMessage.contains('什么')) {
      return '让我看看你今天有什么安排...\n\n目前你今天还没有任何事件。要创建一个吗？';
    }

    if (lowerMessage.contains('明天') && (lowerMessage.contains('几点') || lowerMessage.contains('时间'))) {
      return '明天下午3点和小明喝咖啡，对吗？要添加到你的时间线吗？';
    }

    if (lowerMessage.contains('你好') || lowerMessage.contains('嗨')) {
      return '你好！有什么可以帮你的吗？你可以试试说："明天下午3点开会"';
    }

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Modern AI Header
            _buildHeader(context),

            // Messages list
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _messages.length) {
                          return _buildTypingIndicator(context);
                        }

                        final message = _messages[index];
                        return ModernChatBubble(
                          message: message.message,
                          isUser: message.isUser,
                          timestamp: message.timestamp,
                          isSystem: message.isSystem ?? false,
                        );
                      },
                    ),
            ),

            // Suggested replies
            if (_messages.length <= 1 && !_isLoading)
              _buildSuggestions(context),

            // Input field
              _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // AI Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.aiGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 助手',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isAiInitialized ? '在线' : '演示模式',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _isAiInitialized ? AppColors.success : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () {
                _showMenu();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.aiPrimary.withOpacity(0.1),
                  AppColors.aiAccent.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 32,
              color: AppColors.aiPrimary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '开始对话',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '问我任何关于日程的问题',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TypingDot(delay: Duration.zero),
          const SizedBox(width: 6),
          _TypingDot(delay: const Duration(milliseconds: 150)),
          const SizedBox(width: 6),
          _TypingDot(delay: const Duration(milliseconds: 300)),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _SuggestionChip(
            label: _suggestions[index],
            onTap: () => _handleSend(_suggestions[index]),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_isLoading,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: '告诉我你想创建什么事件...',
                          hintStyle: AppTextStyles.hint,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _handleSend(_controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Send button
            _ModernSendButton(
              isLoading: _isLoading,
              onPressed: () => _handleSend(_controller.text),
            ),
          ],
        ),
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

// Typing dot animation
class _TypingDot extends StatelessWidget {
  final Duration delay;

  const _TypingDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, child, animation) {
        return Opacity(
          opacity: animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.aiPrimary.withOpacity(animation.value),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// Suggestion chip
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.gradientMiddle.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Modern send button
class _ModernSendButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _ModernSendButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_ModernSendButton> createState() => _ModernSendButtonState();
}

class _ModernSendButtonState extends State<_ModernSendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : () => _animController.forward(),
      onTapUp: widget.isLoading ? null : () {
        _animController.reverse();
        widget.onPressed();
      },
      onTapCancel: widget.isLoading ? null : () => _animController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.aiGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.aiPrimary.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
