import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF8C42);
  static const Color primaryContainer = Color(0xFFFFF3E9);
  
  static ThemeData get lightTheme => ThemeData(
    colorSchemeSeed: primaryColor,
    useMaterial3: true,
    textTheme: GoogleFonts.poppinsTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}