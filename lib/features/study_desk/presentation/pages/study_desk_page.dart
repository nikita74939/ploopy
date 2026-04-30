// lib/features/study_desk/presentation/pages/study_desk_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/schedule_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/study_session.dart';
import '../../services/study_session_service.dart';
import '../widgets/study_timer_display.dart';
import '../widgets/focus_session_timer.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/study_schedule_section.dart';

class StudyDeskPage extends StatefulWidget {
  const StudyDeskPage({super.key});

  @override
  State<StudyDeskPage> createState() => _StudyDeskPageState();
}

class _StudyDeskPageState extends State<StudyDeskPage> {
  final StudySessionService _service = StudySessionService();
  late StreamSubscription _subscription;

  StudySession _session = StudySession.initial();
  String _currentInsight = '';
  String _currentEmoji = '📚';
  String _currentMood = 'Fokus';

  static const List<Map<String, String>> _insights = [
    {'hour': '0', 'emoji': '📚', 'mood': 'Siap belajar!', 'text': 'Hari baru, kesempatan baru! Mulai dengan target kecil dulu ya~'},
    {'hour': '1', 'emoji': '🔥', 'mood': 'Semangat!', 'text': '1 jam sudah! Konsistensi kunci sukses. Terus belajar ya! 💪'},
    {'hour': '2', 'emoji': '⚡', 'mood': 'Gas!', 'text': '2 jam! Otak kamu makin panas nih. Istirahat sebentar dulu ga sih?'},
    {'hour': '3', 'emoji': '🚀', 'mood': 'Super!', 'text': '3 jam tercapai! Kamu luar biasa. Jangan lupa makan & minum!'},
    {'hour': '4', 'emoji': '🏆', 'mood': 'Champion!', 'text': '4 jam! Level up! Kamu udah di level productivity yang tinggi.'},
    {'hour': '5', 'emoji': '👑', 'mood': 'Legend!', 'text': '5 jam?! Kamu beast! Istirahat penting ya, jangan burnout.'},
    {'hour': '6', 'emoji': '🌟', 'mood': 'Epic!', 'text': '6 jam belajar! Semoga ilmu yang kamu dapat bermanfaat~'},
  ];

  @override
  void initState() {
    super.initState();
    _subscription = _service.sessionStream.listen(_onSessionUpdate);
    _updateInsight();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _onSessionUpdate(StudySession session) {
    if (!mounted) return;
    setState(() => _session = session);
    _updateInsight();
  }

  void _updateInsight() {
    final hours = _service.totalStudyHours;
    final insightData = _insights[hours.clamp(0, _insights.length - 1)];
    setState(() {
      _currentEmoji = insightData['emoji']!;
      _currentMood = insightData['mood']!;
      _currentInsight = insightData['text']!;
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onStart() => _service.startSession();
  void _onPause() => _service.pauseSession();

  void _onToolsTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/tools');
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = _session.totalDuration + _session.sessionDuration;

    return Scaffold(
      backgroundColor: AppColors.greyLighter,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  StudyTimerDisplay(
                    totalTime: _formatDuration(totalDuration),
                    sessionTime: _formatDuration(_session.sessionDuration),
                    isFocusing: _session.state == StudyState.focusing,
                    onToolsTap: _onToolsTap,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Focus session timer card
                    FocusSessionTimer(
                      sessionTime: _formatDuration(_session.sessionDuration),
                      state: _session.state,
                      onStart: _onStart,
                      onPause: _onPause,
                      emoji: _currentEmoji,
                      mood: _currentMood,
                    ),

                    const SizedBox(height: 16),

                    // AI Insight card
                    AiInsightCard(
                      insight: _currentInsight,
                      onRefresh: _updateInsight,
                    ),

                    const SizedBox(height: 24),

                    // Schedule section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: StudyScheduleSection(
                        scheduleItems: ScheduleDummyData.todayItems,
                        taskItems: ScheduleDummyData.todayTasks,
                        onSeeAllSchedule: () {},
                        onSeeAllTask: () {},
                      ),
                    ),

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
}