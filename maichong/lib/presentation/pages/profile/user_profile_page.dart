import 'package:flutter/material.dart';
import 'package:package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/supabase_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepositoryImpl();
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  // Mock user data - in production, this would come from auth service
  Map<String, dynamic> _userData = {
    'id': 'user-1',
    'email': 'user@example.com',
    'nickname': '用户',
    'avatar_url': null,
    'created_at': DateTime.now().toIso8601String(),
  };

  @override
  void initState() {
    super.initState();
    _nicknameController.text = _userData['nickname'] ?? '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!SupabaseService().isInitialized) {
      setState(() {});
      return;
    }

    final user = _authRepository.currentUser;
    if (user == null) {
      setState(() {});
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _userData = Map<String, dynamic>.from(response);
          _nicknameController.text = _userData['nickname'] ?? '';
        });
      } else {
        setState(() {
          _userData = {
            'id': user.id,
            'email': user.email ?? '',
            'nickname': user.userMetadata?['nickname'] ?? '??',
            'avatar_url': user.userMetadata?['avatar_url'],
            'created_at': DateTime.now().toIso8601String(),
          };
          _nicknameController.text = _userData['nickname'] ?? '';
        });
      }
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _pickAvatar() async {
    try {
      if (!SupabaseService().isInitialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('???? Supabase ??????')),
          );
        }
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isUploadingAvatar = true);

        final file = result.files.single;
        final bytes = file.bytes;
        if (bytes == null) {
          throw Exception('????????');
        }

        final userId = _authRepository.currentUserId;
        if (userId == null) {
          throw Exception('?????');
        }

        final filePath = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final storage = Supabase.instance.client.storage.from('avatars');
        await storage.uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: file.mimeType ?? 'image/png',
            upsert: true,
          ),
        );
        final publicUrl = storage.getPublicUrl(filePath);

        await _authRepository.updateProfile(avatarUrl: publicUrl);

        setState(() {
          _userData['avatar_url'] = publicUrl;
          _isUploadingAvatar = false;
        });
      }
    } catch (e) {
      setState(() => _isUploadingAvatar = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('??????: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nickname = _nicknameController.text.trim();
      _userData['nickname'] = nickname;

      if (SupabaseService().isInitialized) {
        await _authRepository.updateProfile(nickname: nickname);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('???????')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('????: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: _userData['avatar_url'] != null
                              ? NetworkImage(_userData['avatar_url']) as ImageProvider
                              : null,
                          child: _userData['avatar_url'] == null
                              ? Text(
                                  _userData['nickname']?.substring(0, 1) ?? 'U',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (_isUploadingAvatar)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '点击头像更换图片',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Email field (read-only)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: '邮箱',
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              controller: TextEditingController(text: _userData['email'] ?? ''),
            ),
            const SizedBox(height: 16),

            // Nickname field
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: '昵称',
                prefixIcon: Icon(Icons.person),
                hintText: '输入你的昵称',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入昵称';
                }
                if (value.trim().length < 2) {
                  return '昵称至少需要2个字符';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Account info section
            Text(
              '账户信息',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: const Text('注册时间'),
                    subtitle: Text(
                      _formatDate(_userData['created_at']),
                    ),
                    leading: const Icon(Icons.calendar_today),
                  ),
                  Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: const Text('用户 ID'),
                    subtitle: Text(
                      _userData['id'],
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    leading: const Icon(Icons.badge),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // My timelines section
            Text(
              '我的时间线',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: const Text('个人时间线'),
                    subtitle: const Text('默认时间线'),
                    leading: const Icon(Icons.timeline),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    onTap: () {
                      // Navigate to timeline
                      context.pop();
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: const Text('创建新时间线'),
                    leading: const Icon(Icons.add_circle_outline),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('创建时间线功能即将推出')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '未知';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}年${date.month}月${date.day}日';
    } catch (e) {
      return dateString;
    }
  }
}
