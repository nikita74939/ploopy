import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_menu_item.dart';

class ProfileSettingsSection extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onSecurity;
  final VoidCallback onNotification;
  final VoidCallback onHelpCenter;
  final VoidCallback onTpmFeedback;
  final VoidCallback onLogout;

  const ProfileSettingsSection({
    super.key,
    required this.onEditProfile,
    required this.onSecurity,
    required this.onNotification,
    required this.onHelpCenter,
    required this.onTpmFeedback,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('⚙️', 'Pengaturan Akun'),
        const SizedBox(height: 12),
        _buildCard([
          ProfileMenuItem(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF4D96FF),
            title: 'Edit Profil',
            subtitle: 'Ubah nama, foto, dan bio',
            onTap: onEditProfile,
          ),
          _divider(),
          ProfileMenuItem(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFF6BCB77),
            title: 'Password & Keamanan',
            subtitle: 'Password, biometric, 2FA',
            onTap: onSecurity,
          ),
          _divider(),
          ProfileMenuItem(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFFFFD166),
            title: 'Notifikasi',
            subtitle: 'Atur preferensi notifikasi',
            onTap: onNotification,
          ),
        ]),
        const SizedBox(height: 20),
        _buildHeader('💬', 'Dukungan'),
        const SizedBox(height: 12),
        _buildCard([
          ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            iconColor: const Color(0xFFB79CED),
            title: 'Pusat Bantuan',
            subtitle: 'FAQ & bantuan pengguna',
            onTap: onHelpCenter,
          ),
          _divider(),
          ProfileMenuItem(
            icon: Icons.rate_review_outlined,
            iconColor: const Color(0xFFFF8C42),
            title: 'Saran & Kesan TPM',
            subtitle: 'Kirim feedback untuk mata kuliah',
            onTap: onTpmFeedback,
          ),
        ]),
        const SizedBox(height: 20),
        _buildCard([
          ProfileMenuItem(
            icon: Icons.logout_rounded,
            iconColor: Colors.red.shade400,
            title: 'Keluar',
            titleColor: Colors.red.shade400,
            onTap: onLogout,
            showChevron: false,
          ),
        ]),
      ],
    );
  }

  Widget _buildHeader(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Text(emoji, style: GoogleFonts.poppins(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade100,
      indent: 64,
    );
  }
}