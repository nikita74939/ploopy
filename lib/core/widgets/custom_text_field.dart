import 'package:flutter/material.dart';

import '../constants/app_constants.dart' show AppStyle;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyle.borderRadius),
        border: Border.all(
          color: AppColors.greyBorder,
          width: AppStyle.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: AppStyle.shadowOffset,
            blurRadius: 18,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.body,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.hint,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.textSecondary)
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppStyle.paddingMedium,
            vertical: AppStyle.paddingMedium,
          ),
        ),
      ),
    );
  }
}
