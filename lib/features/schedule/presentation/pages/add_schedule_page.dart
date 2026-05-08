import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/doodle_container.dart';
import '../../../../core/widgets/neo_container.dart';
import '../../domain/entities/schedule_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../widgets/color_picker_widget.dart';
import '../widgets/icon_picker_widget.dart';
import '../widgets/recurrence_picker_widget.dart';

// Ganti dengan cara yang sesuai di proyekmu untuk mendapatkan userId aktif
const _kCurrentUserId = '1';

class AddSchedulePage extends StatefulWidget {
  /// Jika [schedule] tidak null, halaman akan berjalan dalam mode edit.
  final ScheduleEntity? schedule;

  const AddSchedulePage({super.key, this.schedule});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  String _selectedRecurrence = 'None';
  DateTime? _recurrenceEnd;

  // Color disimpan sebagai hex-string agar cocok dengan ColorPickerWidget
  String _selectedColor = '0xFF6C63FF';
  String _selectedIcon = 'event';

  bool get _isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final s = widget.schedule;

    if (s != null) {
      // Mode edit — isi dari entity
      _nameController.text = s.name;
      _locationController.text = s.location ?? '';
      _descriptionController.text = s.description ?? '';
      _linkController.text = s.url ?? '';
      _startDate = s.startTime;
      _startTime = TimeOfDay.fromDateTime(s.startTime);
      _endDate = s.endTime;
      _endTime = TimeOfDay.fromDateTime(s.endTime);
      _selectedRecurrence = s.recurrence;
      _recurrenceEnd = s.recurrenceEnd;
      // color dari entity adalah int (ARGB), konversi ke hex-string
      _selectedColor =
          '0x${s.color.toRadixString(16).toUpperCase().padLeft(8, '0')}';
      _selectedIcon = s.icon;
    } else {
      // Mode tambah
      _startDate = now;
      _startTime = TimeOfDay.fromDateTime(now);
      _endDate = now;
      _endTime = TimeOfDay(
        hour: (now.hour + 1).clamp(0, 23),
        minute: now.minute,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // ─── Save / Update ──────────────────────────────────────────────────────────

  void _saveSchedule() {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu selesai harus setelah waktu mulai')),
      );
      return;
    }

    final colorInt = int.parse(_selectedColor);

    if (_isEditing) {
      // UpdateSchedule — pertahankan id & createdAt dari entity asli
      final updated = widget.schedule!.copyWith(
        name: _nameController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        url: _linkController.text.trim().isEmpty
            ? null
            : _linkController.text.trim(),
        color: colorInt,
        icon: _selectedIcon,
        recurrence: _selectedRecurrence,
        recurrenceEnd: _selectedRecurrence == 'None' ? null : _recurrenceEnd,
      );
      context.read<ScheduleBloc>().add(UpdateSchedule(schedule: updated));
    } else {
      // AddSchedule — buat entity baru (id = 0, Isar akan auto-increment)
      final newEntity = ScheduleEntity(
        id: 0,
        userId: _kCurrentUserId,
        name: _nameController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        url: _linkController.text.trim().isEmpty
            ? null
            : _linkController.text.trim(),
        color: colorInt,
        icon: _selectedIcon,
        recurrence: _selectedRecurrence,
        recurrenceEnd: _selectedRecurrence == 'None' ? null : _recurrenceEnd,
        createdAt: DateTime.now(),
      );
      context.read<ScheduleBloc>().add(AddSchedule(schedule: newEntity));
    }

    Navigator.pop(context);
  }

  // ─── Date / Time Pickers ────────────────────────────────────────────────────

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
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

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) =>
      DateFormat('d MMM yyyy', 'id_ID').format(dt);

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Jadwal' : 'Tambah Jadwal',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyle.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Nama Jadwal ───────────────────────────────────────────────
              CustomTextField(
                controller: _nameController,
                hintText: 'Nama Jadwal',
                prefixIcon: Icons.event,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // ── Waktu Mulai ───────────────────────────────────────────────
              _SectionLabel(label: 'Waktu Mulai'),
              const SizedBox(height: 8),
              _DateTimeRow(
                dateLabel: _formatDate(_startDate),
                timeLabel: _formatTime(_startTime),
                onDateTap: () => _pickDate(isStart: true),
                onTimeTap: () => _pickTime(isStart: true),
              ),
              const SizedBox(height: 16),

              // ── Waktu Selesai ─────────────────────────────────────────────
              _SectionLabel(label: 'Waktu Selesai'),
              const SizedBox(height: 8),
              _DateTimeRow(
                dateLabel: _formatDate(_endDate),
                timeLabel: _formatTime(_endTime),
                onDateTap: () => _pickDate(isStart: false),
                onTimeTap: () => _pickTime(isStart: false),
              ),
              const SizedBox(height: 20),

              // ── Lokasi ────────────────────────────────────────────────────
              CustomTextField(
                controller: _locationController,
                hintText: 'Lokasi (opsional)',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              // ── Deskripsi ─────────────────────────────────────────────────
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Deskripsi (opsional)',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // ── Link ──────────────────────────────────────────────────────
              CustomTextField(
                controller: _linkController,
                hintText: 'Tautan (opsional)',
                prefixIcon: Icons.link,
              ),
              const SizedBox(height: 20),

              // ── Perulangan ────────────────────────────────────────────────
              _SectionLabel(label: 'Perulangan'),
              const SizedBox(height: 8),
              RecurrencePickerWidget(
                selectedRecurrence: _selectedRecurrence,
                recurrenceEnd: _recurrenceEnd,
                onRecurrenceChanged: (v) =>
                    setState(() => _selectedRecurrence = v),
                onRecurrenceEndChanged: (v) =>
                    setState(() => _recurrenceEnd = v),
              ),
              const SizedBox(height: 24),

              // ── Warna ─────────────────────────────────────────────────────
              _SectionLabel(label: 'Warna'),
              const SizedBox(height: 8),
              ColorPickerWidget(
                selectedColor: _selectedColor,
                onColorSelected: (v) => setState(() => _selectedColor = v),
              ),
              const SizedBox(height: 24),

              // ── Ikon ──────────────────────────────────────────────────────
              _SectionLabel(label: 'Ikon'),
              const SizedBox(height: 8),
              IconPickerWidget(
                selectedIcon: _selectedIcon,
                onIconSelected: (v) => setState(() => _selectedIcon = v),
              ),
              const SizedBox(height: 32),

              // ── Tombol Simpan ─────────────────────────────────────────────
              NeoButton(
                text: _isEditing ? 'Perbarui Jadwal' : 'Simpan Jadwal',
                onPressed: _saveSchedule,
                textColor: Colors.white,
                backgroundColor: AppColors.primary,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
      ),
    );
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
        Expanded(child: _PickerTile(label: dateLabel, icon: Icons.calendar_today_outlined, onTap: onDateTap)),
        const SizedBox(width: 12),
        Expanded(child: _PickerTile(label: timeLabel, icon: Icons.access_time_outlined, onTap: onTimeTap)),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
          border: Border.all(color: AppColors.border, width: AppStyle.borderWidth),
          boxShadow: const [
            BoxShadow(color: AppColors.border, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}