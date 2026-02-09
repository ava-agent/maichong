import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/timeline/create_event_dialog.dart';
import '../../widgets/timeline/share_sheet.dart';
import '../../widgets/ai/modern_ai_chat_page.dart';
import 'timeline_view_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/storage_service.dart';
import '../../../domain/models/event.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateEventDialog(
        onEventCreated: (event) async {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('事件 "${event.title}" 已创建'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _showAIChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AIChatPage(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Modern Header
          _buildHeader(context),

          // Timeline View
          const Expanded(child: TimelineViewPage()),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          // AI Assistant FAB (smaller, positioned)
          Positioned(
            right: 0,
            bottom: 70,
            child: _ModernSmallFAB(
              icon: Icons.smart_toy_rounded,
              gradient: AppColors.aiGradient,
              onTap: () => _showAIChat(context),
            ),
          ),
          // Create Event FAB (main)
          _ModernExtendedFAB(
            icon: Icons.add_rounded,
            label: '创建事件',
            gradient: AppColors.primaryGradient,
            onTap: () => _showCreateEventDialog(context),
          ),
        ],
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
            // Logo/Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.roundabout_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            // Title
            Text(
              '我的时间线',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            // Search
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _EventSearchDelegate(),
                );
              },
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),

            // Share
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
                showTimelineShareSheet(
                  context: context,
                  timelineId: 'default',
                  timelineName: '我的时间线',
                );
              },
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),

            // Members
            IconButton(
              icon: const Icon(Icons.group_rounded),
              onPressed: () => context.push(
                '/timeline/members?timelineId=default&timelineName=我的时间线',
              ),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventSearchDelegate extends SearchDelegate<Event?> {
  Future<List<Event>> _loadEvents() async {
    return StorageService().eventRepository.getAllEvents();
  }

  List<Event> _filterEvents(List<Event> events, String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    return events.where((event) {
      final title = event.title.toLowerCase();
      final desc = event.description?.toLowerCase() ?? '';
      final location = event.location?.toLowerCase() ?? '';
      return title.contains(lower) || desc.contains(lower) || location.contains(lower);
    }).toList();
  }

  @override
  String? get searchFieldLabel => '搜索事件';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResultList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildResultList(context);

  Widget _buildResultList(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: _loadEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('加载失败: ${snapshot.error}'));
        }

        final events = snapshot.data ?? [];
        final filtered = _filterEvents(events, query);

        if (query.trim().isEmpty) {
          return const Center(child: Text('输入关键词搜索事件'));
        }

        if (filtered.isEmpty) {
          return const Center(child: Text('没有匹配的事件'));
        }

        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final event = filtered[index];
            return ListTile(
              title: Text(event.title),
              subtitle: Text('${event.dateDisplay} · ${event.timeRange}'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(event.title),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${event.dateDisplay} · ${event.timeRange}'),
                        if (event.location != null && event.location!.isNotEmpty)
                          Text('地点：${event.location}'),
                        if (event.description != null && event.description!.isNotEmpty)
                          Text('描述：${event.description}'),
                      ],
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
            );
          },
        );
      },
    );
  }
}

// Modern Extended FAB
class _ModernExtendedFAB extends StatefulWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ModernExtendedFAB({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ModernExtendedFAB> createState() => _ModernExtendedFABState();
}

class _ModernExtendedFABState extends State<_ModernExtendedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: () => _controller.forward(),
      onTapUp: () {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern Small FAB
class _ModernSmallFAB extends StatefulWidget {
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ModernSmallFAB({
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ModernSmallFAB> createState() => _ModernSmallFABState();
}

class _ModernSmallFABState extends State<_ModernSmallFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: () => _controller.forward(),
      onTapUp: () {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.aiPrimary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
