import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/data/models/user_model.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _picker = ImagePicker();

  String? _avatarUrl;
  Uint8List? _pickedBytes;
  String? _pickedExtension;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _bioController.text = widget.user.bio ?? '';
    _avatarUrl = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 900,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final extension = image.name.split('.').last.toLowerCase();
    if (!mounted) return;
    setState(() {
      _pickedBytes = bytes;
      _pickedExtension = extension == 'png' ? 'png' : 'jpg';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      var avatarUrl = _avatarUrl;
      final pickedBytes = _pickedBytes;
      if (pickedBytes != null) {
        avatarUrl = await _uploadAvatar(pickedBytes);
      }

      final updated = UserModel()
        ..userId = widget.user.userId
        ..email = widget.user.email
        ..name = _nameController.text.trim()
        ..bio = _nullableText(_bioController.text)
        ..avatarUrl = avatarUrl
        ..joinedAt = widget.user.joinedAt
        ..biometricEnabled = widget.user.biometricEnabled
        ..streak = widget.user.streak
        ..longestStreak = widget.user.longestStreak
        ..totalStudyMinutes = widget.user.totalStudyMinutes
        ..totalTasksCompleted = widget.user.totalTasksCompleted
        ..appLockEnabled = widget.user.appLockEnabled;

      if (!mounted) return;
      context.read<ProfileBloc>().add(UpdateProfile(user: updated));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<String> _uploadAvatar(Uint8List bytes) async {
    final extension = _pickedExtension ?? 'jpg';
    final path =
        '${widget.user.userId}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';

    final storage = Supabase.instance.client.storage.from('avatars');
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: true),
    );
    return storage.getPublicUrl(path);
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _cleanError(Object e) {
    final message = e.toString();
    return message.startsWith('Exception: ') ? message.substring(11) : message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Edit Profil', style: AppTextStyles.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AvatarPicker(
                  name: _nameController.text,
                  avatarUrl: _avatarUrl,
                  pickedBytes: _pickedBytes,
                  onPick: _pickPhoto,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bioController,
                  style: AppTextStyles.body,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan Profil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final Uint8List? pickedBytes;
  final VoidCallback onPick;

  const _AvatarPicker({
    required this.name,
    required this.avatarUrl,
    required this.pickedBytes,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBorder, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(child: _avatarContent()),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: IconButton(
                onPressed: onPick,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.photo_camera_rounded, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Foto Profil', style: AppTextStyles.title.copyWith(fontSize: 14)),
        const SizedBox(height: 2),
        Text('Pilih foto dari galeri', style: AppTextStyles.caption),
      ],
    );
  }

  Widget _avatarContent() {
    if (pickedBytes != null) {
      return Image.memory(pickedBytes!, fit: BoxFit.cover);
    }
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      return Image.network(avatarUrl!, fit: BoxFit.cover);
    }
    return Center(
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: AppTextStyles.display.copyWith(color: AppColors.primary),
      ),
    );
  }
}
