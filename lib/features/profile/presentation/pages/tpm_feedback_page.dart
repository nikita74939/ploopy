import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';

class TpmFeedbackPage extends StatefulWidget {
  const TpmFeedbackPage({super.key});

  @override
  State<TpmFeedbackPage> createState() => _TpmFeedbackPageState();
}

class _TpmFeedbackPageState extends State<TpmFeedbackPage> {
  final _feedbackCtrl = TextEditingController();
  int _rating = 0;
  String? _selectedCategory;

  final List<String> _categories = [
    'Materi Kuliah',
    'Praktikum',
    'Tugas Akhir',
    'Dosen Pengampu',
    'Lainnya',
  ];

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0 || _selectedCategory == null || _feedbackCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mohon lengkapi semua field',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              'Terima kasih!',
              style: AppTextStyles.heading.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Feedback kamu sudah kami terima.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'OK',
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Rating'),
              const SizedBox(height: 12),
              _buildRatingStars(),
              const SizedBox(height: 24),
              _buildSectionLabel('Kategori'),
              const SizedBox(height: 12),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              _buildSectionLabel('Feedback'),
              const SizedBox(height: 12),
              _buildTextArea(),
              const SizedBox(height: 32),
              PrimaryButton(label: 'Kirim Feedback', onPressed: _submit),
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
      title: Text('Saran & Kesan TPM', style: AppTextStyles.heading),
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

  Widget _buildRatingStars() {
    final labels = ['Buruk', 'Kurang', 'Cukup', 'Bagus', 'Keren!'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              final isSelected = _rating >= starIndex;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 36,
                  color: isSelected ? AppColors.black : AppColors.greyHandle,
                ),
              );
            }),
          ),
          if (_rating > 0) ...[
            const SizedBox(height: 10),
            Text(
              labels[_rating - 1],
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final selected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.black : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppColors.black : AppColors.greyBorder,
              ),
            ),
            child: Text(
              cat,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.greyText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: TextField(
        controller: _feedbackCtrl,
        maxLines: 5,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: 'Tulis saran, kritik, atau kesanmu di sini...',
          hintStyle: AppTextStyles.hint,
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}