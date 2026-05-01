import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionLabel('Kata Sandi'),
            const SizedBox(height: 8),
            _buildCard([
              _buildItem(
                icon: Icons.lock_outline_rounded,
                title: 'Ubah Password',
                subtitle: 'Terakhir diubah 2 bulan lalu',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionLabel('Keamanan Akun'),
            const SizedBox(height: 8),
            _buildCard([
              _buildSwitchItem(
                icon: Icons.fingerprint_rounded,
                title: 'Login Biometric',
                subtitle: 'Gunakan sidik jari untuk masuk',
                value: _biometricEnabled,
                onChanged: (v) => setState(() => _biometricEnabled = v),
              ),
              _divider(),
              _buildSwitchItem(
                icon: Icons.shield_outlined,
                title: '2-Factor Authentication',
                subtitle: 'Keamanan ekstra untuk akunmu',
                value: _twoFactorEnabled,
                onChanged: (v) => setState(() => _twoFactorEnabled = v),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionLabel('Sesi Aktif'),
            const SizedBox(height: 8),
            _buildCard([
              _buildItem(
                icon: Icons.devices_rounded,
                title: 'Perangkat Terhubung',
                subtitle: '2 perangkat aktif',
                onTap: () {},
              ),
              _divider(),
              _buildItem(
                icon: Icons.logout_rounded,
                title: 'Keluar dari Semua Perangkat',
                titleColor: Colors.red.shade500,
                iconColor: Colors.red.shade500,
                onTap: () {},
                showChevron: false,
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
      title: Text('Password & Keamanan', style: AppTextStyles.heading),
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

  Widget _buildItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor ?? AppColors.black),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: titleColor ?? AppColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.greyHandle),
          ],
        ),
      ),
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