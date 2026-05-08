import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';

class AiChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isError;

  const AiChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAiAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(child: _buildBubble(context)),
        ],
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8C42), Color(0xFFFF6B42)],
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text('🤖', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.blue.shade700
            : (isError ? Colors.red.shade50 : Colors.white),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        border: isUser
            ? null
            : Border.all(
                color: isError ? Colors.red.shade200 : Colors.grey.shade100,
                width: 1,
              ),
      ),
      child: isUser
          ? _buildUserText()
          : (isError ? _buildErrorText() : _buildAiMarkdown()),
    );
  }

  Widget _buildUserText() {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.white,
        height: 1.5,
      ),
    );
  }

  Widget _buildErrorText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline_rounded, size: 16, color: Colors.red.shade400),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.red.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiMarkdown() {
    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.black87,
          height: 1.5,
        ),
        h1: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        h2: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        h3: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        strong: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        em: GoogleFonts.poppins(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: Colors.black87,
        ),
        code: GoogleFonts.firaCode(
          fontSize: 12,
          color: AppColors.primary,
          backgroundColor: Colors.grey.shade100,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquote: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        listBullet: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }
}