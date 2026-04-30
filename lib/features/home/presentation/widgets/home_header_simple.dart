import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class HomeHeaderSimple extends StatelessWidget {
  final String dateString;
  final String studyTime;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onStartTap;

  const HomeHeaderSimple({
    super.key,
    required this.dateString,
    required this.studyTime,
    this.onCalendarTap,
    this.onNotificationTap,
    this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Baris 1: Calendar icon | Tanggal | Notif icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon Calendar
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCalendarTap?.call();
                },
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),

              // Tanggal
              Text(
                dateString,
                style: GoogleFonts.robotoMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),

              // Icon Notifikasi
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onNotificationTap?.call();
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    // Badge
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          '3',
                          style: GoogleFonts.robotoMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Baris 2: Study time & Start button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 10),
              Text(
                studyTime,
                style: GoogleFonts.robotoMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 20),
              // Tombol Start
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  // Navigate ke study desk
                  Navigator.pushNamed(context, '/study-desk');
                  onStartTap?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'start',
                        style: GoogleFonts.robotoMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
