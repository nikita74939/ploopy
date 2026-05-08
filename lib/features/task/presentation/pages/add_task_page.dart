import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/neo_container.dart';
import '../bloc/task_bloc.dart';
import '../../data/models/task_model.dart';

class AddTaskPage extends StatefulWidget {
  final TaskModel? task;

  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();

  String? _userId;

  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _deadlineTime = TimeOfDay(hour: 23, minute: 59);

  Color _selectedColor = AppColors.primary;
  String _selectedIcon = 'task';

  final List<Color> _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
    AppColors.blueAccent,
    AppColors.purpleAccent,
    AppColors.pinkAccent,
    AppColors.orangeAccent,
    AppColors.tealAccent,
  ];

  final List<String> _icons = [
    'task',
    'homework',
    'exam',
    'project',
    'personal',
  ];

  @override
  void initState() {
    super.initState();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _userId = args;
    } else if (args is TaskModel) {
      // Jika mengedit task yang sudah ada
      _userId = args.userId;
    }

    if (widget.task != null) {
      _nameController.text = widget.task!.name;
      _subjectController.text = widget.task!.subject ?? '';
      _detailsController.text = widget.task!.details ?? '';
      _deadline = widget.task!.deadline;
      _deadlineTime = TimeOfDay.fromDateTime(widget.task!.deadline);
      _selectedColor = Color(widget.task!.color);
      _selectedIcon = widget.task!.iconName ?? 'task';
      _userId = widget.task!.userId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final deadlineDateTime = DateTime(
        _deadline.year,
        _deadline.month,
        _deadline.day,
        _deadlineTime.hour,
        _deadlineTime.minute,
      );

      final task = TaskModel.create(
        name: _nameController.text.trim(),
        subject: _subjectController.text.isEmpty
            ? null
            : _subjectController.text.trim(),
        deadline: deadlineDateTime,
        details: _detailsController.text.isEmpty
            ? null
            : _detailsController.text.trim(),
        color: _selectedColor.value,
        iconName: _selectedIcon,
        userId: _userId!,
      );

      if (widget.task != null) {
        task.id = widget.task!.id;
        task.isPinned = widget.task!.isPinned;
        task.isCompleted = widget.task!.isCompleted;
        context.read<TaskBloc>().add(UpdateTask(task: task, userId: _userId!));
      } else {
        context.read<TaskBloc>().add(AddTask(task: task, userId: _userId!));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(widget.task != null ? 'Edit Task' : 'Add Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyle.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'Task Name',
                prefixIcon: Icons.assignment,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _subjectController,
                hintText: 'Subject (optional)',
                prefixIcon: Icons.book,
              ),
              const SizedBox(height: 16),

              // Deadline
              const Text(
                'Deadline',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_deadlineTime.hour.toString().padLeft(2, '0')}:${_deadlineTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _detailsController,
                hintText: 'Details (optional)',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Color Selection
              const Text(
                'Color',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: _selectedColor == color
                            ? Border.all(color: AppColors.textMain, width: 3)
                            : null,
                      ),
                      child: _selectedColor == color
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Icon Selection
              const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _icons.map((iconName) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconName;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _selectedIcon == iconName
                            ? _selectedColor.withOpacity(0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedIcon == iconName
                              ? _selectedColor
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getIconData(iconName),
                        color: _selectedIcon == iconName
                            ? _selectedColor
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              NeoButton(
                text: widget.task != null ? 'Update Task' : 'Save Task',
                onPressed: _saveTask,
                textColor: Colors.white,
                backgroundColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _deadline = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _deadlineTime,
    );
    if (time != null) {
      setState(() {
        _deadlineTime = time;
      });
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'task':
        return Icons.assignment;
      case 'homework':
        return Icons.home_work;
      case 'exam':
        return Icons.quiz;
      case 'project':
        return Icons.folder;
      case 'personal':
        return Icons.person;
      default:
        return Icons.assignment;
    }
  }
}
