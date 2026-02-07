import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../data/services/storage_service.dart';
import '../../../domain/models/event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';

class CreateEventDialog extends StatefulWidget {
  final Function(Event) onEventCreated;

  const CreateEventDialog({
    super.key,
    required this.onEventCreated,
  });

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  bool _isAllDay = false;
  String _selectedColor = '#6366f1';

  final List<Map<String, dynamic>> _colorOptions = [
    {'color': '#6366f1', 'name': '靛蓝'},
    {'color': '#f59e0b', 'name': '橙色'},
    {'color': '#10b981', 'name': '绿色'},
    {'color': '#ef4444', 'name': '红色'},
    {'color': '#8b5cf6', 'name': '紫色'},
    {'color': '#ec4899', 'name': '粉色'},
    {'color': '#06b6d4', 'name': '青色'},
    {'color': '#84cc16', 'name': '青柠'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入事件标题';
    }
    return null;
  }

  String? _validateTimeRange() {
    if (_endTime.isBefore(_startTime) || _endTime.isAtSameMomentAs(_startTime)) {
      return '结束时间必须晚于开始时间';
    }
    return null;
  }

  void _handleCreateEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_validateTimeRange() != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('结束时间必须晚于开始时间')),
      );
      return;
    }

    final event = Event(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      color: _selectedColor,
      isAllDay: _isAllDay,
    );

    try {
      await StorageService().eventRepository.createEvent(event);
      widget.onEventCreated(event);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }

  Future<void> _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart ? _startTime : _endTime;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _startTime.hour,
            _startTime.minute,
          );
        } else {
          _endTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _endTime.hour,
            _endTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    final initialTime = isStart ? _startTime : _endTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = DateTime(
            _startTime.year,
            _startTime.month,
            _startTime.day,
            picked.hour,
            picked.minute,
          );
        } else {
          _endTime = DateTime(
            _endTime.year,
            _endTime.month,
            _endTime.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '创建事件',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      AppInput(
                        label: '事件标题',
                        placeholder: '输入事件标题...',
                        controller: _titleController,
                        isRequired: true,
                        validator: _validateTitle,
                      ),
                      const SizedBox(height: 16),

                      // All day toggle
                      Row(
                        children: [
                          Checkbox(
                            value: _isAllDay,
                            onChanged: (value) {
                              setState(() => _isAllDay = value ?? false);
                            },
                          ),
                          const Text('全天事件'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Start time
                      Text(
                        '开始时间',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectDate(isStart: true),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                DateFormat('MM月dd日').format(_startTime),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!_isAllDay)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTime(isStart: true),
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  DateFormat('HH:mm').format(_startTime),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // End time
                      Text(
                        '结束时间',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectDate(isStart: false),
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                DateFormat('MM月dd日').format(_endTime),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!_isAllDay)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTime(isStart: false),
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  DateFormat('HH:mm').format(_endTime),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Location
                      AppInput(
                        label: '地点',
                        placeholder: '添加地点...',
                        controller: _locationController,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      AppInput(
                        label: '描述',
                        placeholder: '添加描述...',
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 16),

                      // Color selection
                      Text(
                        '颜色',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _colorOptions.map((colorOption) {
                          final color = colorOption['color'] as String;
                          final isSelected = _selectedColor == color;
                          return InkWell(
                            onTap: () => setState(() => _selectedColor = color),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _parseColor(color),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '取消',
                      onPressed: () => Navigator.pop(context),
                      type: AppButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: '创建',
                      onPressed: _handleCreateEvent,
                      type: AppButtonType.primary,
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

Color _parseColor(String hexColor) {
  try {
    final color = hexColor.replaceAll('#', '');
    if (color.length == 6) {
      return Color(int.parse('FF$color', radix: 16));
    } else if (color.length == 8) {
      return Color(int.parse(color, radix: 16));
    }
  } catch (_) {
    // Return default color if parsing fails
  }
  return const Color(0xFF6366F1);
}
