import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onSend;
  final bool isLoading;
  final VoidCallback? onAttach;

  const ChatInput({
    super.key,
    this.hintText = '输入消息...',
    this.onSend,
    this.isLoading = false,
    this.onAttach,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isEmpty = _controller.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_isEmpty || widget.isLoading) return;

    final message = _controller.text.trim();
    _controller.clear();
    widget.onSend?.call(message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
            // Attach button
            if (widget.onAttach != null)
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: widget.isLoading ? null : widget.onAttach,
                tooltip: '附件',
              ),
            // Input field
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
                        controller: _controller,
                        enabled: !widget.isLoading,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                    // Clear button
                    if (!_isEmpty && !widget.isLoading)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Material(
              color: _isEmpty
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: widget.isLoading ? null : _handleSend,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: widget.isLoading
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
                          color: _isEmpty
                              ? theme.colorScheme.onSurface.withOpacity(0.4)
                              : theme.colorScheme.onPrimary,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
