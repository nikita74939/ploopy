import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme get textTheme => GoogleFonts.poppinsTextTheme().apply(
    bodyColor: AppColors.textMain,
    displayColor: AppColors.textMain,
  );

  static TextStyle get display => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );

  static TextStyle get heading => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );

  static TextStyle get title => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );

  static TextStyle get subtitle =>
      GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary);

  static TextStyle get body =>
      GoogleFonts.poppins(fontSize: 14, color: AppColors.textMain);

  static TextStyle get bodySmall =>
      GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary);

  static TextStyle get hint =>
      GoogleFonts.poppins(fontSize: 14, color: AppColors.greyHint);

  static TextStyle get buttonPrimary => GoogleFonts.poppins(
    color: AppColors.white,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static TextStyle get buttonSecondary => GoogleFonts.poppins(
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static TextStyle get tabActive => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get tabInactive => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get link => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get small =>
      GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary);

  static TextStyle get error =>
      GoogleFonts.poppins(fontSize: 12, color: AppColors.error);

  static TextStyle get caption =>
      GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted);
}
