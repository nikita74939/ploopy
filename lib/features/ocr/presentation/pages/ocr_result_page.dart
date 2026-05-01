import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/ocr_service.dart';
import '../../../ai/presentation/pages/ai_page.dart';
import '../../domain/ocr_result_model.dart';

class OcrResultPage extends StatefulWidget {
  final OcrResult result;
  final bool isNew;

  const OcrResultPage({super.key, required this.result, this.isNew = false});

  @override
  State<OcrResultPage> createState() => _OcrResultPageState();
}

class _OcrResultPageState extends State<OcrResultPage> {
  late OcrResult _result;
  late TextEditingController _textController;
  late TextEditingController _titleController;
  bool _isEditing = false;
  bool _showImage = true;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
    _textController = TextEditingController(text: _result.extractedText);
    _titleController = TextEditingController(text: _result.title);
    _isEditing = widget.isNew;
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // =====================
  // LOGIC METHODS (UNCHANGED)
  // =====================

  Future<void> _saveChanges() async {
    final updated = _result.copyWith(
      title:
          _titleController.text.trim().isEmpty
              ? _result.title
              : _titleController.text.trim(),
      extractedText: _textController.text,
    );

    await OcrService.update(updated);

    if (!mounted) return;
    setState(() {
      _result = updated;
      _isEditing = false;
    });

    _showSnackbar('Perubahan disimpan', Colors.green.shade600);
  }

  Future<void> _copyText() async {
    if (_textController.text.isEmpty) return;
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _textController.text));
    if (!mounted) return;
    _showSnackbar('Teks disalin ke clipboard!', Colors.green.shade600);
  }

  Future<void> _shareText() async {
    if (_textController.text.isEmpty) return;
    HapticFeedback.lightImpact();

    await Share.share(_textController.text, subject: _result.title);
  }

  void _openInAi(String prompt) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AiPage(
              initialPrompt: '$prompt\n\n---\n${_textController.text}',
            ),
      ),
    );
  }

  void _showAiOptions() {
    if (_textController.text.trim().isEmpty) {
      _showSnackbar('Teks masih kosong', Colors.red.shade400);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.greyBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 22,
                        color: AppColors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Proses dengan AI',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kirim teks ke AI Assistant untuk:',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAiOption(
                    icon: Icons.summarize_outlined,
                    title: 'Rangkum',
                    subtitle: 'Buat ringkasan poin-poin penting',
                    onTap: () {
                      Navigator.pop(context);
                      _openInAi('Tolong buatkan rangkuman dari teks berikut:');
                    },
                  ),
                  _buildAiOption(
                    icon: Icons.translate_outlined,
                    title: 'Terjemahkan',
                    subtitle: 'Terjemahkan ke bahasa lain',
                    onTap: () {
                      Navigator.pop(context);
                      _openInAi(
                        'Tolong terjemahkan teks berikut ke Bahasa Indonesia:',
                      );
                    },
                  ),
                  _buildAiOption(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Perbaiki',
                    subtitle: 'Perbaiki tata bahasa & ejaan',
                    onTap: () {
                      Navigator.pop(context);
                      _openInAi(
                        'Tolong perbaiki tata bahasa dan ejaan teks berikut:',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =====================
  // UI WIDGETS (REDESIGNED)
  // =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title:
          _isEditing
              ? SizedBox(
                height: 32,
                child: TextField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Judul hasil OCR',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.greyHint,
                    ),
                    filled: true,
                    fillColor: AppColors.greyLighter,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                ),
              )
              : Text(
                _result.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
      centerTitle: true,
      actions: [
        if (_isEditing)
          GestureDetector(
            onTap: _saveChanges,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Simpan',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )
        else
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.greyText,
            ),
            onPressed: () => setState(() => _isEditing = true),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                const SizedBox(height: 16),
                _buildStatsCard(),
                const SizedBox(height: 16),
                _buildTextSection(),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: () => setState(() => _showImage = !_showImage),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _showImage ? 180 : 56,
        decoration: BoxDecoration(
          color: AppColors.greyLighter,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child:
            _showImage
                ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(_result.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: AppColors.greyHint,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gambar tidak tersedia',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fullscreen_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap untuk sembunyikan',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 20,
                        color: AppColors.greyText,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Gambar sumber tersembunyi',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.greyText,
                          ),
                        ),
                      ),
                      Text(
                        'Tap untuk tampilkan',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.greyHint,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: AppColors.greyHint,
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.text_fields_rounded,
            value: '${_result.wordCount}',
            label: 'kata',
          ),
          Container(
            width: 1,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.greyBorder,
          ),
          _buildStatItem(
            icon: Icons.format_align_left_rounded,
            value: '${_result.blockCount}',
            label: 'paragraf',
          ),
          const Spacer(),
          Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.greyHint),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.greyLighter,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: AppColors.black),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 16,
                  color: AppColors.greyText,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hasil Ekstraksi',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.greyBorder),
          Padding(
            padding: const EdgeInsets.all(14),
            child:
                _isEditing
                    ? TextField(
                      controller: _textController,
                      maxLines: null,
                      minLines: 8,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.black,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Teks hasil ekstraksi akan muncul di sini...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.greyHint,
                          height: 1.6,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    : Text(
                      _textController.text,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.black,
                        height: 1.6,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.greyBorder, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomAction(
            icon: Icons.copy_rounded,
            label: 'Salin',
            onTap: _copyText,
          ),
          Container(width: 1, height: 40, color: AppColors.greyBorder),
          _buildBottomAction(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: _shareText,
          ),
          Container(width: 1, height: 40, color: AppColors.greyBorder),
          _buildBottomAction(
            icon: Icons.auto_awesome_rounded,
            label: 'AI',
            onTap: _showAiOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.black),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.greyLighter,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: AppColors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.greyHint,
            ),
          ],
        ),
      ),
    );
  }
}
