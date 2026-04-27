import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/profile_menu_item.dart';

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
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('🔐', 'Kata Sandi'),
              const SizedBox(height: 12),
              _buildCard([
                ProfileMenuItem(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFF4D96FF),
                  title: 'Ubah Password',
                  subtitle: 'Terakhir diubah 2 bulan lalu',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('🔒', 'Keamanan Akun'),
              const SizedBox(height: 12),
              _buildCard([
                ProfileMenuItem(
                  icon: Icons.fingerprint_rounded,
                  iconColor: const Color(0xFFFF8C42),
                  title: 'Login Biometric',
                  subtitle: 'Gunakan sidik jari untuk masuk',
                  onTap: () {},
                  showChevron: false,
                  trailing: Switch.adaptive(
                    value: _biometricEnabled,
                    activeColor: const Color(0xFFFF8C42),
                    onChanged: (v) => setState(() => _biometricEnabled = v),
                  ),
                ),
                _divider(),
                ProfileMenuItem(
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF6BCB77),
                  title: '2-Factor Authentication',
                  subtitle: 'Keamanan ekstra untuk akunmu',
                  onTap: () {},
                  showChevron: false,
                  trailing: Switch.adaptive(
                    value: _twoFactorEnabled,
                    activeColor: const Color(0xFF6BCB77),
                    onChanged: (v) => setState(() => _twoFactorEnabled = v),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('📱', 'Sesi Aktif'),
              const SizedBox(height: 12),
              _buildCard([
                ProfileMenuItem(
                  icon: Icons.devices_rounded,
                  iconColor: const Color(0xFFB79CED),
                  title: 'Perangkat Terhubung',
                  subtitle: '2 perangkat aktif',
                  onTap: () {},
                ),
                _divider(),
                ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  iconColor: Colors.red.shade400,
                  title: 'Keluar dari Semua Perangkat',
                  titleColor: Colors.red.shade400,
                  onTap: () {},
                  showChevron: false,
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
        'Password & Keamanan',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
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