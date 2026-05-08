import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const Color primary = Colors.orange;
  static Color primaryLight = Colors.orange.shade50;
  static Color primaryBorder = Colors.orange.shade200;

  // Neutral
  static const Color white = Colors.white;
  static const Color black = Colors.black87;
  static Color grey = Colors.grey;
  static Color greyLight = Colors.grey.shade100;
  static Color greyLighter = Colors.grey.shade50;
  static Color greyBorder = Colors.grey.shade200;
  static Color greyHint = Colors.grey.shade400;
  static Color greyText = Colors.grey.shade500;
  static Color greyHandle = Colors.grey.shade300;

  // Status
  static const Color error = Colors.red;

    static ThemeData get lightTheme => ThemeData(
    colorSchemeSeed: primary,
    useMaterial3: true,
    textTheme: GoogleFonts.poppinsTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}