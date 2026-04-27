import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../shared/services/notification_service.dart';
import '../widgets/pomodoro_controls.dart';
import '../widgets/pomodoro_mode_selector.dart';
import '../widgets/pomodoro_settings_sheet.dart';
import '../widgets/pomodoro_stats_card.dart';
import '../widgets/pomodoro_timer_display.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  PomodoroSettings _settings = const PomodoroSettings();
  PomodoroMode _mode = PomodoroMode.focus;
  Timer? _timer;

  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;

  // Stats
  int _completedSessions = 0;
  int _totalFocusMinutes = 0;

  @override
  void initState() {
    super.initState();
    _updateTimerForMode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  int _getMinutesForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return _settings.focusMinutes;
      case PomodoroMode.shortBreak:
        return _settings.shortBreakMinutes;
      case PomodoroMode.longBreak:
        return _settings.longBreakMinutes;
    }
  }

  Color _getColorForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return const Color(0xFFFF6B6B);
      case PomodoroMode.shortBreak:
        return const Color(0xFF6BCB77);
      case PomodoroMode.longBreak:
        return const Color(0xFF4D96FF);
    }
  }

  String _getLabelForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return '🎯 WAKTU FOKUS';
      case PomodoroMode.shortBreak:
        return '☕ ISTIRAHAT';
      case PomodoroMode.longBreak:
        return '😴 ISTIRAHAT PANJANG';
    }
  }

  void _updateTimerForMode() {
    final minutes = _getMinutesForMode(_mode);
    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = minutes * 60;
    });
  }

  void _changeMode(PomodoroMode mode) {
    if (_isRunning) {
      _showConfirmDialog(
        title: 'Ganti Mode?',
        content: 'Timer yang sedang berjalan akan direset',
        onConfirm: () {
          _resetTimer();
          setState(() => _mode = mode);
          _updateTimerForMode();
        },
      );
    } else {
      setState(() => _mode = mode);
      _updateTimerForMode();
    }
  }

  void _startTimer() {
    if (_isRunning) return;

    WakelockPlus.enable();
    HapticFeedback.mediumImpact();

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _onTimerComplete();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    WakelockPlus.disable();
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _skipTimer() {
    _showConfirmDialog(
      title: 'Skip ke Sesi Berikutnya?',
      content: 'Timer saat ini akan dilewati',
      onConfirm: _onTimerComplete,
    );
  }

  void _onTimerComplete() {
    _timer?.cancel();
    WakelockPlus.disable();
    HapticFeedback.heavyImpact();

    // Kirim notifikasi
    switch (_mode) {
      case PomodoroMode.focus:
        NotificationService.showFocusComplete();
        _completedSessions++;
        _totalFocusMinutes += _settings.focusMinutes;
        break;
      case PomodoroMode.shortBreak:
        NotificationService.showBreakComplete();
        break;
      case PomodoroMode.longBreak:
        NotificationService.showLongBreakComplete();
        break;
    }

    // Auto-switch mode
    final nextMode = _getNextMode();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _mode = nextMode;
    });
    _updateTimerForMode();

    // Show completion dialog
    _showCompletionDialog();
  }

  PomodoroMode _getNextMode() {
    if (_mode == PomodoroMode.focus) {
      if (_completedSessions > 0 &&
          _completedSessions % _settings.sessionsBeforeLongBreak == 0) {
        return PomodoroMode.longBreak;
      }
      return PomodoroMode.shortBreak;
    }
    return PomodoroMode.focus;
  }

  void _showCompletionDialog() {
    final isBreak = _mode != PomodoroMode.focus;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isBreak ? '🎉' : '💪',
                style: const TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 12),
              Text(
                isBreak ? 'Sesi Fokus Selesai!' : 'Waktunya Fokus!',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isBreak
                    ? 'Kerja bagus! Istirahat dulu ya 😌'
                    : 'Yuk lanjut sesi fokus berikutnya!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _startTimer();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getColorForMode(_mode),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Mulai ${isBreak ? "Istirahat" : "Fokus"}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Nanti aja',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getColorForMode(_mode),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Ya',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings() async {
    final newSettings = await PomodoroSettingsSheet.show(context, _settings);
    if (newSettings != null) {
      setState(() => _settings = newSettings);
      if (!_isRunning) _updateTimerForMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _getColorForMode(_mode);
    final currentLabel = _getLabelForMode(_mode);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              PomodoroModeSelector(
                selectedMode: _mode,
                onChanged: _changeMode,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PomodoroTimerDisplay(
                  totalSeconds: _totalSeconds,
                  remainingSeconds: _remainingSeconds,
                  color: currentColor,
                  modeLabel: currentLabel,
                ),
              ),
              const SizedBox(height: 20),
              PomodoroControls(
                isRunning: _isRunning,
                isPaused: _isPaused,
                accentColor: currentColor,
                onStart: _startTimer,
                onPause: _pauseTimer,
                onResume: _resumeTimer,
                onReset: _resetTimer,
                onSkip: _skipTimer,
              ),
              const SizedBox(height: 24),
              PomodoroStatsCard(
                completedSessions: _completedSessions,
                totalFocusMinutes: _totalFocusMinutes,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey.shade50,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Pomodoro',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.tune_rounded, color: Colors.grey.shade700),
          onPressed: _openSettings,
          tooltip: 'Pengaturan',
        ),
      ],
    );
  }
}