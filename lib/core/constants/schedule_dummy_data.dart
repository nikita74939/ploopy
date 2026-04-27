import 'package:flutter/material.dart';

class ScheduleDummyData {
  static final List<Map<String, dynamic>> todayItems = [
    {
      'time': '06.00',
      'title': 'Minum segelas air',
      'streak': '3 hari',
      'duration': '5 mnt',
      'color': const Color(0xFFFF8C42),
      'icon': Icons.local_drink_outlined,
      'done': true,
    },
    {
      'time': '06.30',
      'title': 'Meditasi & relaksasi',
      'streak': '6 hari',
      'duration': '15 mnt',
      'color': const Color(0xFF6BCB77),
      'icon': Icons.self_improvement_outlined,
      'done': true,
    },
    {
      'time': '07.00',
      'title': 'Matematika — Bab 5',
      'streak': '',
      'duration': '45 mnt',
      'color': const Color(0xFF4D96FF),
      'icon': Icons.calculate_outlined,
      'done': false,
    },
    {
      'time': '08.00',
      'title': 'Stretching 10 menit',
      'streak': '5 hari',
      'duration': '10 mnt',
      'color': const Color(0xFFB79CED),
      'icon': Icons.sports_gymnastics,
      'done': false,
    },
    {
      'time': '10.00',
      'title': 'Bahasa Inggris — Reading',
      'streak': '',
      'duration': '30 mnt',
      'color': const Color(0xFFFF6B6B),
      'icon': Icons.menu_book_outlined,
      'done': false,
    },
    {
      'time': '15.00',
      'title': 'Jalan-jalan singkat',
      'streak': '3 hari',
      'duration': '20 mnt',
      'color': const Color(0xFFFFD166),
      'icon': Icons.directions_walk_outlined,
      'done': false,
    },
  ];
}