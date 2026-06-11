import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/memory_card_widget.dart';
import '../widgets/game_stats_bar.dart';
import '../widgets/game_result_dialog.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage>
    with WidgetsBindingObserver {
  static const List<IconData> _cardIcons = [
    Icons.psychology_rounded,
    Icons.menu_book_rounded,
    Icons.lightbulb_rounded,
    Icons.track_changes_rounded,
    Icons.science_rounded,
    Icons.palette_rounded,
    Icons.rocket_launch_rounded,
    Icons.auto_awesome_rounded,
  ];

  late List<_CardModel> _cards;
  List<int> _flippedIndices = [];
  bool _isChecking = false;
  int _moves = 0;
  int _matchedPairs = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _gameStarted = false;
  bool _isPaused = false;
  int _bestMoves = 0;
  int _bestTime = 0;
  bool _showHint = false;
  int? _hintIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBestScore();
    _initGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimer();
    }
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestMoves = prefs.getInt('memory_best_moves') ?? 0;
      _bestTime = prefs.getInt('memory_best_time') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    bool isNewRecord = false;

    if (_bestMoves == 0 || _moves < _bestMoves) {
      await prefs.setInt('memory_best_moves', _moves);
      _bestMoves = _moves;
      isNewRecord = true;
    }

    if (_bestTime == 0 || _seconds < _bestTime) {
      await prefs.setInt('memory_best_time', _seconds);
      _bestTime = _seconds;
      isNewRecord = true;
    }

    if (isNewRecord && mounted) {
      _showNewRecordDialog();
    }
  }

  void _initGame() {
    final pairs = [..._cardIcons, ..._cardIcons];
    pairs.shuffle();
    _cards = pairs
        .asMap()
        .entries
        .map((e) => _CardModel(id: e.key, icon: e.value))
        .toList();
    _flippedIndices = [];
    _moves = 0;
    _matchedPairs = 0;
    _seconds = 0;
    _gameStarted = false;
    _isPaused = false;
    _showHint = false;
    _hintIndex = null;
    _timer?.cancel();
  }

  void _pauseTimer() {
    if (_gameStarted && !_isPaused) {
      setState(() => _isPaused = true);
      _timer?.cancel();
    }
  }

  void _resumeTimer() {
    if (_gameStarted && _isPaused) {
      setState(() => _isPaused = false);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() => _seconds++);
      }
    });
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isMatched) return;
    if (_flippedIndices.contains(index)) return;

    if (!_gameStarted) {
      setState(() => _gameStarted = true);
      _startTimer();
    }

    HapticFeedback.lightImpact();

    setState(() {
      _flippedIndices.add(index);
      _showHint = false;
      _hintIndex = null;
    });

    if (_flippedIndices.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isChecking = true;
    _moves++;

    final first = _cards[_flippedIndices[0]];
    final second = _cards[_flippedIndices[1]];

    if (first.icon == second.icon) {
      HapticFeedback.mediumImpact();
      setState(() {
        _cards[_flippedIndices[0]].isMatched = true;
        _cards[_flippedIndices[1]].isMatched = true;
        _matchedPairs++;
        _flippedIndices = [];
        _isChecking = false;
      });

      if (_matchedPairs == _cardIcons.length) {
        _timer?.cancel();
        _saveBestScore();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            GameResultDialog.show(
              context,
              moves: _moves,
              seconds: _seconds,
              onRestart: _restartGame,
              onExit: () => Navigator.pop(context),
            );
          }
        });
      }
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _flippedIndices = [];
            _isChecking = false;
          });
        }
      });
    }
  }

  void _showHintDialog() {
    if (_moves < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimal 3 moves untuk menggunakan hint',
            style: AppTextStyles.body.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    int? firstUnmatched;
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].isMatched) {
        firstUnmatched = i;
        break;
      }
    }

    if (firstUnmatched != null) {
      setState(() {
        _showHint = true;
        _hintIndex = firstUnmatched;
        _moves++;
      });
    }
  }

  void _showNewRecordDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Rekor Baru!', style: AppTextStyles.heading),
          ],
        ),
        content: Text(
          'Selamat! Kamu memecahkan rekor terbaikmu!',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.buttonPrimary.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLighter,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Memory Game',
          style: AppTextStyles.heading.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          if (_bestMoves > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$_bestMoves',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.lightbulb_outline_rounded,
              color: _moves >= 3 ? AppColors.primary : AppColors.greyHint,
            ),
            onPressed: _showHintDialog,
            tooltip: 'Hint (3+ moves)',
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.grey),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text('Mulai Ulang?', style: AppTextStyles.heading),
                  content: Text(
                    'Progress saat ini akan hilang.',
                    style: AppTextStyles.body,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _restartGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        'Mulai Ulang',
                        style: AppTextStyles.buttonPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Temukan semua pasangan kartu!',
                style: AppTextStyles.subtitle,
              ),
            ),
            const SizedBox(height: 8),

            GameStatsBar(
              moves: _moves,
              matches: _matchedPairs,
              totalPairs: _cardIcons.length,
              seconds: _seconds,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final isFlipped = _flippedIndices.contains(index);
                    final showHint = _showHint && _hintIndex == index;

                    return Stack(
                      children: [
                        MemoryCardWidget(
                          icon: card.icon,
                          isFlipped: isFlipped || card.isMatched,
                          isMatched: card.isMatched,
                          onTap: () => _onCardTap(index),
                        ),
                        if (showHint)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryLight,
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Latih memorimu dengan mencari pasangan kartu',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardModel {
  final int id;
  final IconData icon;
  bool isMatched;

  // ignore: unused_element_parameter
  _CardModel({required this.id, required this.icon, this.isMatched = false});
}
