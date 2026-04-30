import 'package:flutter/material.dart';

class ScheduleDummyData {
  static List<Map<String, dynamic>> get todayItems => [
    {
      'title': 'Meditasi & Relaksasi',
      'time': '06.30',
      'icon': Icons.self_improvement_rounded,
      'color': Color(0xFF18181B),
      'done': true,
      'streak': '6',
      'duration': '15 mnt',
      'durationNum': 15,
    },
    {
      'title': 'Belajar Matematika',
      'time': '09.00',
      'icon': Icons.calculate_rounded,
      'color': Color(0xFF3F3F46),
      'done': false,
      'streak': '',
      'duration': '60 mnt',
      'durationNum': 60,
    },
    {
      'title': 'Baca Buku',
      'time': '13.00',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF52525B),
      'done': false,
      'streak': '',
      'duration': '30 mnt',
      'durationNum': 30,
    },
    {
      'title': 'Olahraga Ringan',
      'time': '16.00',
      'icon': Icons.fitness_center_rounded,
      'color': Color(0xFF71717A),
      'done': false,
      'streak': '',
      'duration': '45 mnt',
      'durationNum': 45,
    },
  ];

  static List<Map<String, dynamic>> get todayTasks => [
    {
      'title': 'Tugas Matematika Bab 5',
      'subject': 'Matematika',
      'icon': Icons.assignment_rounded,
      'color': Color(0xFF18181B),
      'done': false,
      'due': 'Hari ini',
    },
    {
      'title': 'Baca Chapter 3-4',
      'subject': 'Bahasa Inggris',
      'icon': Icons.book_rounded,
      'color': Color(0xFF3F3F46),
      'done': false,
      'due': 'Besok',
    },
    {
      'title': 'Makalah IPS',
      'subject': 'IPS',
      'icon': Icons.article_rounded,
      'color': Color(0xFF52525B),
      'done': false,
      'due': 'Kemarin',
    },
  ];
}
