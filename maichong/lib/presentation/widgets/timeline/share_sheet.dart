import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/share_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/timeline_capture_service.dart';

/// Bottom sheet for sharing timeline
class TimelineShareSheet extends StatefulWidget {
  final String? timelineId;
  final String? timelineName;

  const TimelineShareSheet({
    super.key,
    this.timelineId,
    this.timelineName,
  });

  @override
  State<TimelineShareSheet> createState() => _TimelineShareSheetState();
}

class _TimelineShareSheetState extends State<TimelineShareSheet> {
  final _captureService = TimelineCaptureService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareService = ShareService();

    // Add image capture option to standard options
    final extendedOptions = [
      ShareOption(
        id: 'image',
        label: '生成图片',
        icon: Icons.image,
      ),
      ...ShareOptions.standardOptions,
    ];

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.share,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '分享时间线',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Share preview
          FutureBuilder<List>(
            future: StorageService().eventRepository.getAllEvents(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              final events = snapshot.data!;

              return Column(
                children: [
                  // Preview card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${events.length}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timelineName ?? '我的时间线',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${events.length} 个事件',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Share options
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: extendedOptions.length,
                    itemBuilder: (context, index) {
                      final option = extendedOptions[index];
                      return _ShareOptionTile(
                        option: option,
                        onTap: () => _handleShareOption(
                          context,
                          shareService,
                          option,
                          events,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _handleShareOption(
    BuildContext context,
    ShareService shareService,
    ShareOption option,
    List events,
  ) async {
    final shareText = shareService.generateEventsShareText(
      events,
      title: timelineName,
    );

    switch (option.id) {
      case 'image':
        await _handleImageGeneration(context, events);
        return; // Don't close the sheet yet

      case 'weibo':
        shareService.shareOnSocialMedia(
          'weibo',
          text: shareText,
          url: 'https://pulse.app', // Replace with actual URL
        );
        break;

      case 'wechat':
        final copied = await shareService.copyToClipboard(shareText);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(copied ? '已复制到剪贴板' : '复制失败'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;

      case 'copy':
        final copied = await shareService.copyToClipboard(shareText);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(copied ? '已复制到剪贴板' : '复制失败'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;

      case 'download':
        final downloaded = await shareService.downloadAsFile(
          events,
          '${timelineName ?? 'timeline'}_${DateTime.now().millisecondsSinceEpoch}.txt',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(downloaded ? '下载已开始' : '下载失败'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;

      case 'ics':
        final downloaded = await shareService.downloadAsIcs(
          events,
          '${timelineName ?? 'timeline'}_${DateTime.now().millisecondsSinceEpoch}.ics',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(downloaded ? '日历文件已下载' : '下载失败'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;

      case 'more':
        if (context.mounted) {
          await shareService.shareTimeline(
            title: timelineName ?? '我的时间线',
            description: shareText,
            url: 'https://pulse.app',
          );
        }
        break;
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleImageGeneration(BuildContext context, List events) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在生成图片...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final dataUrl = await _captureService.generateTimelineImage(
        events: events,
        timelineName: timelineName ?? '我的时间线',
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (dataUrl != null) {
          // Show image preview dialog
          await showDialog(
            context: context,
            builder: (context) => _ImagePreviewDialog(
              dataUrl: dataUrl,
              timelineName: timelineName ?? '我的时间线',
              onDownload: () async {
                final downloaded = await _captureService.downloadImage(
                  dataUrl,
                  '${timelineName ?? 'timeline'}_${DateTime.now().millisecondsSinceEpoch}.png',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(downloaded ? '图片已下载' : '下载失败'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onCopy: () async {
                final copied = await _captureService.copyToClipboard(dataUrl);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(copied ? '图片已复制到剪贴板' : '复制失败'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('图片生成失败'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成图片时出错: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Image preview dialog
class _ImagePreviewDialog extends StatelessWidget {
  final String dataUrl;
  final String timelineName;
  final VoidCallback onDownload;
  final VoidCallback onCopy;

  const _ImagePreviewDialog({
    required this.dataUrl,
    required this.timelineName,
    required this.onDownload,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.image,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '时间线分享图片',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timelineName,
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

            // Image preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  dataUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy),
                      label: const Text('复制图片'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onDownload,
                      icon: const Icon(Icons.download),
                      label: const Text('下载图片'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  final ShareOption option;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: option.color != null
                  ? Color(int.parse(option.color!.replaceFirst('#', '0xFF')))
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              option.icon,
              color: option.color != null
                  ? Colors.white
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            option.label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Show timeline share sheet
void showTimelineShareSheet({
  required BuildContext context,
  String? timelineId,
  String? timelineName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TimelineShareSheet(
      timelineId: timelineId,
      timelineName: timelineName,
    ),
  );
}
