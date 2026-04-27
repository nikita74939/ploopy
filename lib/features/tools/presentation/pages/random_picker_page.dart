import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/choice_input_list.dart';
import '../widgets/spin_wheel.dart';
import '../widgets/winner_dialog.dart';

class RandomPickerPage extends StatefulWidget {
  const RandomPickerPage({super.key});

  @override
  State<RandomPickerPage> createState() => _RandomPickerPageState();
}

class _RandomPickerPageState extends State<RandomPickerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  final List<TextEditingController> _controllers = [];
  bool _isSpinning = false;
  double _currentRotation = 0;

  // Palet warna untuk wheel sections
  static const List<Color> _wheelColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFF8C42),
    Color(0xFFFFD166),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFB79CED),
    Color(0xFFFF6B9D),
    Color(0xFF06D6A0),
    Color(0xFFEF476F),
    Color(0xFFF78C6B),
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Initial 3 choices
    _controllers.addAll([
      TextEditingController(text: 'Pilihan A'),
      TextEditingController(text: 'Pilihan B'),
      TextEditingController(text: 'Pilihan C'),
    ]);
  }

  @override
  void dispose() {
    _spinController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _validChoices {
    return _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  void _addChoice() {
    if (_controllers.length >= 10) return;
    setState(() {
      _controllers.add(
        TextEditingController(text: 'Pilihan ${_controllers.length + 1}'),
      );
    });
    HapticFeedback.lightImpact();
  }

  void _removeChoice(int index) {
    if (_controllers.length <= 2) return;
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _spin() async {
    final choices = _validChoices;
    if (choices.length < 2) {
      _showError('Minimal 2 pilihan untuk spin! 🎲');
      return;
    }

    setState(() => _isSpinning = true);

    // Random winner index
    final random = math.Random();
    final winnerIndex = random.nextInt(choices.length);

    // Kalkulasi target rotation
    // Pointer ada di atas (12 o'clock), angle 0 = posisi atas
    // Section center angle = -π/2 + (i * sectionAngle + sectionAngle/2)
    final sectionAngle = (2 * math.pi) / choices.length;
    final winnerSectionCenter =
        winnerIndex * sectionAngle + sectionAngle / 2;

    // Rotasi wheel supaya winner ada di atas (di bawah pointer)
    // Wheel gerak counter-clockwise (kita negate angle)
    final targetAngle = -winnerSectionCenter;

    // Tambahkan 5 full rotations untuk efek spinning
    const fullRotations = 5 * 2 * math.pi;
    final finalRotation = _currentRotation +
        fullRotations +
        (targetAngle - (_currentRotation % (2 * math.pi)));

    _spinAnimation = Tween<double>(
      begin: _currentRotation,
      end: finalRotation,
    ).animate(
      CurvedAnimation(
        parent: _spinController,
        curve: Curves.easeOutCubic,
      ),
    )..addListener(() {
        setState(() => _currentRotation = _spinAnimation.value);
      });

    await _spinController.forward(from: 0);

    _currentRotation = finalRotation % (2 * math.pi);

    if (!mounted) return;
    setState(() => _isSpinning = false);

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Show winner dialog
    WinnerDialog.show(
      context: context,
      winner: choices[winnerIndex],
      winnerColor: _wheelColors[winnerIndex % _wheelColors.length],
      onSpinAgain: _spin,
    );
  }

  void _resetChoices() {
    setState(() {
      for (final c in _controllers) {
        c.dispose();
      }
      _controllers.clear();
      _controllers.addAll([
        TextEditingController(text: 'Pilihan A'),
        TextEditingController(text: 'Pilihan B'),
        TextEditingController(text: 'Pilihan C'),
      ]);
      _currentRotation = 0;
    });
    _spinController.reset();
    HapticFeedback.mediumImpact();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final choices = _validChoices;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Spin Wheel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SpinWheel(
                  choices: choices.isEmpty ? ['?', '?'] : choices,
                  rotation: _currentRotation,
                  colors: _wheelColors,
                ),
              ),
              const SizedBox(height: 20),

              // Spin Button
              _buildSpinButton(),
              const SizedBox(height: 24),

              // Input List
              ChoiceInputList(
                controllers: _controllers,
                colors: _wheelColors,
                onAdd: _addChoice,
                onRemove: _removeChoice,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey.shade50,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Random Picker',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: Colors.grey.shade700,
          ),
          onPressed: _isSpinning ? null : _resetChoices,
          tooltip: 'Reset',
        ),
      ],
    );
  }

  Widget _buildSpinButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _isSpinning ? Colors.grey.shade300 : AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _isSpinning ? null : _spin,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isSpinning
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isSpinning
                      ? Icons.hourglass_top_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  _isSpinning ? 'Sedang Memutar...' : 'SPIN!',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}