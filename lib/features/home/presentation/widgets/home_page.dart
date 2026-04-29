import 'package:flutter/material.dart';
import '../../../../core/constants/schedule_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/session_service.dart';
import 'home_greeting_header.dart';
import 'learn_now_banner.dart';
import 'mini_calendar.dart';
import 'schedule_timeline.dart';
import 'package:flutter/services.dart';
import 'package:ploopy/features/notification/presentation/pages/notification_page.dart';

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
            HomeGreetingHeader(
              name : name, 
              unreadNotifCount : 3,
              onNotifTap :(){
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              }
            ),
            const SizedBox(height: 20),
            MiniCalendar(
              selectedDay: _selectedDay,
              onDaySelected: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: 20),
            LearnNowBanner(
              onTap: () {
                // TODO: navigate to desk page
              },
            ),
            const SizedBox(height: 24),
            ScheduleTimeline(
              items: ScheduleDummyData.todayItems,
              onSeeAll: () {
                // TODO: navigate to full schedule
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}