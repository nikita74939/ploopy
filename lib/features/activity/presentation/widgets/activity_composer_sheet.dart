import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/bottom_sheet_insets.dart';
import '../bloc/activity_bloc.dart';

class ActivityComposerSheet extends StatefulWidget {
  final String userId;

  const ActivityComposerSheet({super.key, required this.userId});

  @override
  State<ActivityComposerSheet> createState() => _ActivityComposerSheetState();
}

class _ActivityComposerSheetState extends State<ActivityComposerSheet> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _image;
  Uint8List? _previewBytes;
  bool _submitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _image = image;
      _previewBytes = bytes;
    });
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    try {
      final repository = context.read<ActivityBloc>().repository;
      final imageUrls = <String>[];
      final image = _image;
      if (image != null) {
        final contentType = image.mimeType ?? 'image/jpeg';
        final url = await repository.uploadImage(
          bytes: await image.readAsBytes(),
          contentType: contentType,
        );
        imageUrls.add(url);
      }

      await repository.createActivity(
        userId: widget.userId,
        text: text,
        imageUrls: imageUrls,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _textController.text.trim().isNotEmpty && !_submitting;
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          BottomSheetInsets.bottom(context),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.greyHandle,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Buat Activity',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _textController,
                minLines: 4,
                maxLines: 6,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Ceritakan aktivitasmu...',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
              const SizedBox(height: 12),
              if (_previewBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    _previewBytes!,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                onPressed: _submitting ? null : _pickImage,
                icon: const Icon(Icons.photo_library_rounded),
                label: Text(_image == null ? 'Tambah gambar' : 'Ganti gambar'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: canSubmit ? _submit : null,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_submitting ? 'Mengirim...' : 'Posting'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
