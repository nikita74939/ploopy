import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heading = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 13,
    color: AppColors.greyText,
  );

  static TextStyle body = GoogleFonts.poppins(fontSize: 13);

  static TextStyle hint = GoogleFonts.poppins(
    fontSize: 13,
    color: AppColors.greyHint,
  );

  static TextStyle buttonPrimary = GoogleFonts.poppins(
    color: AppColors.white,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static TextStyle tabActive = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle tabInactive = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );

  static TextStyle link = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.primary,
  );

  static TextStyle small = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.grey,
  );

  static TextStyle error = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.error,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.greyHint,
  );
}