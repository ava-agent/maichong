import 'package:flutter/material.dart';
import '../../widgets/timeline/create_event_dialog.dart';
import 'timeline_view_page.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateEventDialog(
        onEventCreated: (event) async {
          // The dialog handles creation and reload internally
          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('事件 "${event.title}" 已创建'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的时间线'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () => context.push(
              '/timeline/members?timelineId=default&timelineName=我的时间线',
            ),
            tooltip: '成员管理',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'today':
                  // TODO: Filter to today
                  break;
                case 'upcoming':
                  // TODO: Filter to upcoming
                  break;
                case 'all':
                  // TODO: Show all
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'today',
                child: Row(
                  children: [
                    Icon(Icons.today),
                    SizedBox(width: 12),
                    Text('今天'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'upcoming',
                child: Row(
                  children: [
                    Icon(Icons.upcoming),
                    SizedBox(width: 12),
                    Text('即将到来'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 12),
                    Text('全部'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const TimelineViewPage(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('创建事件'),
        elevation: 4,
      ),
    );
  }
}
