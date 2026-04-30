// chat/presentation/widgets/chat_input_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.greyBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildIconButton(Icons.add_outlined),
            _buildIconButton(Icons.photo_camera_outlined),
            const SizedBox(width: 8),
            Expanded(child: _buildTextField()),
            const SizedBox(width: 10),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Icon(icon, size: 20, color: AppColors.black),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.black,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.emoji_emotions_outlined,
              size: 22,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
// chat/presentation/widgets/chat_input_bar.dart (lanjutan)

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _hasText ? widget.onSend : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _hasText ? AppColors.black : AppColors.greyLight,
          borderRadius: BorderRadius.circular(12),
          border: _hasText ? null : Border.all(color: AppColors.greyBorder),
        ),
        child: Icon(
          Icons.send_rounded,
          size: 20,
          color: _hasText ? AppColors.white : AppColors.grey,
        ),
      ),
    );
  }
}