import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/tools_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../memory_game/presentation/pages/memory_game_page.dart';
import '../../../ocr/presentation/pages/ocr_home_page.dart';
import '../../../scanner/presentation/pages/scanner_home_page.dart';
import '../widgets/tool_category_section.dart';
import 'compass_page.dart';
import 'currency_converter_page.dart';
import 'timezone_converter_page.dart';
import 'unit_converter_page.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...ToolsData.categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: ToolCategorySection(
                          category: cat,
                          onToolTap: (tool) => _handleToolTap(context, tool),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.greyBorder, width: 1),
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
                  color: AppColors.textMain,
                ),
              ),
              Text(
                'Alat bantu buat produktivitasmu',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.primary,
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
      case 'compass': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CompassPage()),
        );
        break;
      case 'pict_to_text': // ⭐ ADD
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OcrHomePage()),
        );
        break;
      case 'memory_game':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MemoryGamePage()),
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
            const Icon(
              Icons.construction_rounded,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$toolName — Coming soon!',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.textMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
