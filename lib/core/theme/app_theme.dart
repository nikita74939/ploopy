import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF18181B);
  static const Color primaryContainer = Color(0xFFF4F4F5);

  static ThemeData get lightTheme => ThemeData(
    colorSchemeSeed: primaryColor,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    textTheme: GoogleFonts.robotoMonoTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
