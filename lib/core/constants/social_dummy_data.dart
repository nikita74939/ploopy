import 'package:flutter/material.dart';

class SocialDummyData {
  // Stories / Active Users
  static final List<Map<String, dynamic>> activeUsers = [
    {'name': 'Kamu', 'avatar': 'K', 'color': Color(0xFFFF8C42), 'isMe': true},
    {
      'name': 'Andi',
      'avatar': 'A',
      'color': Color(0xFF4D96FF),
      'isOnline': true,
    },
    {
      'name': 'Bella',
      'avatar': 'B',
      'color': Color(0xFFFF6B6B),
      'isOnline': true,
    },
    {
      'name': 'Cindy',
      'avatar': 'C',
      'color': Color(0xFF6BCB77),
      'isOnline': false,
    },
    {
      'name': 'Doni',
      'avatar': 'D',
      'color': Color(0xFFB79CED),
      'isOnline': true,
    },
    {
      'name': 'Erin',
      'avatar': 'E',
      'color': Color(0xFFFFD166),
      'isOnline': false,
    },
    {
      'name': 'Fajar',
      'avatar': 'F',
      'color': Color(0xFF4D96FF),
      'isOnline': true,
    },
  ];

  // Feed For You (seluruh user)

  // Feed For You (seluruh user)
  static final List<Map<String, dynamic>> forYouPosts = [
    {
      'authorName': 'Andi Saputra',
      'authorAvatar': 'A',
      'authorColor': Color(0xFF4D96FF),
      'isFriend': true,
      'date': '2h',
      'fullDate': '2 jam lalu',
      'location': 'GOR Senayan', // ⭐ NEW
      'distance': '1.2 km', // ⭐ NEW
      'content':
          'Finally 🔥 streak 30 hari! Konsistensi emang kunci. Yuk semangat terus gengs! 💪',
      'images': ['https://picsum.photos/seed/fire30/400/300'],
      'achievements': [
        {'icon': '🔥', 'color': Color(0xFFFFE0E0)},
        {'icon': '🏆', 'color': Color(0xFFFFF3E0)},
        {'icon': '⭐', 'color': Color(0xFFE0ECFF)},
      ],
      'info': [
        {'icon': '📅', 'text': 'Streak 30 hari'},
        {'icon': '⏱️', 'text': 'Total 85 jam'},
      ],
      'likes': 42,
      'comments': 12,
      'liked': false,
    },
    {
      'authorName': 'Bella Pratiwi',
      'authorAvatar': 'B',
      'authorColor': Color(0xFFFF6B6B),
      'isFriend': true,
      'date': '4h',
      'fullDate': '4 jam lalu',
      'location': 'Perpustakaan Pusat', // ⭐ NEW
      'distance': '350 m', // ⭐ NEW
      'content':
          'Study date with my best friends 📚✨ belajar Kalkulus bareng di perpustakaan',
      'images': [
        'https://picsum.photos/seed/study2/300/300',
        'https://picsum.photos/seed/library/300/300',
      ],
      'achievements': [
        {'icon': '📚', 'color': Color(0xFFE0ECFF)},
        {'icon': '👥', 'color': Color(0xFFE0F5E0)},
      ],
      'info': [
        {'icon': '📖', 'text': '13:00 - 17:00'},
        {'icon': '📍', 'text': 'Perpus Pusat'},
      ],
      'likes': 28,
      'comments': 5,
      'liked': true,
    },
    {
      'authorName': 'Cindy Wijaya',
      'authorAvatar': 'C',
      'authorColor': Color(0xFF6BCB77),
      'isFriend': false,
      'date': '6h',
      'fullDate': '6 jam lalu',
      'location': 'Taman Menteng', // ⭐ NEW
      'distance': '4.5 km', // ⭐ NEW
      'content':
          'Morning run completed! 🏃‍♀️ 5km dalam 28 menit. Healthy body, healthy mind 💚',
      'images': ['https://picsum.photos/seed/run1/400/300'],
      'achievements': [
        {'icon': '🏃', 'color': Color(0xFFE0F5E0)},
        {'icon': '💚', 'color': Color(0xFFE0F5E0)},
      ],
      'info': [
        {'icon': '⏱️', 'text': '28 menit'},
        {'icon': '📏', 'text': '5.2 km'},
      ],
      'likes': 67,
      'comments': 18,
      'liked': false,
    },
    {
      'authorName': 'Doni Herlambang',
      'authorAvatar': 'D',
      'authorColor': Color(0xFFB79CED),
      'isFriend': true,
      'date': '8h',
      'fullDate': '8 jam lalu',
      // Tidak ada location (optional)
      'content':
          'Baru aja unlock achievement "Brain Master" 🧠 50 jam belajar tercapai!',
      'images': [],
      'achievements': [
        {'icon': '🧠', 'color': Color(0xFFF0E0FF)},
        {'icon': '🏅', 'color': Color(0xFFFFF3E0)},
      ],
      'info': [
        {'icon': '🎯', 'text': 'Total 50 jam'},
        {'icon': '🏆', 'text': 'New achievement!'},
      ],
      'likes': 35,
      'comments': 8,
      'liked': true,
    },
    {
      'authorName': 'Erin Putri',
      'authorAvatar': 'E',
      'authorColor': Color(0xFFFFD166),
      'isFriend': false,
      'date': '12h',
      'fullDate': '12 jam lalu',
      'location': 'Kopi Kenangan Sudirman', // ⭐ NEW
      'distance': '2.8 km', // ⭐ NEW
      'content':
          'Matcha + Study = Vibes 🍵📖 pomodoro session hari ini produktif banget!',
      'images': [
        'https://picsum.photos/seed/matcha2/300/300',
        'https://picsum.photos/seed/note1/300/300',
        'https://picsum.photos/seed/laptop/300/300',
      ],
      'achievements': [
        {'icon': '🍵', 'color': Color(0xFFE0F5E0)},
        {'icon': '⏰', 'color': Color(0xFFE0ECFF)},
      ],
      'info': [
        {'icon': '🍅', 'text': '6 pomodoro'},
        {'icon': '☕', 'text': 'Cozy Cafe'},
      ],
      'likes': 89,
      'comments': 23,
      'liked': false,
    },
    {
      'authorName': 'Fajar Ramadhan',
      'authorAvatar': 'F',
      'authorColor': Color(0xFF4D96FF),
      'isFriend': true,
      'date': '1d',
      'fullDate': '1 hari lalu',
      // Tidak ada location (optional)
      'content':
          'Coding session late night 👨‍💻 akhirnya project Flutter-nya jalan juga!',
      'images': ['https://picsum.photos/seed/code1/400/300'],
      'achievements': [
        {'icon': '💻', 'color': Color(0xFFE0ECFF)},
        {'icon': '🚀', 'color': Color(0xFFFFE0E0)},
      ],
      'info': [
        {'icon': '🌙', 'text': '22:00 - 02:30'},
        {'icon': '⌨️', 'text': 'Flutter project'},
      ],
      'likes': 54,
      'comments': 14,
      'liked': false,
    },
  ];

  // Filter hanya teman
  static List<Map<String, dynamic>> get friendsPosts =>
      forYouPosts.where((p) => p['isFriend'] == true).toList();
}
