import 'package:flutter/material.dart';

class ProfileDummyData {
  // Stats
  static const int totalFriends = 128;
  static const int totalActivities = 342;
  static const int currentStreak = 12;
  static const int longestStreak = 28;
  static const int joinYear = 2024;

  // Achievements (untuk section achievement)
  static final List<Map<String, dynamic>> achievements = [
    {
      'icon': Icons.local_fire_department_rounded,
      'title': 'Fire Starter',
      'desc': 'Streak 7 hari',
      'color': Color(0xFFFF6B6B),
      'unlocked': true,
    },
    {
      'icon': Icons.workspace_premium_rounded,
      'title': 'Rising Star',
      'desc': '10 aktivitas',
      'color': Color(0xFFFFD166),
      'unlocked': true,
    },
    {
      'icon': Icons.psychology_rounded,
      'title': 'Brain Master',
      'desc': '50 jam belajar',
      'color': Color(0xFFB79CED),
      'unlocked': true,
    },
    {
      'icon': Icons.emoji_events_rounded,
      'title': 'Champion',
      'desc': 'Top 10 global',
      'color': Color(0xFF4D96FF),
      'unlocked': false,
    },
    {
      'icon': Icons.diamond_rounded,
      'title': 'Diamond',
      'desc': 'Premium user',
      'color': Color(0xFF6BCB77),
      'unlocked': false,
    },
  ];

  // ⭐ NEW: Feed Posts (Aktivitas = postingan user)
  // Ganti bagian feedPosts dengan ini:
  static final List<Map<String, dynamic>> feedPosts = [
    {
      'authorName': 'Kamu',
      'authorAvatar': 'K',
      'authorColor': Color(0xFFFF8C42),
      'date': '1 Thu',
      'fullDate': 'Kamis, 1 Agustus 2024',
      'content':
          'Spent a relaxing night cuddling with Peanut 🐶 Belajar jadi lebih semangat!',
      'images': [
        'https://picsum.photos/seed/dog1/300/300',
        'https://picsum.photos/seed/food1/300/300',
        'https://picsum.photos/seed/matcha1/300/300',
      ],
      'achievements': [
        {'icon': '🌸', 'color': Color(0xFFFFE0EC)},
        {'icon': '🛋️', 'color': Color(0xFFE0F5E0)},
        {'icon': '💤', 'color': Color(0xFFE0F0FF)},
        {'icon': '⭐', 'color': Color(0xFFE0ECFF)},
        {'icon': '🌱', 'color': Color(0xFFE0F5E0)},
      ],
      'info': [
        {'icon': '🌙', 'text': '12:30 AM - 07:25 AM'},
        {'icon': '🔥', 'text': 'Running 30m'},
      ],
    },
    {
      'authorName': 'Kamu',
      'authorAvatar': 'K',
      'authorColor': Color(0xFFFF8C42),
      'date': '30 Wed',
      'fullDate': 'Rabu, 30 Juli 2024',
      'content':
          'Finally selesai Matematika Bab 5! Susah banget tapi worth it 💪📚',
      'images': [
        'https://picsum.photos/seed/book1/300/300',
        'https://picsum.photos/seed/study1/300/300',
      ],
      'achievements': [
        {'icon': '📚', 'color': Color(0xFFE0ECFF)},
        {'icon': '🏆', 'color': Color(0xFFFFF3E0)},
      ],
      'info': [
        {'icon': '📖', 'text': '14:00 - 16:30'},
        {'icon': '🔥', 'text': 'Study 2h 30m'},
      ],
    },
    {
      'authorName': 'Kamu',
      'authorAvatar': 'K',
      'authorColor': Color(0xFFFF8C42),
      'date': '29 Tue',
      'fullDate': 'Selasa, 29 Juli 2024',
      'content':
          'Morning meditation sesh ☀️ Mental health is wealth, don\'t forget to breathe',
      'images': [],
      'achievements': [
        {'icon': '🧘', 'color': Color(0xFFF0E0FF)},
        {'icon': '☀️', 'color': Color(0xFFFFF3E0)},
      ],
      'info': [
        {'icon': '🌅', 'text': '06:00 - 06:15'},
        {'icon': '🧘', 'text': 'Meditation 15m'},
      ],
    },
    {
      'authorName': 'Kamu',
      'authorAvatar': 'K',
      'authorColor': Color(0xFFFF8C42),
      'date': '28 Mon',
      'fullDate': 'Senin, 28 Juli 2024',
      'content': 'Streak 7 hari tercapai! 🔥 Tetep semangat jaga konsistensi!',
      'images': ['https://picsum.photos/seed/fire1/300/300'],
      'achievements': [
        {'icon': '🔥', 'color': Color(0xFFFFE0E0)},
        {'icon': '🏅', 'color': Color(0xFFFFF3E0)},
      ],
      'info': [
        {'icon': '⏱️', 'text': 'Total 7 hari'},
        {'icon': '💪', 'text': 'Keep going!'},
      ],
    },
  ];
}
