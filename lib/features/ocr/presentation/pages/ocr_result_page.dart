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
  final bool isNew; // true = baru selesai ekstrak, false = view history

  const OcrResultPage({
    super.key,
    required this.result,
    this.isNew = false,
  });

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
    _isEditing = widget.isNew; // auto-edit mode kalau baru
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updated = _result.copyWith(
      title: _titleController.text.trim().isEmpty
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

    _showSnackbar('Perubahan disimpan ✨', Colors.green.shade600);
  }

  Future<void> _copyText() async {
    if (_textController.text.isEmpty) return;
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _textController.text));
    if (!mounted) return;
    _showSnackbar('Teks disalin ke clipboard! 📋', Colors.green.shade600);
  }

  Future<void> _shareText() async {
    if (_textController.text.isEmpty) return;
    HapticFeedback.lightImpact();

    await Share.share(
      _textController.text,
      subject: _result.title,
    );
  }

  void _openInAi(String prompt) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiPage(
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
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Row(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  'Proses dengan AI',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Kirim teks ke AI Assistant untuk:',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 14),
            _buildAiOption(
              icon: '📝',
              title: 'Rangkum',
              subtitle: 'Buat ringkasan poin-poin penting',
              onTap: () {
                Navigator.pop(context);
                _openInAi('Tolong buatkan rangkuman dari teks berikut:');
              },
            ),
            _buildAiOption(
              icon: '💡',
              title: 'Jelaskan',
              subtitle: 'Jelasin konsep dengan bahasa sederhana',
              onTap: () {
                Navigator.pop(context);
                _openInAi('Tolong jelasin maksud dari teks berikut dengan bahasa yang mudah dipahami:');
              },
            ),
            _buildAiOption(
              icon: '🌐',
              title: 'Translate ke Indonesia',
              subtitle: 'Terjemahin ke Bahasa Indonesia',
              onTap: () {
                Navigator.pop(context);
                _openInAi('Tolong terjemahkan teks berikut ke Bahasa Indonesia:');
              },
            ),
            _buildAiOption(
              icon: '🎯',
              title: 'Buat Soal Latihan',
              subtitle: 'Generate pertanyaan dari teks ini',
              onTap: () {
                Navigator.pop(context);
                _openInAi('Tolong buatkan 5 soal latihan (pilihan ganda) dari teks berikut, beserta jawabannya:');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTitleCard(),
            if (_showImage && _result.imagePath != null) _buildImageCard(),
            Expanded(child: _buildTextCard()),
            _buildActionBar(),
          ],
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
        'Hasil Ekstraksi',
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_result.imagePath != null)
          IconButton(
            icon: Icon(
              _showImage
                  ? Icons.image_rounded
                  : Icons.hide_image_outlined,
              color: Colors.grey.shade700,
              size: 20,
            ),
            onPressed: () => setState(() => _showImage = !_showImage),
            tooltip: _showImage ? 'Sembunyikan' : 'Tampilkan',
          ),
        if (_isEditing)
          IconButton(
            icon: const Icon(
              Icons.check_rounded,
              color: Colors.green,
              size: 22,
            ),
            onPressed: _saveChanges,
          )
        else
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: Colors.grey.shade700,
              size: 18,
            ),
            onPressed: () => setState(() => _isEditing = true),
          ),
      ],
    );
  }

  Widget _buildTitleCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          const Text('📝', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _titleController,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Judul...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    _result.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_result.wordCount} kata',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(_result.imagePath!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image_rounded,
                      size: 10, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Sumber',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_fields_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Teks Terdeteksi',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_result.blockCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_result.blockCount} block',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 18),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Teks hasil ekstraksi...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  )
                : SingleChildScrollView(
                    child: SelectableText(
                      _textController.text.isEmpty
                          ? '(Tidak ada teks terdeteksi)'
                          : _textController.text,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _textController.text.isEmpty
                            ? Colors.grey.shade400
                            : Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.copy_rounded,
              label: 'Copy',
              color: const Color(0xFF4D96FF),
              onTap: _copyText,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              icon: Icons.share_rounded,
              label: 'Share',
              color: const Color(0xFF6BCB77),
              onTap: _shareText,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildActionButton(
              icon: Icons.auto_awesome_rounded,
              label: 'Proses AI',
              color: const Color(0xFFB79CED),
              onTap: _showAiOptions,
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? color : color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPrimary ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}