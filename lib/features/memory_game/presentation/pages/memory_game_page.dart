import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/memory_card_widget.dart';
import '../widgets/game_stats_bar.dart';
import '../widgets/game_result_dialog.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  // Emoji pairs untuk kartu
  static const List<String> _emojis = [
    '🧠', '📚', '💡', '🎯', '🔬', '🎨', '🚀', '🌟',
  ];

  late List<_CardModel> _cards;
  List<int> _flippedIndices = [];
  bool _isChecking = false;
  int _moves = 0;
  int _matchedPairs = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initGame() {
    final pairs = [..._emojis, ..._emojis];
    pairs.shuffle();
    _cards = pairs
        .asMap()
        .entries
        .map((e) => _CardModel(id: e.key, emoji: e.value))
        .toList();
    _flippedIndices = [];
    _moves = 0;
    _matchedPairs = 0;
    _seconds = 0;
    _gameStarted = false;
    _timer?.cancel();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isMatched) return;
    if (_flippedIndices.contains(index)) return;
    if (_flippedIndices.length >= 2) return;

    if (!_gameStarted) {
      _gameStarted = true;
      _startTimer();
    }

    setState(() {
      _flippedIndices.add(index);
      _cards[index] = _cards[index].copyWith(isFlipped: true);
    });

    if (_flippedIndices.length == 2) {
      _moves++;
      _isChecking = true;
      _checkMatch();
    }
  }

  void _checkMatch() {
    final a = _flippedIndices[0];
    final b = _flippedIndices[1];

    if (_cards[a].emoji == _cards[b].emoji) {
      // Match!
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _cards[a] = _cards[a].copyWith(isMatched: true, isFlipped: false);
          _cards[b] = _cards[b].copyWith(isMatched: true, isFlipped: false);
          _flippedIndices = [];
          _matchedPairs++;
          _isChecking = false;
        });

        if (_matchedPairs == _emojis.length) {
          _timer?.cancel();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            GameResultDialog.show(
              context,
              moves: _moves,
              seconds: _seconds,
              onRestart: _restartGame,
              onExit: () => Navigator.pop(context),
            );
          });
        }
      });
    } else {
      // No match - flip back
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _cards[a] = _cards[a].copyWith(isFlipped: false);
          _cards[b] = _cards[b].copyWith(isFlipped: false);
          _flippedIndices = [];
          _isChecking = false;
        });
      });
    }
  }

  void _restartGame() {
    setState(() {
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Memory Game',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Restart',
            onPressed: _restartGame,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Subtitle
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Temukan semua pasangan kartu!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13,
              ),
            ),
          ),

          // Stats bar
          GameStatsBar(
            moves: _moves,
            matches: _matchedPairs,
            totalPairs: _emojis.length,
            seconds: _seconds,
          ),

          // Game grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return MemoryCardWidget(
                    emoji: card.emoji,
                    isFlipped: card.isFlipped,
                    isMatched: card.isMatched,
                    onTap: () => _onCardTap(index),
                  );
                },
              ),
            ),
          ),

          // Tip
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_rounded,
                    color: const Color(0xFFFFB74D).withOpacity(0.6), size: 14),
                const SizedBox(width: 4),
                Text(
                  'Latih memorimu dengan mencari pasangan kartu',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple immutable model untuk kartu
class _CardModel {
  final int id;
  final String emoji;
  final bool isFlipped;
  final bool isMatched;

  const _CardModel({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });

  _CardModel copyWith({bool? isFlipped, bool? isMatched}) {
    return _CardModel(
      id: id,
      emoji: emoji,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
