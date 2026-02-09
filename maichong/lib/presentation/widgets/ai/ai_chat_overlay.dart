import 'package:flutter/material.dart';
import '../pages/ai/ai_chat_page.dart';

/// Full-screen overlay for AI chat accessed via floating button
/// Matches the product plan: "通过悬浮按钮唤出对话界面"
class AIChatOverlay extends StatefulWidget {
  const AIChatOverlay({super.key});

  @override
  State<AIChatOverlay> createState() => _AIChatOverlayState();
}

class _AIChatOverlayState extends State<AIChatOverlay> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = _isExpanded ? screenHeight * 0.95 : screenHeight * 0.7;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < 0) {
            // Swiped up - expand
            setState(() => _isExpanded = true);
          } else if (details.primaryVelocity! > 0) {
            // Swiped down - collapse
            setState(() => _isExpanded = false);
          }
        }
      },
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI 助手',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '用自然语言规划你的生活',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.expand_less),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    tooltip: _isExpanded ? '收起' : '展开',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '关闭',
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Chat content
            Expanded(
              child: _AIChatContent(
                onSendMessage: (message) {
                  // Handle message send - could trigger callback
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal widget that contains the actual chat UI
class _AIChatContent extends StatefulWidget {
  final ValueChanged<String>? onSendMessage;

  const _AIChatContent({
    this.onSendMessage,
  });

  @override
  State<_AIChatContent> createState() => _AIChatContentState();
}

class _AIChatContentState extends State<_AIChatContent> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  bool _isTyping = false;

  final List<String> _suggestions = [
    '明天下午3点和小明喝咖啡',
    '下周五晚上7点生日派对',
    '今天有什么安排？',
    '创建一个提醒',
  ];

  @override
  void initState() {
    super.initState();
    _addGreetingMessage();
  }

  void _addGreetingMessage() {
    _messages.add(ChatMessage(
      id: '1',
      message: '你好！我是你的 AI 助手。我可以帮你：\n\n• 创建、修改、删除事件\n• 查看你的时间线\n• 回答日程相关问题\n\n试试问我：明天下午3点和小明喝咖啡',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _handleSend(String message) {
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
    _simulateAIResponse(message);
  }

  Future<void> _simulateAIResponse(String userMessage) async {
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
    widget.onSendMessage?.call(userMessage);
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

    return '我明白了！你想了解更多关于日程管理的信息，对吗？我可以帮你创建、修改或查询事件。';
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
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
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
              );
            },
          ),
        ),

        // Suggested replies
        if (_messages.length <= 1 && !_isLoading)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return SuggestionChip(
                  label: Text(_suggestions[index]),
                  onPressed: () => _handleSend(_suggestions[index]),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              },
            ),
          ),

        // Input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            enabled: !_isLoading,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: '告诉 AI 你想做什么...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _handleSend(_textController.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _textController.text.trim().isEmpty
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: _textController.text.trim().isEmpty || _isLoading
                        ? null
                        : () {
                              final message = _textController.text.trim();
                              _textController.clear();
                              _handleSend(message);
                            },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: _textController.text.trim().isEmpty
                                  ? theme.colorScheme.onSurface.withOpacity(0.4)
                                  : theme.colorScheme.onPrimary,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
