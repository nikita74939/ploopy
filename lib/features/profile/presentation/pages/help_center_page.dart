import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  static final List<Map<String, String>> _faqs = [
    {
      'q': 'Bagaimana cara memulai belajar di Ploopy?',
      'a': 'Kamu bisa langsung menambahkan jadwal belajar dari halaman Beranda, lalu ikuti timeline harianmu!',
    },
    {
      'q': 'Apa itu Streak?',
      'a': 'Streak adalah jumlah hari berturut-turut kamu menyelesaikan aktivitas belajar. Jaga terus streakmu!',
    },
    {
      'q': 'Bagaimana cara mendapat Achievement?',
      'a': 'Lakukan aktivitas tertentu seperti streak 7 hari, menyelesaikan 10 aktivitas, dll untuk unlock achievement.',
    },
    {
      'q': 'Apakah data saya aman?',
      'a': 'Ya! Kami menggunakan enkripsi tingkat industri dan kamu bisa mengaktifkan biometric untuk keamanan ekstra.',
    },
    {
      'q': 'Bagaimana cara menghubungi support?',
      'a': 'Kamu bisa email ke support@ploopy.id atau kirim feedback melalui halaman Saran TPM.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionLabel('Hubungi Kami'),
            const SizedBox(height: 8),
            _buildContactCard(),
            const SizedBox(height: 24),
            _buildSectionLabel('Pertanyaan Umum'),
            const SizedBox(height: 8),
            _buildFaqCard(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Pusat Bantuan', style: AppTextStyles.heading),
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

  Widget _buildContactCard() {
    final actions = [
      (icon: Icons.email_outlined, label: 'Email'),
      (icon: Icons.chat_bubble_outline_rounded, label: 'Live Chat'),
      (icon: Icons.phone_outlined, label: 'Telepon'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'support@ploopy.id',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text('Respon dalam 1x24 jam', style: AppTextStyles.caption),
          const SizedBox(height: 14),
          Row(
            children: actions.map((a) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: a == actions.last ? 0 : 8,
                  ),
                  child: _ContactButton(icon: a.icon, label: a.label),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: _faqs.asMap().entries.map((e) {
          final isLast = e.key == _faqs.length - 1;
          return Column(
            children: [
              _FaqItem(faq: e.value),
              if (!isLast)
                const Divider(
                    height: 1, color: AppColors.greyBorder, indent: 14),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.black),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final Map<String, String> faq;

  const _FaqItem({required this.faq});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.faq['q']!,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _expanded ? 0.5 : 0,
                  child: const Icon(
                    Icons.expand_more_rounded,
                    size: 18,
                    color: AppColors.greyHint,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              Text(
                widget.faq['a']!,
                style: AppTextStyles.subtitle.copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}