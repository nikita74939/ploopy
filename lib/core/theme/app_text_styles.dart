import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heading = GoogleFonts.robotoMono(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitle = GoogleFonts.robotoMono(
    fontSize: 13,
    color: AppColors.greyText,
  );

  static TextStyle body = GoogleFonts.robotoMono(fontSize: 13);

  static TextStyle hint = GoogleFonts.robotoMono(
    fontSize: 13,
    color: AppColors.greyHint,
  );

  static TextStyle buttonPrimary = GoogleFonts.robotoMono(
    color: AppColors.white,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static TextStyle tabActive = GoogleFonts.robotoMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle tabInactive = GoogleFonts.robotoMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );

  static TextStyle link = GoogleFonts.robotoMono(
    fontSize: 12,
    color: AppColors.primary,
  );

  static TextStyle small = GoogleFonts.robotoMono(
    fontSize: 12,
    color: AppColors.grey,
  );

  static TextStyle error = GoogleFonts.robotoMono(
    fontSize: 12,
    color: AppColors.error,
  );

  static TextStyle caption = GoogleFonts.robotoMono(
    fontSize: 12,
    color: AppColors.greyHint,
  );
}
