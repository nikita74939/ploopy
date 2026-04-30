import 'package:flutter/material.dart';

class SocialDummyData {
  static final List<Map<String, dynamic>> activeUsers = [
    {'name': 'Kamu', 'avatar': 'K', 'color': Color(0xFF18181B), 'isMe': true},
    {
      'name': 'Nadia',
      'avatar': 'N',
      'color': Color(0xFF3F3F46),
      'isOnline': true,
    },
    {
      'name': 'Rafi',
      'avatar': 'R',
      'color': Color(0xFF52525B),
      'isOnline': true,
    },
    {
      'name': 'Alya',
      'avatar': 'A',
      'color': Color(0xFF71717A),
      'isOnline': false,
    },
    {
      'name': 'Dimas',
      'avatar': 'D',
      'color': Color(0xFF27272A),
      'isOnline': true,
    },
  ];

  static final List<Map<String, dynamic>> forYouPosts = [
    {
      'authorName': 'Nadia Putri',
      'authorAvatar': 'N',
      'authorAvatarUrl':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&h=160&fit=crop&crop=faces',
      'authorColor': Color(0xFF18181B),
      'isFriend': true,
      'date': '2j',
      'fullDate': '2 jam lalu',
      'location': 'Perpustakaan Kampus',
      'distance': '300 m',
      'content':
          'Selesai review materi Metodologi Penelitian. Tinggal rapihin daftar pustaka dan slide presentasi.',
      'images': [
        'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=900&h=600&fit=crop',
      ],
      'achievements': [
        {'label': 'Task complete', 'color': Color(0xFFF4F4F5)},
      ],
      'info': [
        {'icon': Icons.check_circle_outline_rounded, 'text': 'Task complete'},
      ],
      'likes': 18,
      'comments': 4,
      'liked': false,
    },
    {
      'authorName': 'Rafi Ramadhan',
      'authorAvatar': 'R',
      'authorAvatarUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop&crop=faces',
      'authorColor': Color(0xFF3F3F46),
      'isFriend': true,
      'date': '5j',
      'fullDate': '5 jam lalu',
      'location': 'Lab Informatika',
      'distance': '650 m',
      'content':
          'Praktikum Basis Data minggu ini selesai. Catatan query join aku upload malam ini buat teman satu kelompok.',
      'images': [],
      'achievements': [
        {'label': 'Schedule complete', 'color': Color(0xFFF4F4F5)},
      ],
      'info': [
        {'icon': Icons.event_available_outlined, 'text': 'Schedule complete'},
      ],
      'likes': 27,
      'comments': 9,
      'liked': true,
    },
    {
      'authorName': 'Alya Maharani',
      'authorAvatar': 'A',
      'authorAvatarUrl':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=160&h=160&fit=crop&crop=faces',
      'authorColor': Color(0xFF52525B),
      'isFriend': false,
      'date': '1h',
      'fullDate': '1 hari lalu',
      'location': 'Student Center',
      'distance': '1.1 km',
      'content':
          'Butuh 2 orang lagi buat belajar bareng Statistik. Fokus latihan soal regresi linear, jam 19.00.',
      'images': [
        'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=900&h=600&fit=crop',
      ],
      'achievements': [],
      'info': [],
      'likes': 14,
      'comments': 15,
      'liked': false,
    },
    {
      'authorName': 'Dimas Arya',
      'authorAvatar': 'D',
      'authorAvatarUrl':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=160&h=160&fit=crop&crop=faces',
      'authorColor': Color(0xFF27272A),
      'isFriend': true,
      'date': '2h',
      'fullDate': '2 hari lalu',
      'content':
          'Akhirnya submit proposal PKM sebelum deadline. Semoga revisinya tidak terlalu banyak.',
      'images': [],
      'achievements': [
        {'label': 'Achievement', 'color': Color(0xFFF4F4F5)},
      ],
      'info': [
        {'icon': Icons.workspace_premium_outlined, 'text': 'Achievement'},
      ],
      'likes': 36,
      'comments': 12,
      'liked': false,
    },
  ];

  static List<Map<String, dynamic>> get friendsPosts =>
      forYouPosts.where((p) => p['isFriend'] == true).toList();
}
