import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/scanner_service.dart';
import '../../domain/models/scanned_doc_isar_model.dart'; // ← fix: domain → data

class ScannerPreviewPage extends StatefulWidget {
  final ScannedDocIsar doc;

  const ScannerPreviewPage({super.key, required this.doc});

  @override
  State<ScannerPreviewPage> createState() => _ScannerPreviewPageState();
}

class _ScannerPreviewPageState extends State<ScannerPreviewPage> {
  late PageController _pageController;
  late ScannedDocIsar _doc;
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
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Edit Judul',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLength: 60,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.greyLighter,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: AppColors.greyText),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(ctx, controller.text.trim()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Simpan',
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

    if (result != null && result.isNotEmpty && result != _doc.title) {
      await ScannerService.updateTitle(_doc.docId, result);
      if (!mounted) return;
      setState(() {
        _doc = _doc.copyWith(title: result); // ← fix: pakai copyWith
      });
      _showSnackbar('Judul diperbarui');
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
        _showSnackbar('Gagal membuat PDF', isError: true);
        return;
      }

      final pdfFile = File(pdfPath);
      final pdfBytes = await pdfFile.readAsBytes();

      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: _doc.title,
      );
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
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
        _showSnackbar('Gagal membuat PDF', isError: true);
        return;
      }

      await Share.shareXFiles(
        [XFile(pdfPath)],
        subject: _doc.title,
        text: 'Scan dari Ploopy',
      );
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _shareAsImage() async {
    try {
      HapticFeedback.lightImpact();

      final files =
          _doc.imagePaths
              .where((p) => File(p).existsSync())
              .map((p) => XFile(p))
              .toList();

      if (files.isEmpty) {
        _showSnackbar('Tidak ada gambar untuk di-share', isError: true);
        return;
      }

      await Share.shareXFiles(
        files,
        subject: _doc.title,
        text: 'Scan dari Ploopy',
      );
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: isError ? Colors.red.shade400 : AppColors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: _editTitle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _doc.title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.edit_outlined, size: 14, color: Colors.white54),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert_rounded,
            color: Colors.white,
            size: 22,
          ),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (val) {
            if (val == 'pdf') _generatePdf();
            if (val == 'share_img') _shareAsImage();
            if (val == 'share_pdf') _shareAsPdf();
          },
          itemBuilder:
              (_) => [
                PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 20,
                        color: AppColors.greyText,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Print PDF',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share_img',
                  child: Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 20,
                        color: AppColors.greyText,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Share Gambar',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share_pdf',
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_outlined,
                        size: 20,
                        color: AppColors.greyText,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Share PDF',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _doc.imagePaths.length,
            itemBuilder: (_, i) {
              final path = _doc.imagePaths[i];
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'scan_${_doc.docId}_$i',
                    child: Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) => Container(
                            margin: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: AppColors.greyLighter,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: AppColors.greyHint,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentPage + 1} / ${_doc.imagePaths.length}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomAction(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Print',
            isLoading: _isGeneratingPdf,
            onTap: _generatePdf,
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          _buildBottomAction(
            icon: Icons.share_outlined,
            label: 'Share',
            isLoading: _isSharing,
            onTap: () => _showShareOptions(),
          ),
        ],
      ),
    );
  }

  void _showShareOptions() {
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
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.greyBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Share sebagai',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildShareOption(
                          icon: Icons.image_outlined,
                          label: 'Gambar',
                          onTap: () {
                            Navigator.pop(context);
                            _shareAsImage();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildShareOption(
                          icon: Icons.picture_as_pdf_outlined,
                          label: 'PDF',
                          onTap: () {
                            Navigator.pop(context);
                            _shareAsPdf();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.greyLighter,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.black),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white.withOpacity(0.7),
                    ),
                  ),
                )
                : Icon(icon, size: 22, color: Colors.white),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
