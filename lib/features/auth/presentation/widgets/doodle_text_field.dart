import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/doodle_container.dart';

class DoodleTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final int? maxLines;

  const DoodleTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.maxLines = 1, // Berikan default value 1 disini
  });

  @override
  State<DoodleTextField> createState() => _DoodleTextFieldState();
}

class _DoodleTextFieldState extends State<DoodleTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return DoodleContainer(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              // Jika isPassword true, pastikan obscureText aktif sesuai state
              obscureText: widget.isPassword ? _obscureText : false,

              /* 
                PERBAIKAN UTAMA: 
                Jika itu password, maxLines HARUS 1. 
                Jika bukan, gunakan widget.maxLines (yang sekarang defaultnya 1).
              */
              maxLines: widget.isPassword ? 1 : widget.maxLines,

              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textMain,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (widget.isPassword)
            GestureDetector(
              onTap: () => setState(() => _obscureText = !_obscureText),
              child: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMain,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}
