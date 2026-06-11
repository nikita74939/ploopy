import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/achievement_tracking_service.dart';
import '../../../../core/services/scanner_service.dart';
import '../../domain/scanned_doc_model.dart';
import '../widgets/scan_empty_state.dart';
import '../widgets/scan_history_item.dart';
import 'scanner_preview_page.dart';

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
        return;
      }

      final title = await _askForTitle();

      final doc = await ScannerService.saveDoc(
        title: title ?? 'Scan ${DateTime.now().day}/${DateTime.now().month}',
        imagePaths: imagePaths,
      );

      if (doc == null) {
        _showSnackbar('Gagal menyimpan dokumen.', Colors.red.shade400);
        return;
      }

      await AchievementTrackingService.track(
        'scanner_used',
        amount: imagePaths.length,
      );
      await _loadDocs();

      _showSnackbar(
        '${imagePaths.length} halaman berhasil disimpan.',
        Colors.green.shade600,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScannerPreviewPage(doc: doc),
        ),
      ).then((_) => _loadDocs());
    } catch (e) {
      _showSnackbar('Gagal memindai dokumen.', Colors.red.shade400);
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<String?> _askForTitle() async {
    final controller = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                Icons.drive_file_rename_outline_rounded,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Beri Judul',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scan berhasil. Tambahkan judul agar dokumen mudah ditemukan.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Contoh: Catatan Kalkulus Bab 3',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.description_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                'Lewati',
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                'Simpan',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> _deleteDoc(ScannedDoc doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 22,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                'Hapus scan?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            '"${doc.title}" akan dihapus permanen beserta semua halamannya.',
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
              icon: const Icon(Icons.delete_rounded, size: 18),
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
        );
      },
    );

    if (confirm != true) return;

    await ScannerService.deleteDoc(doc.id);
    await _loadDocs();

    _showSnackbar('Dokumen dihapus.', Colors.grey.shade800);
  }

  void _openDoc(ScannedDoc doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScannerPreviewPage(doc: doc),
      ),
    ).then((_) => _loadDocs());
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
          ),
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
      floatingActionButton: _docs.isNotEmpty ? _buildFab() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey.shade50,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.black87,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Scanner Dokumen',
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
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
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
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
                Icon(
                  Icons.document_scanner_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Membuka scanner',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Arahkan kamera ke dokumen',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
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
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final doc = _docs[index];

                return ScanHistoryItem(
                  doc: doc,
                  onTap: () => _openDoc(doc),
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
    final totalPages = _docs.fold<int>(
      0,
      (sum, doc) => sum + doc.pageCount,
    );

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF3E9),
            Color(0xFFFFE8D6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_copy_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Koleksi Scan',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '${_docs.length} dokumen · $totalPages halaman',
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
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _startScan,
      backgroundColor: AppColors.primary,
      elevation: 6,
      icon: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 22,
      ),
      label: Text(
        'Scan Baru',
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
