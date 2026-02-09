import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/supabase_service.dart';

class TimelineMembersPage extends StatefulWidget {
  final String timelineId;
  final String timelineName;

  const TimelineMembersPage({
    super.key,
    required this.timelineId,
    required this.timelineName,
  });

  @override
  State<TimelineMembersPage> createState() => _TimelineMembersPageState();
}

class _TimelineMembersPageState extends State<TimelineMembersPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _members = [];
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);

    try {
      if (!SupabaseService().isInitialized) {
        _members = [
          {
            'id': '1',
            'user_id': 'owner-1',
            'role': 'owner',
            'nickname': '?',
            'avatar_url': null,
            'joined_at': DateTime.now().toIso8601String(),
          },
          {
            'id': '2',
            'user_id': 'user-2',
            'role': 'admin',
            'nickname': '??',
            'avatar_url': null,
            'joined_at': DateTime.now().toIso8601String(),
          },
          {
            'id': '3',
            'user_id': 'user-3',
            'role': 'member',
            'nickname': '??',
            'avatar_url': null,
            'joined_at': DateTime.now().toIso8601String(),
          },
        ];
        _currentUserRole = 'owner';
        setState(() => _isLoading = false);
        return;
      }

      final client = Supabase.instance.client;
      final response = await client
          .from('timeline_members')
          .select('id, user_id, role, joined_at, users(nickname, avatar_url, email)')
          .eq('timeline_id', widget.timelineId)
          .order('joined_at', ascending: true);

      final list = List<Map<String, dynamic>>.from(response as List);
      _members = list.map((m) {
        final user = (m['users'] ?? {}) as Map;
        return {
          'id': m['id'],
          'user_id': m['user_id'],
          'role': m['role'],
          'nickname': user['nickname'] ?? user['email'] ?? '??',
          'avatar_url': user['avatar_url'],
          'joined_at': m['joined_at'],
        };
      }).toList();

      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId != null) {
        final me = _members.firstWhere(
          (m) => m['user_id'] == currentUserId,
          orElse: () => {},
        );
        _currentUserRole = (me['role'] as String?) ?? 'member';
      } else {
        _currentUserRole = 'member';
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('??????: $e')),
        );
      }
    }
  }

  Future<void> _showInviteDialog() async {
    await showDialog(
      context: context,
      builder: (context) => InviteDialog(
        timelineId: widget.timelineId,
        timelineName: widget.timelineName,
      ),
    );
    _loadMembers();
  }

  Future<void> _removeMember(Map<String, dynamic> member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除成员'),
        content: Text('确定要移除 "${member['nickname']}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('移除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (SupabaseService().isInitialized) {
          await Supabase.instance.client
              .from('timeline_members')
              .delete()
              .eq('id', member['id']);
        }
        setState(() {
          _members.removeWhere((m) => m['id'] == member['id']);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member['nickname']} 已被移除')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('移除失败: $e')),
          );
        }
      }
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'owner':
        return const Color(0xFFF59E0B); // Orange
      case 'admin':
        return const Color(0xFF6366F1); // Indigo
      default:
        return const Color(0xFF64748B); // Gray
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'owner':
        return '所有者';
      case 'admin':
        return '管理员';
      default:
        return '成员';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.timelineName} - 成员'),
        elevation: 0,
        actions: [
          if (_currentUserRole == 'owner' || _currentUserRole == 'admin')
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showInviteDialog,
              tooltip: '邀请成员',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '还没有成员',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击 + 按钮邀请成员加入',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    final role = member['role'] as String;
                    final isOwner = role == 'owner';
                    final canRemove = !isOwner &&
                        (_currentUserRole == 'owner' ||
                            (_currentUserRole == 'admin' && role != 'admin'));

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: member['avatar_url'] != null
                            ? ClipOval(
                                child: Image.network(
                                  member['avatar_url'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      member['nickname']?.substring(0, 1) ?? '?',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                member['nickname']?.substring(0, 1) ?? '?',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      title: Text(
                        member['nickname'] ?? '未知用户',
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        '加入于 ${_formatDate(member['joined_at'])}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Role badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getRoleColor(role),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getRoleLabel(role),
                              style: TextStyle(
                                color: _getRoleColor(role),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Remove button (only if allowed)
                          if (canRemove)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: theme.colorScheme.error,
                              onPressed: () => _removeMember(member),
                              tooltip: '移除成员',
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '未知';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date).inDays;

      if (diff == 0) return '今天';
      if (diff == 1) return '昨天';
      if (diff < 7) return '${diff}天前';
      if (diff < 30) return '${(diff / 7).floor()}周前';
      if (diff < 365) return '${(diff / 30).floor()}个月前';
      return '${(diff / 365).floor()}年前';
    } catch (e) {
      return dateString;
    }
  }
}
