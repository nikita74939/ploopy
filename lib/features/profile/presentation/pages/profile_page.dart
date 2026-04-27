import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/profile_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/session_service.dart';
import '../../../auth/presentation/pages/auth_screen.dart';
import '../widgets/profile_achievement_section.dart';
import '../widgets/profile_activity_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_settings_section.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_streak_card.dart';
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
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Text('👋', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  'Keluar?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Text(
              'Kamu yakin mau keluar dari akunmu?',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Keluar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    final name = _user?['name'] ?? 'Pengguna';
    final email = _user?['email'] ?? '';

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeader(
            name: name,
            email: email,
            joinYear: ProfileDummyData.joinYear,
            onEditPressed: () => _navigateTo(const EditProfilePage()),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ProfileStatsCard(
                  totalFriends: ProfileDummyData.totalFriends,
                  totalActivities: ProfileDummyData.totalActivities,
                  currentStreak: ProfileDummyData.currentStreak,
                ),
                const SizedBox(height: 16),
                ProfileStreakCard(
                  currentStreak: ProfileDummyData.currentStreak,
                  longestStreak: ProfileDummyData.longestStreak,
                ),
                const SizedBox(height: 20),
                ProfileAchievementSection(
                  achievements: ProfileDummyData.achievements,
                  onSeeAll: () {},
                ),
                const SizedBox(height: 20),
                ProfileActivitySection(
                  activities: ProfileDummyData.feedPosts,
                  onCreatePost: () {
                    // TODO: navigate to create post page
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '📝 Fitur buat post coming soon!',
                          style: GoogleFonts.poppins(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  onSeeAll: () {
                    // TODO: navigate to all activities
                  },
                ),
                const SizedBox(height: 24),
                ProfileSettingsSection(
                  onEditProfile: () => _navigateTo(const EditProfilePage()),
                  onSecurity: () => _navigateTo(const SecurityPage()),
                  onNotification:
                      () => _navigateTo(const NotificationSettingsPage()),
                  onHelpCenter: () => _navigateTo(const HelpCenterPage()),
                  onTpmFeedback: () => _navigateTo(const TpmFeedbackPage()),
                  onLogout: _showLogoutDialog,
                ),
                const SizedBox(height: 24),
                _buildAppVersion(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersion() {
    return Column(
      children: [
        Text(
          '🎓 Ploopy',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Versi 1.0.0',
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}
