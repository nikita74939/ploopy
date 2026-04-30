import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploopy/core/theme/app_colors.dart';
import 'package:ploopy/features/scanner/domain/scanned_doc_model.dart';
import 'package:ploopy/features/scanner/presentation/pages/scanner_preview_page.dart';
import 'package:ploopy/features/scanner/presentation/widgets/scan_empty_state.dart';
import 'package:ploopy/features/scanner/presentation/widgets/scan_history_item.dart';
import 'package:ploopy/shared/services/scanner_service.dart';

class ScannerHomePage extends StatefulWidget {
  const ScannerHomePage({super.key});

  @override
  State<ScannerHomePage> createState() => _ScannerHomePageState();
}

class _ScannerHomePageState extends State<ScannerHomePage> {
  List<ScannedDoc> _docs = [];
  bool _isLoading = true;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    final docs = await ScannerService.getAllDocs();
    if (!mounted) return;
    setState(() {
      _docs = docs;
      _isLoading = false;
    });
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);
    HapticFeedback.mediumImpact();

    try {
      final imagePaths = await ScannerService.scanDocuments();

      if (imagePaths == null || imagePaths.isEmpty) {
        if (mounted) setState(() => _isScanning = false);
        return;
      }

      final title = await _askForTitle();

      final doc = await ScannerService.saveDoc(
        title: title ?? 'Scan ${DateTime.now().day}/${DateTime.now().month}',
        imagePaths: imagePaths,
      );

      if (doc != null) {
        await _loadDocs();
        _showSnackbar(
          '${imagePaths.length} halaman berhasil di-scan',
        );

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScannerPreviewPage(doc: doc),
          ),
        ).then((_) => _loadDocs());
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<String?> _askForTitle() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Beri Judul',
          style: GoogleFonts.robotoMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan berhasil! Kasih judul biar gampang dicari.',
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.robotoMono(fontSize: 13, color: AppColors.black),
              decoration: InputDecoration(
                hintText: 'Contoh: Catatan Kalkulus Bab 3',
                hintStyle: GoogleFonts.robotoMono(
                  fontSize: 12,
                  color: AppColors.greyHint,
                ),
                filled: true,
                fillColor: AppColors.greyLighter,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(
              'Skip',
              style: GoogleFonts.robotoMono(color: AppColors.greyText),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(ctx, controller.text.trim()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Simpan',
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDoc(ScannedDoc doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Hapus scan?',
          style: GoogleFonts.robotoMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        content: Text(
          '"${doc.title}" akan dihapus permanen beserta file-nya',
          style: GoogleFonts.robotoMono(fontSize: 12, color: AppColors.greyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.robotoMono(color: AppColors.greyText),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(ctx, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.robotoMono(
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
      await ScannerService.deleteDoc(doc.id);
      await _loadDocs();
      _showSnackbar('Scan dihapus');
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: isError ? Colors.red.shade400 : AppColors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _docs.isNotEmpty ? _buildFab() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Scanner',
        style: GoogleFonts.robotoMono(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_isScanning) {
      return _buildScanningState();
    }

    if (_docs.isEmpty) {
      return ScanEmptyState(onScan: _startScan);
    }

    return _buildDocsList();
  }

  Widget _buildScanningState() {
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
            child: const SizedBox(
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
            'Membuka Scanner...',
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Arahkan kamera ke dokumen',
            style: GoogleFonts.robotoMono(
              fontSize: 11,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocsList() {
    return Column(
      children: [
        _buildStatsHeader(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDocs,
            color: AppColors.black,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final doc = _docs[i];
                return ScanHistoryItem(
                  doc: doc,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScannerPreviewPage(doc: doc),
                      ),
                    ).then((_) => _loadDocs());
                  },
                  onDelete: () => _deleteDoc(doc),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final totalPages = _docs.fold<int>(0, (sum, d) => sum + d.pageCount);

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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.greyLighter,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.folder_outlined,
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
                  'Koleksi Scan',
                  style: GoogleFonts.robotoMono(
                    fontSize: 11,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_docs.length} dokumen · $totalPages halaman',
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _startScan,
      backgroundColor: AppColors.black,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.document_scanner_outlined,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}