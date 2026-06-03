import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/doodle_container.dart';
import '../../domain/entities/schedule_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../widgets/schedule_form_sheet.dart';

class DetailSchedulePage extends StatelessWidget {
  final ScheduleEntity schedule;

  const DetailSchedulePage({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    // color sudah bertipe int (ARGB) — langsung pakai Color()
    final color = Color(schedule.color);
    final iconData = _getIconData(schedule.icon);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit jadwal',
            onPressed: () => _navigateToEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
            tooltip: 'Hapus jadwal',
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ───────────────────────────────────────────────────
            DoodleContainer(
              color: color.withValues(alpha: 0.1),
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border,
                        width: AppStyle.borderWidth,
                      ),
                    ),
                    child: Icon(iconData, color: color, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    schedule.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Text(
                      _getRecurrenceLabel(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Detail Items ────────────────────────────────────────────────
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal',
              value: DateFormat(
                'EEEE, d MMMM yyyy',
                'id_ID',
              ).format(schedule.startTime),
              color: AppColors.primary,
            ),
            _DetailRow(
              icon: Icons.access_time_outlined,
              label: 'Waktu',
              value:
                  '${DateFormat('HH:mm').format(schedule.startTime)} – ${DateFormat('HH:mm').format(schedule.endTime)}  (${_getDuration()})',
              color: AppColors.primary,
            ),
            if (schedule.location?.isNotEmpty == true)
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Lokasi',
                value: schedule.location!,
                color: const Color(0xFFE53935),
              ),
            if (schedule.description?.isNotEmpty == true)
              _DetailRow(
                icon: Icons.notes_outlined,
                label: 'Deskripsi',
                value: schedule.description!,
                color: AppColors.greenAccent,
              ),
            if (schedule.url?.isNotEmpty == true)
              _DetailRow(
                icon: Icons.link_outlined,
                label: 'Tautan',
                value: schedule.url!,
                color: Colors.blue,
                isLink: true,
                onTap: () => _launchUrl(schedule.url!),
              ),
            if (schedule.recurrenceEnd != null && schedule.recurrence != 'None')
              _DetailRow(
                icon: Icons.event_repeat_outlined,
                label: 'Batas Perulangan',
                value: DateFormat(
                  'd MMMM yyyy',
                  'id_ID',
                ).format(schedule.recurrenceEnd!),
                color: Colors.purple,
              ),

            const SizedBox(height: 12),
            Center(
              child: Text(
                'Dibuat ${DateFormat('d MMMM yyyy, HH:mm').format(schedule.createdAt)}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Action Buttons ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: DoodleContainer(
                    color: AppColors.textMain,
                    onTap: () => _navigateToEdit(context),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DoodleContainer(
                    color: const Color(0xFFFFEBEE),
                    onTap: () => _showDeleteDialog(context),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFE53935),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hapus',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFE53935),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────

  void _navigateToEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ScheduleBloc>(),
        child: ScheduleFormSheet(
          userId: schedule.userId,
          schedule: schedule,
          onSaved: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _getRecurrenceLabel() {
    switch (schedule.recurrence) {
      case 'Daily':
        return 'Setiap Hari';
      case 'Weekly':
        return 'Setiap Minggu';
      case 'Monthly':
        return 'Setiap Bulan';
      default:
        return 'Sekali Saja';
    }
  }

  String _getDuration() {
    final diff = schedule.endTime.difference(schedule.startTime);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}j';
    return '${hours}j ${minutes}m';
  }

  IconData _getIconData(String? icon) {
    switch (icon) {
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'book':
        return Icons.menu_book;
      case 'sports':
        return Icons.sports;
      case 'music':
        return Icons.music_note;
      case 'food':
        return Icons.restaurant;
      case 'health':
        return Icons.favorite;
      case 'travel':
        return Icons.flight;
      case 'social':
        return Icons.people;
      case 'game':
        return Icons.sports_esports;
      case 'meeting':
        return Icons.groups;
      default:
        return Icons.event;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppStyle.borderRadius),
            border: Border.all(
              color: AppColors.border,
              width: AppStyle.borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.border,
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hapus Jadwal?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yakin mau hapus "${schedule.name}"? Aksi ini tidak bisa dibatalkan.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DoodleContainer(
                      color: Colors.white,
                      onTap: () => Navigator.pop(ctx),
                      child: Center(
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DoodleContainer(
                      color: const Color(0xFFE53935),
                      onTap: () {
                        // userId diperlukan agar bloc me-reload jadwal yang benar
                        context.read<ScheduleBloc>().add(
                          DeleteSchedule(
                            id: schedule.id,
                            userId: schedule.userId,
                          ),
                        );
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: Text(
                          'Hapus',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Detail Row Widget ────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLink;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLink = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: isLink
            ? () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tautan disalin!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    backgroundColor: AppColors.textMain,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppStyle.borderRadius,
                      ),
                      side: const BorderSide(
                        color: AppColors.border,
                        width: AppStyle.borderWidth,
                      ),
                    ),
                    margin: const EdgeInsets.all(16),
                    elevation: 0,
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppStyle.borderRadius),
            border: Border.all(
              color: AppColors.border,
              width: AppStyle.borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.border,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isLink ? Colors.blue : AppColors.textMain,
                        decoration: isLink
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
