import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploopy/features/ai/presentation/pages/ai_page.dart';
import 'package:ploopy/features/ocr/presentation/pages/ocr_home_page.dart';
import 'package:ploopy/features/scanner/presentation/pages/scanner_home_page.dart';
import 'package:ploopy/features/todo/presentation/pages/todo_page.dart';
import 'package:ploopy/features/tools/presentation/pages/compass_page.dart';
import 'package:ploopy/features/tools/presentation/pages/pomodoro_page.dart';
import 'package:ploopy/features/tools/presentation/pages/timezone_converter_page.dart';
import 'package:ploopy/features/tools/presentation/pages/unit_converter_page.dart';
import 'package:ploopy/core/constants/tools_dummy_data.dart';
import 'package:ploopy/features/tools/presentation/widgets/tool_category_section.dart';
import 'currency_converter_page.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...ToolsDummyData.categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ToolCategorySection(
                        category: cat,
                        onToolTap: (tool) => _handleToolTap(context, tool),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tools',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Alat bantu buat produktivitasmu',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _handleToolTap(BuildContext context, Map<String, dynamic> tool) {
    final available = tool['available'] as bool;
    final label = tool['label'] as String;
    final route = tool['route'] as String;

    if (!available) {
      _showComingSoon(context, label);
      return;
    }

    switch (route) {
      case 'currency': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CurrencyConverterPage()),
        );
        break;
      case 'timezone': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TimezoneConverterPage()),
        );
      case 'scanner': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScannerHomePage()),
        );
      case 'unit': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UnitConverterPage()),
        );
        break;
      case 'ai_assistant': // ⭐ UPDATE
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiPage()),
        );
        break;
      case 'compass': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CompassPage()),
        );
        break;
      case 'pomodoro': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PomodoroPage()),
        );
        break;
      case 'todo': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TodoPage()),
        );
        break;
      case 'pict_to_text': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OcrHomePage()),
        );
        break;
      default:
        _showComingSoon(context, label);
    }
  }

  void _showComingSoon(BuildContext context, String toolName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🚧', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$toolName — Coming soon!',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
