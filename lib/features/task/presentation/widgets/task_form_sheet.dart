import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/bottom_sheet_insets.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';

class TaskFormSheet extends StatefulWidget {
  final String userId;
  final TaskEntity? task;
  final DateTime? initialDate;

  const TaskFormSheet({
    super.key,
    required this.userId,
    this.task,
    this.initialDate,
  });

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();

  late DateTime _deadline;
  late TimeOfDay _deadlineTime;
  late Color _selectedColor;
  late String _selectedIcon;

  bool get _isEditing => widget.task != null;

  static const _colors = [
    AppColors.primary,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
    AppColors.blueAccent,
    AppColors.purpleAccent,
    AppColors.pinkAccent,
    AppColors.tealAccent,
  ];

  static const _icons = <String, IconData>{
    'task': Icons.assignment_rounded,
    'homework': Icons.home_work_rounded,
    'exam': Icons.quiz_rounded,
    'project': Icons.folder_rounded,
    'personal': Icons.person_rounded,
  };

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    final current = DateTime.now();
    final initialDate = widget.initialDate;
    _deadline =
        task?.deadline ??
        (initialDate == null
            ? current.add(const Duration(days: 1))
            : DateTime(initialDate.year, initialDate.month, initialDate.day));
    _deadlineTime = TimeOfDay.fromDateTime(
      task?.deadline ?? _deadline.copyWith(hour: 23, minute: 59),
    );
    _selectedColor = task == null ? AppColors.primary : Color(task.color);
    _selectedIcon = task?.iconName ?? 'task';

    if (task != null) {
      _nameController.text = task.name;
      _subjectController.text = task.subject ?? '';
      _detailsController.text = task.details ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _save(BuildContext formContext) {
    if (Form.maybeOf(formContext)?.validate() != true) return;

    final deadline = DateTime(
      _deadline.year,
      _deadline.month,
      _deadline.day,
      _deadlineTime.hour,
      _deadlineTime.minute,
    );

    final task = TaskEntity(
      id: widget.task?.id ?? 0,
      userId: widget.userId,
      name: _nameController.text.trim(),
      subject: _nullableText(_subjectController.text),
      deadline: deadline,
      details: _nullableText(_detailsController.text),
      color: _selectedColor.toARGB32(),
      iconName: _selectedIcon,
      isPinned: widget.task?.isPinned ?? false,
      isCompleted: widget.task?.isCompleted ?? false,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      context.read<TaskBloc>().add(
        UpdateTask(task: task, userId: widget.userId),
      );
    } else {
      context.read<TaskBloc>().add(AddTask(task: task, userId: widget.userId));
    }

    Navigator.pop(context);
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: BottomSheetInsets.bottom(context),
        ),
        child: Form(
          child: Builder(
            builder: (formContext) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SheetHandle(),
                  const SizedBox(height: 18),
                  Text(
                    _isEditing ? 'Edit Task' : 'Tambah Task',
                    style: AppTextStyles.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      hintText: 'Nama task',
                      prefixIcon: Icon(Icons.assignment_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nama task wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subjectController,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      hintText: 'Mata pelajaran (opsional)',
                      prefixIcon: Icon(Icons.book_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionLabel('Deadline'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.calendar_today_outlined,
                          label:
                              '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.access_time_outlined,
                          label:
                              '${_deadlineTime.hour.toString().padLeft(2, '0')}:${_deadlineTime.minute.toString().padLeft(2, '0')}',
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _detailsController,
                    style: AppTextStyles.body,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Detail (opsional)',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Warna'),
                  const SizedBox(height: 8),
                  _ColorChoices(
                    colors: _colors,
                    selectedColor: _selectedColor,
                    onSelected: (color) =>
                        setState(() => _selectedColor = color),
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Ikon'),
                  const SizedBox(height: 8),
                  _IconChoices(
                    icons: _icons,
                    selectedIcon: _selectedIcon,
                    selectedColor: _selectedColor,
                    onSelected: (icon) => setState(() => _selectedIcon = icon),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _save(formContext),
                      child: Text(
                        _isEditing ? 'Simpan Perubahan' : 'Tambah Task',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date != null) setState(() => _deadline = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _deadlineTime,
    );
    if (time != null) setState(() => _deadlineTime = time);
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.greyHandle,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.title.copyWith(fontSize: 13));
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

class _ColorChoices extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onSelected;

  const _ColorChoices({
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((color) {
        final selected = color == selectedColor;
        return InkWell(
          onTap: () => onSelected(color),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.textMain : AppColors.greyBorder,
                width: selected ? 3 : 1,
              ),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: AppColors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _IconChoices extends StatelessWidget {
  final Map<String, IconData> icons;
  final String selectedIcon;
  final Color selectedColor;
  final ValueChanged<String> onSelected;

  const _IconChoices({
    required this.icons,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: icons.entries.map((entry) {
        final selected = entry.key == selectedIcon;
        return InkWell(
          onTap: () => onSelected(entry.key),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: selected
                  ? selectedColor.withValues(alpha: 0.14)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? selectedColor : AppColors.greyBorder,
              ),
            ),
            child: Icon(
              entry.value,
              color: selected ? selectedColor : AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
