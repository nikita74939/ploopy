// File: /schedule/schedule_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploopy/core/theme/app_colors.dart';

class ScheduleDetailPage extends StatelessWidget {
  final Map<String, dynamic> schedule;

  const ScheduleDetailPage({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final title = schedule['title'] as String? ?? '';
    final location = schedule['location'] as String? ?? '';
    final description = schedule['description'] as String? ?? '';
    final repeat = schedule['repeat'] as String? ?? 'Tidak Berulang';
    final startDate = schedule['startDate'] as DateTime?;
    final startTime = schedule['startTime'] as TimeOfDay?;
    final endTime = schedule['endTime'] as TimeOfDay?;
    final duration = schedule['duration'] as String? ?? '';
    final color = schedule['color'] as Color? ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Icon & Title Card ──
                    _buildMainCard(title, color),
                    const SizedBox(height: 20),

                    // ── Date & Time ──
                    _buildSectionTitle('Waktu'),
                    const SizedBox(height: 10),
                    _buildDateTimeCard(startDate, startTime, endTime, duration),
                    const SizedBox(height: 20),

                    // ── Location ──
                    if (location.isNotEmpty) ...[
                      _buildSectionTitle('Tempat'),
                      const SizedBox(height: 10),
                      _buildInfoCard(
                        icon: Icons.location_on_outlined,
                        content: location,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Repeat ──
                    _buildSectionTitle('Perulangan'),
                    const SizedBox(height: 10),
                    _buildInfoCard(icon: Icons.repeat_rounded, content: repeat),
                    const SizedBox(height: 20),

                    // ── Description ──
                    if (description.isNotEmpty) ...[
                      _buildSectionTitle('Deskripsi'),
                      const SizedBox(height: 10),
                      _buildDescriptionCard(description),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.black,
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.black,
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Navigate to edit page
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: Colors.red.shade400,
            onPressed: () {
              HapticFeedback.lightImpact();
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Hapus Jadwal',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'Apakah kamu yakin ingin menghapus jadwal ini?',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: AppColors.greyText),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Jadwal berhasil dihapus',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      backgroundColor: AppColors.black,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Hapus',
                  style: GoogleFonts.poppins(color: Colors.red.shade400),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildMainCard(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyBorder),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              schedule['icon'] as IconData? ?? Icons.event_rounded,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(
    DateTime? startDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String duration,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          // Date
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.greyText,
                    ),
                  ),
                  Text(
                    _formatDate(startDate ?? DateTime.now()),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Time
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                ), // ← Close BoxDecoration properly
                child: const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waktu',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.greyText,
                      ),
                    ),
                    Text(
                      '${_formatTime(startTime)} - ${_formatTime(endTime)} ($duration)',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.greyText,
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String content}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Text(
        description,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.black,
          height: 1.5,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }
}
