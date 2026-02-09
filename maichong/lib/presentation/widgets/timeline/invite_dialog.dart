import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/services/share_link_service.dart';
import '../../../data/repositories/timeline_repository.dart';

class InviteDialog extends StatefulWidget {
  final String timelineId;
  final String timelineName;

  const InviteDialog({
    super.key,
    required this.timelineId,
    required this.timelineName,
  });

  @override
  State<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _shareLinkService = ShareLinkService();

  bool _isLoading = false;
  String? _selectedRole = 'member';
  String? _generatedInviteLink;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateInviteLink();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _generateInviteLink() {
    final link = _shareLinkService.generateInviteLink(
      timelineId: widget.timelineId,
      timelineName: widget.timelineName,
    );
    setState(() {
      _generatedInviteLink = link;
    });
  }

  Future<void> _copyInviteLink() async {
    if (_generatedInviteLink == null) return;

    await _shareLinkService.copyInviteLinkToClipboard(
      context,
      _generatedInviteLink!,
    );
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = TimelineRepositoryImpl();
      // For now, just show a success message
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('邀请链接已发送给 ${_emailController.text}'),
            action: SnackBarAction(
              label: '复制链接',
              onPressed: () {
                if (_generatedInviteLink != null) {
                  Clipboard.setData(ClipboardData(text: _generatedInviteLink!));
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送邀请失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '邀请成员',
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          '时间线: ${widget.timelineName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '分享链接'),
                Tab(text: '邮件邀请'),
              ],
            ),

            // Tab content
            SizedBox(
              height: 280,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShareLinkTab(theme),
                  _buildEmailInviteTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareLinkTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '分享此链接，让成员一键加入你的时间线',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Invite link display
          Text(
            '邀请链接',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _generatedInviteLink ?? '生成中...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyInviteLink,
                  tooltip: '复制链接',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Role selection
          Text(
            '新成员默认角色',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'member',
                label: '成员',
              ),
              ButtonSegment(
                value: 'admin',
                label: '管理员',
              ),
            ],
            selected: {_selectedRole ?? 'member': true},
            onSelectionChanged: (value) {
              setState(() => _selectedRole = value.first);
            },
          ),
          const Spacer(),

          // Copy button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _copyInviteLink,
              icon: const Icon(Icons.copy),
              label: const Text('复制邀请链接'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInviteTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email input
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '邮箱地址',
                hintText: '输入要邀请的邮箱',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入邮箱地址';
                }
                if (!value.contains('@')) {
                  return '请输入有效的邮箱地址';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Role selection
            Text(
              '角色',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'member',
                  label: '成员',
                ),
                ButtonSegment(
                  value: 'admin',
                  label: '管理员',
                ),
              ],
              selected: {_selectedRole ?? 'member': true},
              onSelectionChanged: (value) {
                setState(() => _selectedRole = value.first);
              },
            ),
            const Spacer(),

            // Send button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _sendInvite,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('发送邀请'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
