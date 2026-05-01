import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF6B2C);
  static const Color primaryContainer = Color(0xFFFFF0EA);

  static ThemeData get lightTheme => ThemeData(
    colorSchemeSeed: primaryColor,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFFFBF8),
    textTheme: GoogleFonts.poppinsTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
