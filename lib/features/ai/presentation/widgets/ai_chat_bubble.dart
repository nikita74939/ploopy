import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
          if (!isUser) ...[_buildAiAvatar(), const SizedBox(width: 8)],
          Flexible(child: _buildBubble(context)),
        ],
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.greyBorder),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.smart_toy_outlined,
        size: 17,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border:
            isUser
                ? null
                : Border.all(
                  color:
                      isError ? AppColors.primaryBorder : AppColors.greyBorder,
                  width: 1,
                ),
      ),
      child:
          isUser
              ? _buildUserText()
              : (isError ? _buildErrorText() : _buildAiMarkdown()),
    );
  }

  Widget _buildUserText() {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(color: AppColors.white, height: 1.5),
    );
  }

  Widget _buildErrorText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: AppColors.grey,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.small.copyWith(
              color: AppColors.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiMarkdown() {
    final base = AppTextStyles.body.copyWith(
      color: AppColors.black,
      height: 1.5,
    );

    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: base,
        h1: AppTextStyles.heading.copyWith(fontSize: 17),
        h2: AppTextStyles.heading.copyWith(fontSize: 15),
        h3: AppTextStyles.heading.copyWith(fontSize: 14),
        strong: base.copyWith(fontWeight: FontWeight.w700),
        em: base.copyWith(fontStyle: FontStyle.italic),
        code: AppTextStyles.small.copyWith(
          color: AppColors.black,
          backgroundColor: AppColors.greyLight,
        ),
        codeblockDecoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.greyBorder),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquote: base.copyWith(
          color: AppColors.grey,
          fontStyle: FontStyle.italic,
        ),
        listBullet: base,
      ),
    );
  }
}
