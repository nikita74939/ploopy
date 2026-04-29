import 'package:flutter/material.dart';
import 'package:ploopy/features/home/presentation/widgets/home_greeting_header.dart';
import 'package:ploopy/features/home/presentation/widgets/learn_now_banner.dart';
import 'package:ploopy/features/home/presentation/widgets/mini_calendar.dart';
import 'package:ploopy/features/home/presentation/widgets/schedule_section.dart';
import '../../../../core/constants/schedule_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/session_service.dart';


class HomeBerandaPage extends StatefulWidget {
  const HomeBerandaPage({super.key});

  @override
  State<HomeBerandaPage> createState() => _HomeBerandaPageState();
}

class _HomeBerandaPageState extends State<HomeBerandaPage> {
  Map<String, dynamic>? _user;
  bool _loadingUser = true;
  int _selectedDay = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loadingUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    final name = _user?['name'] ?? 'Pengguna';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeGreetingHeader(name: name),
            const SizedBox(height: 20),
            MiniCalendar(
              selectedDay: _selectedDay,
              onDaySelected: (day) => setState(() => _selectedDay = day),
              onOpenCalendar: () {
                // TODO: navigate to calendar_page (coming soon)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.calendar_month_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Kalender lengkap segera hadir! 🗓️'),
                      ],
                    ),
                    backgroundColor: Colors.black87,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            LearnNowBanner(
              onTap: () {
                // TODO: navigate to desk page
              },
            ),
            const SizedBox(height: 24),
            ScheduleSection(
              scheduleItems: ScheduleDummyData.todayItems,
              taskItems: ScheduleDummyData.todayTasks, // add this to your dummy data
              onSeeAllSchedule: () {
                // TODO: navigate to schedule_page
              },
              onSeeAllTask: () {
                // TODO: navigate to task_page
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}