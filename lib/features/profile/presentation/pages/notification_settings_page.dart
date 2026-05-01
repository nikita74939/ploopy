import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionLabel('Channel Notifikasi'),
            const SizedBox(height: 8),
            _buildCard([
              _buildSwitchItem(
                icon: Icons.notifications_outlined,
                title: 'Push Notification',
                subtitle: 'Notifikasi langsung di perangkat',
                value: _pushEnabled,
                onChanged: (v) => setState(() => _pushEnabled = v),
              ),
              _divider(),
              _buildSwitchItem(
                icon: Icons.email_outlined,
                title: 'Email Notification',
                subtitle: 'Kirim rangkuman via email',
                value: _emailEnabled,
                onChanged: (v) => setState(() => _emailEnabled = v),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionLabel('Jenis Notifikasi'),
            const SizedBox(height: 8),
            _buildCard([
              _buildSwitchItem(
                icon: Icons.alarm_outlined,
                title: 'Pengingat Jadwal',
                subtitle: 'Ingetin jadwal belajarmu',
                value: _reminderEnabled,
                onChanged: (v) => setState(() => _reminderEnabled = v),
              ),
              _divider(),
              _buildSwitchItem(
                icon: Icons.local_fire_department_outlined,
                title: 'Streak Reminder',
                subtitle: 'Jangan sampai streak putus!',
                value: _streakEnabled,
                onChanged: (v) => setState(() => _streakEnabled = v),
              ),
              _divider(),
              _buildSwitchItem(
                icon: Icons.people_outline_rounded,
                title: 'Aktivitas Sosial',
                subtitle: 'Update dari teman-temanmu',
                value: _socialEnabled,
                onChanged: (v) => setState(() => _socialEnabled = v),
              ),
              _divider(),
              _buildSwitchItem(
                icon: Icons.emoji_events_outlined,
                title: 'Achievement Unlock',
                subtitle: 'Saat kamu dapat achievement baru',
                value: _achievementEnabled,
                onChanged: (v) => setState(() => _achievementEnabled = v),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Notifikasi', style: AppTextStyles.heading),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.greyBorder),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.black),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.black,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, color: AppColors.greyBorder, indent: 46);
}