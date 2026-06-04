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

  const ScannerPreviewPage({
    super.key,
    required this.doc,
  });

  @override
  State<ScannerPreviewPage> createState() => _ScannerPreviewPageState();
}

class _ScannerPreviewPageState extends State<ScannerPreviewPage> {
  late PageController _pageController;
  late ScannedDoc _doc;

  int _currentPage = 0;
  bool _isGeneratingPdf = false;
  bool _isSharing = false;
  bool _isAddingPage = false;

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

  Future<void> _reloadDoc() async {
    final latestDoc = await ScannerService.getDocById(_doc.id);

    if (!mounted || latestDoc == null) return;

    setState(() {
      _doc = latestDoc;
      if (_currentPage >= _doc.imagePaths.length) {
        _currentPage = _doc.imagePaths.length - 1;
      }
    });
  }

  Future<void> _editTitle() async {
    final controller = TextEditingController(text: _doc.title);

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
                'Edit Judul',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 60,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Judul dokumen',
              prefixIcon: Icon(
                Icons.description_rounded,
                color: Colors.grey.shade500,
                size: 20,
              ),
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

    if (result == null || result.isEmpty || result == _doc.title) return;

    final updated = await ScannerService.updateTitle(_doc.id, result);

    if (!updated) {
      _showSnackbar('Gagal memperbarui judul.', Colors.red.shade400);
      return;
    }

    await _reloadDoc();

    _showSnackbar('Judul diperbarui.', Colors.green.shade600);
  }

  Future<void> _addPages() async {
    if (_isAddingPage) return;

    setState(() => _isAddingPage = true);
    HapticFeedback.mediumImpact();

    try {
      final newPages = await ScannerService.scanDocuments();

      if (newPages == null || newPages.isEmpty) return;

      final updatedDoc = await ScannerService.addPagesToDoc(
        id: _doc.id,
        newImagePaths: newPages,
      );

      if (updatedDoc == null) {
        _showSnackbar('Gagal menambahkan halaman.', Colors.red.shade400);
        return;
      }

      if (!mounted) return;

      setState(() {
        _doc = updatedDoc;
        _currentPage = _doc.imagePaths.length - newPages.length;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_pageController.hasClients) return;

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      });

      _showSnackbar(
        '${newPages.length} halaman ditambahkan.',
        Colors.green.shade600,
      );
    } catch (e) {
      _showSnackbar('Gagal menambahkan halaman.', Colors.red.shade400);
    } finally {
      if (mounted) {
        setState(() => _isAddingPage = false);
      }
    }
  }

  Future<void> _deleteCurrentPage() async {
    if (_doc.imagePaths.isEmpty) return;

    final pageNumber = _currentPage + 1;

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
                color: Colors.red.shade400,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Hapus halaman?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'Halaman $pageNumber akan dihapus dari dokumen ini.',
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

    final updatedDoc = await ScannerService.deletePage(
      docId: _doc.id,
      pageIndex: _currentPage,
    );

    if (!mounted) return;

    if (updatedDoc == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _doc = updatedDoc;
      if (_currentPage >= _doc.imagePaths.length) {
        _currentPage = _doc.imagePaths.length - 1;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pageController.hasClients) return;

      _pageController.jumpToPage(_currentPage);
    });

    _showSnackbar('Halaman dihapus.', Colors.grey.shade800);
  }

  Future<void> _generatePdf() async {
    if (_isGeneratingPdf) return;

    setState(() => _isGeneratingPdf = true);
    HapticFeedback.lightImpact();

    try {
      final pdfPath = await ScannerService.generatePdf(
        title: _doc.title,
        imagePaths: _doc.imagePaths,
      );

      if (pdfPath == null) {
        _showSnackbar('Gagal membuat PDF.', Colors.red.shade400);
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
      _showSnackbar('Gagal membuat PDF.', Colors.red.shade400);
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  Future<void> _shareAsPdf() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    HapticFeedback.lightImpact();

    try {
      final pdfPath = await ScannerService.generatePdf(
        title: _doc.title,
        imagePaths: _doc.imagePaths,
      );

      if (pdfPath == null) {
        _showSnackbar('Gagal membuat PDF.', Colors.red.shade400);
        return;
      }

      await Share.shareXFiles(
        [XFile(pdfPath)],
        subject: _doc.title,
        text: 'Scan dari Ploopy',
      );
    } catch (e) {
      _showSnackbar('Gagal membagikan PDF.', Colors.red.shade400);
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _shareAsImage() async {
    try {
      HapticFeedback.lightImpact();

      final files = _doc.imagePaths
          .where((path) => File(path).existsSync())
          .map((path) => XFile(path))
          .toList();

      if (files.isEmpty) {
        _showSnackbar('File gambar tidak ditemukan.', Colors.red.shade400);
        return;
      }

      await Share.shareXFiles(
        files,
        subject: _doc.title,
        text: 'Scan dari Ploopy',
      );
    } catch (e) {
      _showSnackbar('Gagal membagikan gambar.', Colors.red.shade400);
    }
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
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildImageViewer()),
          _buildPageInfo(),
          _buildThumbnailStrip(),
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
            const Icon(
              Icons.edit_rounded,
              size: 14,
              color: Colors.white70,
            ),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Tambah halaman',
          onPressed: _isAddingPage ? null : _addPages,
          icon: _isAddingPage
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add_photo_alternate_rounded),
        ),
        PopupMenuButton<String>(
          color: Colors.white,
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editTitle();
                break;
              case 'add':
                _addPages();
                break;
              case 'delete_page':
                _deleteCurrentPage();
                break;
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'edit',
                child: _buildPopupItem(
                  icon: Icons.drive_file_rename_outline_rounded,
                  label: 'Edit judul',
                ),
              ),
              PopupMenuItem(
                value: 'add',
                child: _buildPopupItem(
                  icon: Icons.add_photo_alternate_rounded,
                  label: 'Tambah halaman',
                ),
              ),
              PopupMenuItem(
                value: 'delete_page',
                child: _buildPopupItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus halaman ini',
                  color: Colors.red.shade400,
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildPopupItem({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final itemColor = color ?? Colors.black87;

    return Row(
      children: [
        Icon(icon, size: 20, color: itemColor),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: itemColor,
          ),
        ),
      ],
    );
  }

  Widget _buildImageViewer() {
    if (_doc.imagePaths.isEmpty) {
      return const Center(
        child: Icon(
          Icons.description_rounded,
          color: Colors.white54,
          size: 60,
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _doc.imagePaths.length,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      itemBuilder: (_, index) {
        final file = File(_doc.imagePaths[index]);

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

  Widget _buildPageInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_rounded,
            color: Colors.white.withOpacity(0.75),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Halaman ${_currentPage + 1} dari ${_doc.pageCount}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailStrip() {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.black,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _doc.imagePaths.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          if (index == _doc.imagePaths.length) {
            return _buildAddPageThumbnail();
          }

          final selected = index == _currentPage;
          final file = File(_doc.imagePaths[index]);

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.white24,
                  width: selected ? 2.4 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    file.existsSync()
                        ? Image.file(file, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.white54,
                            ),
                          ),
                    Positioned(
                      left: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddPageThumbnail() {
    return GestureDetector(
      onTap: _isAddingPage ? null : _addPages,
      child: Container(
        width: 54,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.55),
            width: 1,
          ),
        ),
        child: Center(
          child: _isAddingPage
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade800,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _buildBottomButton(
                icon: Icons.add_photo_alternate_rounded,
                label: 'Tambah',
                color: AppColors.primary,
                onTap: _addPages,
                isLoading: _isAddingPage,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBottomButton(
                icon: Icons.picture_as_pdf_rounded,
                label: 'PDF',
                color: Colors.red.shade300,
                onTap: _generatePdf,
                isLoading: _isGeneratingPdf,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBottomButton(
                icon: Icons.share_rounded,
                label: 'Bagikan',
                color: Colors.blue.shade300,
                onTap: _shareAsPdf,
                isLoading: _isSharing,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBottomButton(
                icon: Icons.image_rounded,
                label: 'Gambar',
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
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
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
                            color: color,
                          ),
                        ),
                      )
                    : Icon(
                        icon,
                        color: color,
                        size: 22,
                      ),
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