import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../core/services/achievement_tracking_service.dart';
import '../../domain/ocr_result_model.dart';
import '../widgets/ocr_empty_state.dart';
import '../widgets/ocr_history_item.dart';
import '../widgets/ocr_source_picker.dart';
import 'ocr_result_page.dart';

class OcrHomePage extends StatefulWidget {
  const OcrHomePage({super.key});

  @override
  State<OcrHomePage> createState() => _OcrHomePageState();
}

class _OcrHomePageState extends State<OcrHomePage> {
  List<OcrResult> _results = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final results = await OcrService.getAll();
    if (!mounted) return;

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  Future<void> _startOcr() async {
    if (_isProcessing) return;

    final source = await OcrSourcePicker.show(context);
    if (source == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    var isDialogVisible = false;

    try {
      final imagePath = source == OcrSource.camera
          ? await OcrService.pickFromCamera()
          : await OcrService.pickFromGallery();

      if (!mounted) return;

      if (imagePath == null) {
        _showSnackbar('Pengambilan gambar dibatalkan.', Colors.grey.shade700);
        return;
      }

      _showProcessingDialog();
      isDialogVisible = true;

      final ocrResult = await OcrService.extractText(imagePath);

      if (!mounted) return;
      if (isDialogVisible) {
        Navigator.pop(context);
        isDialogVisible = false;
      }

      if (ocrResult == null) {
        _showSnackbar('Gagal mengekstrak teks.', Colors.red.shade400);
        return;
      }

      if (ocrResult.text.trim().isEmpty) {
        _showSnackbar(
          'Tidak ada teks yang terdeteksi.',
          Colors.orange.shade500,
        );
        return;
      }

      final saved = await OcrService.save(
        title: 'OCR ${DateTime.now().day}/${DateTime.now().month}',
        extractedText: ocrResult.text,
        blockCount: ocrResult.blockCount,
        imagePath: imagePath,
      );

      if (!mounted) return;

      if (saved == null) {
        _showSnackbar('Hasil OCR gagal disimpan.', Colors.red.shade400);
        return;
      }

      await AchievementTrackingService.track('ocr_used');
      await _loadResults();
      _showSnackbar(
        '${ocrResult.blockCount} blok teks berhasil ditemukan.',
        Colors.green.shade600,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OcrResultPage(result: saved, isNew: true),
        ),
      ).then((_) => _loadResults());
    } catch (e) {
      if (!mounted) return;
      if (isDialogVisible) {
        Navigator.pop(context);
      }
      _showSnackbar('Terjadi kesalahan saat memproses OCR.', Colors.red.shade400);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showProcessingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Menganalisis gambar...',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'OCR sedang mengekstrak teks.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteResult(OcrResult result) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Hapus hasil?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '"${result.title}" akan dihapus permanen.',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
            label: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await OcrService.delete(result.id);
      await _loadResults();
      _showSnackbar('Hasil berhasil dihapus.', Colors.grey.shade800);
    }
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
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _results.isNotEmpty ? _buildFab() : null,
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
        'Picture to Text',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_isProcessing) return _buildProcessingState();
    if (_results.isEmpty) return OcrEmptyState(onStart: _startOcr);

    return _buildResultsList();
  }

  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Memproses...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'OCR sedang membaca teks pada gambar.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    final totalWords = _results.fold<int>(0, (sum, r) => sum + r.wordCount);

    return Column(
      children: [
        _buildStatsHeader(totalWords),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadResults,
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final result = _results[i];
                return OcrHistoryItem(
                  result: result,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OcrResultPage(result: result),
                      ),
                    ).then((_) => _loadResults());
                  },
                  onDelete: () => _deleteResult(result),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(int totalWords) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.document_scanner_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat Ekstraksi',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '${_results.length} hasil · $totalWords kata',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.text_snippet_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _startOcr,
      backgroundColor: AppColors.primary,
      elevation: 6,
      icon: const Icon(
        Icons.document_scanner_rounded,
        color: Colors.white,
        size: 20,
      ),
      label: Text(
        'Ekstrak',
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
