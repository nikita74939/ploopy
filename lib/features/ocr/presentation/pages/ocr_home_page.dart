import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/ocr_service.dart';
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

  // =====================
  // LOGIC METHODS (UNCHANGED)
  // =====================

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

    try {
      String? imagePath;
      if (source == OcrSource.camera) {
        imagePath = await OcrService.pickFromCamera();
      } else {
        imagePath = await OcrService.pickFromGallery();
      }

      if (imagePath == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      if (!mounted) return;
      _showProcessingDialog();

      final ocrResult = await OcrService.extractText(imagePath);

      if (!mounted) return;
      Navigator.pop(context);

      if (ocrResult == null) {
        _showSnackbar('Gagal ekstrak teks', Colors.red.shade400);
        setState(() => _isProcessing = false);
        return;
      }

      if (ocrResult.extractedText.isEmpty) {
        _showSnackbar('Tidak ada teks terdeteksi', Colors.orange.shade400);
        setState(() => _isProcessing = false);
        return;
      }

      final saved = await OcrService.save(
        title: 'OCR ${DateTime.now().day}/${DateTime.now().month}',
        extractedText: ocrResult.extractedText,
        blockCount: ocrResult.blockCount,
        imagePath: imagePath,
      );

      if (saved != null) {
        await _loadResults();
        _showSnackbar(
          '${ocrResult.blockCount} blok teks ditemukan! ✨',
          Colors.green.shade600,
        );

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OcrResultPage(result: saved, isNew: true),
          ),
        ).then((_) => _loadResults());
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackbar('Error: $e', Colors.red.shade400);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              surfaceTintColor: Colors.transparent,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.greyLighter,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Menganalisis Gambar...',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI sedang mengekstrak teks',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.greyText,
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
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Hapus hasil?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            content: Text(
              '"${result.title}" akan dihapus permanen',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.greyText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: AppColors.greyText),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(ctx, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Hapus',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await OcrService.delete(result.id);
      await _loadResults();
      _showSnackbar('Hasil dihapus', Colors.grey.shade800);
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
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _results.isNotEmpty ? _buildFab() : null,
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
      title: Text(
        'Picture to Text',
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_isProcessing) {
      return _buildProcessingState();
    }

    if (_results.isEmpty) {
      return OcrEmptyState(onStart: _startOcr);
    }

    return _buildResultsList();
  }

  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.greyLighter,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.black),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Memproses...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'AI sedang menganalisis gambar',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.greyText),
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
            color: AppColors.black,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.greyLighter,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.document_scanner_outlined,
              color: AppColors.black,
              size: 20,
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
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_results.length} hasil · $totalWords kata',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.auto_awesome_rounded, color: AppColors.greyText, size: 20),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _startOcr,
      backgroundColor: AppColors.black,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Icon(
        Icons.text_fields_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}
