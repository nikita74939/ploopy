import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/schedule_entity.dart';
import '../bloc/schedule_bloc.dart';
import 'color_picker_widget.dart';
import 'icon_picker_widget.dart';
import 'recurrence_picker_widget.dart';

class ScheduleFormSheet extends StatefulWidget {
  final String userId;
  final ScheduleEntity? schedule;
  final VoidCallback? onSaved;

  const ScheduleFormSheet({
    super.key,
    required this.userId,
    this.schedule,
    this.onSaved,
  });

  @override
  State<ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<ScheduleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late String _selectedRecurrence;
  late String _selectedColor;
  late String _selectedIcon;
  DateTime? _recurrenceEnd;

  bool get _isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    final now = DateTime.now();

    if (schedule == null) {
      _startDate = now;
      _startTime = TimeOfDay.fromDateTime(now);
      final end = now.add(const Duration(hours: 1));
      _endDate = end;
      _endTime = TimeOfDay.fromDateTime(end);
      _selectedRecurrence = 'None';
      _selectedColor = '0xFFFF7600';
      _selectedIcon = 'event';
      return;
    }

    _nameController.text = schedule.name;
    _locationController.text = schedule.location ?? '';
    _descriptionController.text = schedule.description ?? '';
    _linkController.text = schedule.url ?? '';
    _startDate = schedule.startTime;
    _startTime = TimeOfDay.fromDateTime(schedule.startTime);
    _endDate = schedule.endTime;
    _endTime = TimeOfDay.fromDateTime(schedule.endTime);
    _selectedRecurrence = schedule.recurrence;
    _recurrenceEnd = schedule.recurrenceEnd;
    _selectedColor =
        '0x${schedule.color.toRadixString(16).toUpperCase().padLeft(8, '0')}';
    _selectedIcon = schedule.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final start = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final end = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu selesai harus setelah mulai')),
      );
      return;
    }

    final schedule = ScheduleEntity(
      id: widget.schedule?.id ?? 0,
      userId: widget.schedule?.userId ?? widget.userId,
      name: _nameController.text.trim(),
      startTime: start,
      endTime: end,
      recurrence: _selectedRecurrence,
      recurrenceEnd: _selectedRecurrence == 'None' ? null : _recurrenceEnd,
      location: _nullableText(_locationController.text),
      color: int.parse(_selectedColor),
      description: _nullableText(_descriptionController.text),
      url: _nullableText(_linkController.text),
      icon: _selectedIcon,
      createdAt: widget.schedule?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      context.read<ScheduleBloc>().add(UpdateSchedule(schedule: schedule));
    } else {
      context.read<ScheduleBloc>().add(AddSchedule(schedule: schedule));
    }

    Navigator.pop(context);
    widget.onSaved?.call();
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 18),
                Text(
                  _isEditing ? 'Edit Jadwal' : 'Tambah Jadwal',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _nameController,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Nama jadwal',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama jadwal wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                _SectionLabel('Waktu Mulai'),
                const SizedBox(height: 8),
                _DateTimeRow(
                  dateLabel: _formatDate(_startDate),
                  timeLabel: _formatTime(_startTime),
                  onDateTap: () => _pickDate(isStart: true),
                  onTimeTap: () => _pickTime(isStart: true),
                ),
                const SizedBox(height: 14),
                _SectionLabel('Waktu Selesai'),
                const SizedBox(height: 8),
                _DateTimeRow(
                  dateLabel: _formatDate(_endDate),
                  timeLabel: _formatTime(_endTime),
                  onDateTap: () => _pickDate(isStart: false),
                  onTimeTap: () => _pickTime(isStart: false),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Lokasi (opsional)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  style: AppTextStyles.body,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Deskripsi (opsional)',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _linkController,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Tautan (opsional)',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionLabel('Perulangan'),
                const SizedBox(height: 8),
                RecurrencePickerWidget(
                  selectedRecurrence: _selectedRecurrence,
                  recurrenceEnd: _recurrenceEnd,
                  onRecurrenceChanged: (value) =>
                      setState(() => _selectedRecurrence = value),
                  onRecurrenceEndChanged: (value) =>
                      setState(() => _recurrenceEnd = value),
                ),
                const SizedBox(height: 16),
                _SectionLabel('Warna'),
                const SizedBox(height: 8),
                ColorPickerWidget(
                  selectedColor: _selectedColor,
                  onColorSelected: (value) =>
                      setState(() => _selectedColor = value),
                ),
                const SizedBox(height: 16),
                _SectionLabel('Ikon'),
                const SizedBox(height: 8),
                IconPickerWidget(
                  selectedIcon: _selectedIcon,
                  onIconSelected: (value) =>
                      setState(() => _selectedIcon = value),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      _isEditing ? 'Simpan Perubahan' : 'Tambah Jadwal',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  String _formatDate(DateTime date) =>
      DateFormat('d MMM yyyy', 'id_ID').format(date);

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

class _DateTimeRow extends StatelessWidget {
  final String dateLabel;
  final String timeLabel;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const _DateTimeRow({
    required this.dateLabel,
    required this.timeLabel,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PickerTile(
            label: dateLabel,
            icon: Icons.calendar_today_outlined,
            onTap: onDateTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PickerTile(
            label: timeLabel,
            icon: Icons.access_time_outlined,
            onTap: onTimeTap,
          ),
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.icon,
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
