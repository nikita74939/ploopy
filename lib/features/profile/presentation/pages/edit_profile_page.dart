import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameCtrl = TextEditingController(text: 'Pengguna Ploopy');
  final _bioCtrl = TextEditingController(text: 'Mahasiswa yang suka belajar 📚');
  final _phoneCtrl = TextEditingController(text: '081234567890');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profil berhasil diperbarui',
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 32),
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              CustomTextField(controller: _nameCtrl, hint: 'Nama lengkap'),
              const SizedBox(height: 16),
              _buildLabel('Bio'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _bioCtrl,
                hint: 'Ceritakan tentang dirimu',
              ),
              const SizedBox(height: 16),
              _buildLabel('Nomor Telepon'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _phoneCtrl,
                hint: '08xxxxxxxxxx',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              PrimaryButton(label: 'Simpan Perubahan', onPressed: _save),
            ],
          ),
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
      title: Text('Edit Profil', style: AppTextStyles.heading),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.greyBorder),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.greyBorder, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              _nameCtrl.text.isNotEmpty
                  ? _nameCtrl.text[0].toUpperCase()
                  : 'P',
              style: GoogleFonts.robotoMono(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.greyText,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}