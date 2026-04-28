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

    // Tampilkan picker Camera/Gallery
    final source = await OcrSourcePicker.show(context);
    if (source == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      // 1. Pick image
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

      // 2. Show processing dialog
      if (!mounted) return;
      _showProcessingDialog();

      // 3. Extract text
      final ocrResult = await OcrService.extractText(imagePath);

      if (!mounted) return;
      Navigator.pop(context); // Tutup dialog

      if (ocrResult == null) {
        _showSnackbar('Gagal ekstrak teks', Colors.red.shade400);
        setState(() => _isProcessing = false);
        return;
      }

      if (ocrResult.text.isEmpty) {
        _showSnackbar('Tidak ada teks terdeteksi', Colors.orange.shade400);
        setState(() => _isProcessing = false);
        return;
      }

      // 4. Save result
      final saved = await OcrService.save(
        title: 'OCR ${DateTime.now().day}/${DateTime.now().month}',
        extractedText: ocrResult.text,
        blockCount: ocrResult.blockCount,
        imagePath: imagePath,
      );

      if (saved != null) {
        await _loadResults();
        _showSnackbar(
          '${ocrResult.blockCount} blok teks ditemukan! ✨',
          Colors.green.shade600,
        );

        // Buka result page
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
        Navigator.pop(context); // Tutup dialog kalau masih terbuka
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
                'Menganalisis Gambar...',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI sedang mengekstrak teks',
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
          '"${result.title}" akan dihapus permanen',
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
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await OcrService.delete(result.id);
      await _loadResults();
      _showSnackbar('Hasil dihapus 🗑️', Colors.grey.shade800);
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
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
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
            'AI sedang menganalisis gambar',
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
            child: const Text('🔍', style: TextStyle(fontSize: 22)),
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
            Icons.auto_awesome_rounded,
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
        Icons.text_fields_rounded,
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