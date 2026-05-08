import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/scanner_service.dart';
import '../../domain/scanned_doc_model.dart';

class ScannerPreviewPage extends StatefulWidget {
  final ScannedDoc doc;

  const ScannerPreviewPage({super.key, required this.doc});

  @override
  State<ScannerPreviewPage> createState() => _ScannerPreviewPageState();
}

class _ScannerPreviewPageState extends State<ScannerPreviewPage> {
  late PageController _pageController;
  late ScannedDoc _doc;
  int _currentPage = 0;
  bool _isGeneratingPdf = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _doc = widget.doc;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _editTitle() async {
    final controller = TextEditingController(text: _doc.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Edit Judul',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != _doc.title) {
      await ScannerService.updateTitle(_doc.id, result);
      if (!mounted) return;
      setState(() {
        _doc = ScannedDoc(
          id: _doc.id,
          title: result,
          imagePaths: _doc.imagePaths,
          pdfPath: _doc.pdfPath,
          scannedAt: _doc.scannedAt,
        );
      });
      _showSnackbar('Judul diperbarui', Colors.green.shade600);
    }
  }

  Future<void> _generatePdf() async {
    setState(() => _isGeneratingPdf = true);
    HapticFeedback.lightImpact();

    try {
      final pdfPath = await ScannerService.generatePdf(
        title: _doc.title,
        imagePaths: _doc.imagePaths,
      );

      if (pdfPath == null) {
        _showSnackbar('Gagal membuat PDF', Colors.red.shade400);
        return;
      }

      // Preview PDF
      final pdfFile = File(pdfPath);
      final pdfBytes = await pdfFile.readAsBytes();

      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: _doc.title,
      );
    } catch (e) {
      _showSnackbar('Error: $e', Colors.red.shade400);
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _shareAsPdf() async {
    setState(() => _isSharing = true);
    HapticFeedback.lightImpact();

    try {
      final pdfPath = await ScannerService.generatePdf(
        title: _doc.title,
        imagePaths: _doc.imagePaths,
      );

      if (pdfPath == null) {
        _showSnackbar('Gagal membuat PDF', Colors.red.shade400);
        return;
      }

      await Share.shareXFiles(
        [XFile(pdfPath)],
        subject: _doc.title,
        text: 'Scan dari Ploopy 📄',
      );
    } catch (e) {
      _showSnackbar('Error: $e', Colors.red.shade400);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _shareAsImage() async {
    try {
      HapticFeedback.lightImpact();

      final files = _doc.imagePaths
          .where((p) => File(p).existsSync())
          .map((p) => XFile(p))
          .toList();

      if (files.isEmpty) {
        _showSnackbar('File tidak ditemukan', Colors.red.shade400);
        return;
      }

      await Share.shareXFiles(
        files,
        subject: _doc.title,
        text: 'Scan dari Ploopy 📄',
      );
    } catch (e) {
      _showSnackbar('Error: $e', Colors.red.shade400);
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
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildImageViewer()),
          if (_doc.imagePaths.length > 1) _buildPageIndicator(),
          _buildActionBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: GestureDetector(
        onTap: _editTitle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _doc.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.edit_rounded, size: 14, color: Colors.white70),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildImageViewer() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _doc.imagePaths.length,
      onPageChanged: (i) => setState(() => _currentPage = i),
      itemBuilder: (_, i) {
        final file = File(_doc.imagePaths[i]);
        if (!file.existsSync()) {
          return const Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: Colors.white54,
              size: 60,
            ),
          );
        }
        return InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Center(
            child: Image.file(
              file,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_doc.imagePaths.length, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _currentPage ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == _currentPage
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          top: BorderSide(color: Colors.grey.shade800, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _buildBottomButton(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Preview PDF',
                color: Colors.red.shade300,
                onTap: _generatePdf,
                isLoading: _isGeneratingPdf,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBottomButton(
                icon: Icons.share_rounded,
                label: 'Share PDF',
                color: Colors.blue.shade300,
                onTap: _shareAsPdf,
                isLoading: _isSharing,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBottomButton(
                icon: Icons.image_rounded,
                label: 'Share Image',
                color: Colors.green.shade300,
                onTap: _shareAsImage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      )
                    : Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}