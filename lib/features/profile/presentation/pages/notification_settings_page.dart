import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/profile_menu_item.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _reminderEnabled = true;
  bool _streakEnabled = true;
  bool _socialEnabled = true;
  bool _achievementEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              const SizedBox(height: 20),
              _buildSectionTitle('📬', 'Channel Notifikasi'),
              const SizedBox(height: 12),
              _buildCard([
                _buildSwitch(
                  icon: Icons.notifications_rounded,
                  color: const Color(0xFF4D96FF),
                  title: 'Push Notification',
                  subtitle: 'Notifikasi langsung di perangkat',
                  value: _pushEnabled,
                  onChanged: (v) => setState(() => _pushEnabled = v),
                ),
                _divider(),
                _buildSwitch(
                  icon: Icons.email_outlined,
                  color: const Color(0xFFFFD166),
                  title: 'Email Notification',
                  subtitle: 'Kirim rangkuman via email',
                  value: _emailEnabled,
                  onChanged: (v) => setState(() => _emailEnabled = v),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('🎯', 'Jenis Notifikasi'),
              const SizedBox(height: 12),
              _buildCard([
                _buildSwitch(
                  icon: Icons.alarm_rounded,
                  color: const Color(0xFFFF8C42),
                  title: 'Pengingat Jadwal',
                  subtitle: 'Ingetin jadwal belajarmu',
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                ),
                _divider(),
                _buildSwitch(
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.red.shade400,
                  title: 'Streak Reminder',
                  subtitle: 'Jangan sampai streak putus! 🔥',
                  value: _streakEnabled,
                  onChanged: (v) => setState(() => _streakEnabled = v),
                ),
                _divider(),
                _buildSwitch(
                  icon: Icons.people_rounded,
                  color: const Color(0xFF6BCB77),
                  title: 'Aktivitas Sosial',
                  subtitle: 'Update dari teman-temanmu',
                  value: _socialEnabled,
                  onChanged: (v) => setState(() => _socialEnabled = v),
                ),
                _divider(),
                _buildSwitch(
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFB79CED),
                  title: 'Achievement Unlock',
                  subtitle: 'Saat kamu dapat achievement baru',
                  value: _achievementEnabled,
                  onChanged: (v) => setState(() => _achievementEnabled = v),
                ),
              ]),
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
        'Notifikasi',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E9), Color(0xFFFFE8D6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tetap Update!',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Atur notifikasi biar kamu nggak ketinggalan info penting',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String emoji, String title) {
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

  Widget _buildSwitch({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ProfileMenuItem(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      showChevron: false,
      trailing: Switch.adaptive(
        value: value,
        activeColor: color,
        onChanged: onChanged,
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