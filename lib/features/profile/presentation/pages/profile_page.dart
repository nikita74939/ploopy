import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/profile_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/session_service.dart';
import '../../../auth/presentation/pages/auth_screen.dart';
import '../widgets/profile_achievement_section.dart';
import '../widgets/profile_activity_section.dart';
import 'edit_profile_page.dart';
import 'help_center_page.dart';
import 'notification_settings_page.dart';
import 'security_page.dart';
import 'tpm_feedback_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;
  bool _loading = true;

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
      _loading = false;
    });
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _showLogoutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            title: Text(
              'Keluar?',
              style: GoogleFonts.robotoMono(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            content: Text(
              'Kamu yakin mau keluar dari akunmu?',
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: AppColors.greyText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Batal',
                  style: GoogleFonts.robotoMono(color: AppColors.greyText),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Keluar',
                  style: GoogleFonts.robotoMono(
                    color: Colors.red.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
    if (confirm == true) _logout();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    final name = _user?['name'] ?? 'Pengguna';
    final email = _user?['email'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileTopSection(
              name: name,
              email: email,
              joinYear: ProfileDummyData.joinYear,
              totalFriends: ProfileDummyData.totalFriends,
              totalActivities: ProfileDummyData.totalActivities,
              currentStreak: ProfileDummyData.currentStreak,
              onSettingsTap: () => _showSettingsSheet(),
            ),
            const SizedBox(height: 24),
            _buildSection(child: _MonthlyHeatmap()),
            const SizedBox(height: 24),
            _buildSection(
              child: ProfileAchievementSection(
                achievements: ProfileDummyData.achievements,
                onSeeAll: () {},
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(child: ProfileActivitySection(onTapPost: (_) {})),
            const SizedBox(height: 32),
            _buildVersionFooter(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: child,
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _SettingsSheet(
            onEditProfile: () {
              Navigator.pop(context);
              _navigateTo(const EditProfilePage());
            },
            onSecurity: () {
              Navigator.pop(context);
              _navigateTo(const SecurityPage());
            },
            onNotification: () {
              Navigator.pop(context);
              _navigateTo(const NotificationSettingsPage());
            },
            onTpmFeedback: () {
              Navigator.pop(context);
              _navigateTo(const TpmFeedbackPage());
            },
            onHelpCenter: () {
              Navigator.pop(context);
              _navigateTo(const HelpCenterPage());
            },
            onLogout: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
    );
  }

  Widget _buildVersionFooter() {
    return Center(
      child: Text(
        'Ploopy v1.0.0',
        style: GoogleFonts.robotoMono(
          fontSize: 10,
          color: AppColors.greyHandle,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// TOP SECTION: avatar, name, stats
// ──────────────────────────────────────────────
class _ProfileTopSection extends StatelessWidget {
  final String name;
  final String email;
  final int joinYear;
  final int totalFriends;
  final int totalActivities;
  final int currentStreak;
  final VoidCallback onSettingsTap;

  const _ProfileTopSection({
    required this.name,
    required this.email,
    required this.joinYear,
    required this.totalFriends,
    required this.totalActivities,
    required this.currentStreak,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + settings
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const Spacer(),
              GestureDetector(
                onTap: onSettingsTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Name
          Text(
            name,
            style: GoogleFonts.robotoMono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: GoogleFonts.robotoMono(
              fontSize: 11,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 11,
                color: AppColors.greyHint,
              ),
              const SizedBox(width: 4),
              Text(
                'Bergabung $joinYear',
                style: GoogleFonts.robotoMono(
                  fontSize: 11,
                  color: AppColors.greyHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _StatChip(label: 'Teman', value: '$totalFriends'),
              const SizedBox(width: 8),
              _StatChip(label: 'Aktivitas', value: '$totalActivities'),
              const SizedBox(width: 8),
              _StatChip(
                label: 'Streak',
                value: '$currentStreak hari',
                accent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.greyBorder, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.robotoMono(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _StatChip({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent ? AppColors.black : AppColors.greyLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent ? Colors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              color: accent ? Colors.white70 : AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// MONTHLY HEATMAP (GitHub-style)
// ──────────────────────────────────────────────
class _MonthlyHeatmap extends StatelessWidget {
  // Dummy data: minutes studied per day this month
  static final Map<int, int> _studyMinutes = {
    1: 45,
    2: 0,
    3: 90,
    4: 120,
    5: 60,
    6: 30,
    7: 0,
    8: 150,
    9: 90,
    10: 60,
    11: 0,
    12: 45,
    13: 120,
    14: 180,
    15: 90,
    16: 60,
    17: 30,
    18: 0,
    19: 90,
    20: 120,
    21: 150,
    22: 60,
    23: 45,
    24: 0,
    25: 90,
    26: 120,
    27: 180,
    28: 90,
    29: 60,
    30: 45,
    31: 0,
  };

  Color _cellColor(int minutes) {
    if (minutes == 0) return AppColors.greyLight;
    if (minutes < 60) return const Color(0xFFD4D4D8);
    if (minutes < 120) return const Color(0xFF71717A);
    if (minutes < 180) return const Color(0xFF3F3F46);
    return AppColors.black;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Bulan Ini',
              style: GoogleFonts.robotoMono(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            Text(
              _monthName(now.month),
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildGrid(daysInMonth),
        const SizedBox(height: 10),
        _buildLegend(),
      ],
    );
  }

  Widget _buildGrid(int daysInMonth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 7;
        final cellSize = (constraints.maxWidth - (cols - 1) * 4) / cols;
        final _ = (daysInMonth / cols).ceil();

        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(daysInMonth, (i) {
            final day = i + 1;
            final minutes = _studyMinutes[day] ?? 0;
            return Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: _cellColor(minutes),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: GoogleFonts.robotoMono(
                  fontSize: 8,
                  color: minutes >= 120 ? Colors.white : AppColors.greyText,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLegend() {
    final levels = [
      (color: AppColors.greyLight, label: '0'),
      (color: const Color(0xFFD4D4D8), label: '<1j'),
      (color: const Color(0xFF71717A), label: '1-2j'),
      (color: const Color(0xFF3F3F46), label: '2-3j'),
      (color: AppColors.black, label: '>3j'),
    ];
    return Row(
      children: [
        Text(
          'Waktu belajar: ',
          style: GoogleFonts.robotoMono(fontSize: 9, color: AppColors.greyHint),
        ),
        ...levels.map(
          (l) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: l.color,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppColors.greyBorder, width: 0.5),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  l.label,
                  style: GoogleFonts.robotoMono(
                    fontSize: 9,
                    color: AppColors.greyHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      '',
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
    return names[month];
  }
}

// ──────────────────────────────────────────────
// SETTINGS BOTTOM SHEET
// ──────────────────────────────────────────────
class _SettingsSheet extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onSecurity;
  final VoidCallback onNotification;
  final VoidCallback onHelpCenter;
  final VoidCallback onTpmFeedback;
  final VoidCallback onLogout;

  const _SettingsSheet({
    required this.onEditProfile,
    required this.onSecurity,
    required this.onNotification,
    required this.onHelpCenter,
    required this.onTpmFeedback,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyHandle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Pengaturan',
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SheetItem(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profil',
            onTap: onEditProfile,
          ),
          _SheetItem(
            icon: Icons.lock_outline_rounded,
            label: 'Password & Keamanan',
            onTap: onSecurity,
          ),
          _SheetItem(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            onTap: onNotification,
          ),
          _SheetItem(
            icon: Icons.help_outline_rounded,
            label: 'Pusat Bantuan',
            onTap: onHelpCenter,
          ),
          _SheetItem(
            icon: Icons.rate_review_outlined,
            label: 'Saran & Kesan TPM',
            onTap: onTpmFeedback,
          ),
          const Divider(height: 1, color: Color(0xFFE4E4E7)),
          _SheetItem(
            icon: Icons.logout_rounded,
            label: 'Keluar',
            onTap: onLogout,
            isDestructive: true,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade500 : AppColors.black;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  color: color,
                  fontWeight: isDestructive ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (!isDestructive)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.greyHandle,
              ),
          ],
        ),
      ),
    );
  }
}
