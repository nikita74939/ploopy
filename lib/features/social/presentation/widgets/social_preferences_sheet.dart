import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SocialPreferencesSheet extends StatefulWidget {
  const SocialPreferencesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SocialPreferencesSheet(),
    );
  }

  @override
  State<SocialPreferencesSheet> createState() => _SocialPreferencesSheetState();
}

class _SocialPreferencesSheetState extends State<SocialPreferencesSheet> {
  bool _showLocation = true;
  bool _showActivity = true;
  bool _showEvent = true;
  bool _pushNotifications = true;
  String _studyPreference = 'Semua';

  final List<String> _studyOptions = ['Semua', 'Kampus', 'Online', 'Pribadi'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            const Divider(height: 1, color: AppColors.greyBorder),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Lokasi'),
                    const SizedBox(height: 8),
                    _buildSwitchTile(
                      title: 'Tampilkan lokasi',
                      subtitle: 'Lokasi di post & event',
                      value: _showLocation,
                      onChanged: (v) => setState(() => _showLocation = v),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Konten'),
                    const SizedBox(height: 8),
                    _buildSwitchTile(
                      title: 'Aktivitas teman',
                      subtitle: 'Post dari teman yang di-follow',
                      value: _showActivity,
                      onChanged: (v) => setState(() => _showActivity = v),
                    ),
                    const SizedBox(height: 8),
                    _buildSwitchTile(
                      title: 'Event',
                      subtitle: 'Event dari teman & publik',
                      value: _showEvent,
                      onChanged: (v) => setState(() => _showEvent = v),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Preferensi Belajar'),
                    const SizedBox(height: 8),
                    _buildDropdownTile(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Notifikasi'),
                    const SizedBox(height: 8),
                    _buildSwitchTile(
                      title: 'Push notification',
                      subtitle: 'Notifikasi untuk aktivitas baru',
                      value: _pushNotifications,
                      onChanged: (v) => setState(() => _pushNotifications = v),
                    ),
                    const SizedBox(height: 28),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 10),
      width: 36,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.greyHandle,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 14),
      child: Row(
        children: [
          Expanded(child: Text('preferensi', style: AppTextStyles.heading)),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.greyBorder),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toLowerCase(),
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.greyText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greyLighter,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        children: [
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
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildToggle(value, onChanged),
        ],
      ),
    );
  }

  Widget _buildToggle(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.black : AppColors.greyLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.black : AppColors.greyBorder,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: value ? AppColors.white : AppColors.greyHint,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greyLighter,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'tampilkan konten',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'filter berdasarkan jenis aktivitas',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _studyPreference,
                isExpanded: true,
                icon: const Icon(
                  Icons.unfold_more_rounded,
                  size: 16,
                  color: AppColors.grey,
                ),
                style: AppTextStyles.body.copyWith(color: AppColors.black),
                items:
                    _studyOptions.map((opt) {
                      return DropdownMenuItem(
                        value: opt,
                        child: Text(opt.toLowerCase()),
                      );
                    }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _studyPreference = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              'simpan',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
