import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/neo_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyle.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Notifications'),
            _buildSwitchItem(
              icon: Icons.notifications,
              title: 'Push Notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchItem(
              icon: Icons.volume_up,
              title: 'Sound',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
            _buildSwitchItem(
              icon: Icons.vibration,
              title: 'Vibration',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Appearance'),
            _buildSwitchItem(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Security'),
            _buildSwitchItem(
              icon: Icons.fingerprint,
              title: 'Biometric Login',
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Data'),
            _buildMenuItem(
              icon: Icons.cloud_upload,
              title: 'Backup Data',
              onTap: () {
                // Backup data
              },
            ),
            _buildMenuItem(
              icon: Icons.cloud_download,
              title: 'Restore Data',
              onTap: () {
                // Restore data
              },
            ),
            _buildMenuItem(
              icon: Icons.delete_forever,
              title: 'Clear Cache',
              onTap: () {
                _showClearCacheDialog();
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('App'),
            _buildMenuItem(
              icon: Icons.star,
              title: 'Rate App',
              onTap: () {
                // Open app store
              },
            ),
            _buildMenuItem(
              icon: Icons.share,
              title: 'Share App',
              onTap: () {
                // Share app
              },
            ),
            _buildMenuItem(
              icon: Icons.policy,
              title: 'Privacy Policy',
              onTap: () {
                // Open privacy policy
              },
            ),
            _buildMenuItem(
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {
                // Open terms of service
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Ploopy v1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeoCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeoCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}