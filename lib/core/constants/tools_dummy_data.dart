import 'package:flutter/material.dart';

class ToolsDummyData {
  static final List<Map<String, dynamic>> categories = [
    {
      'title': 'Smart Tools',
      'description': 'Powered by AI',
      'tools': [
        {
          'icon': Icons.smart_toy_rounded,
          'label': 'AI Assistant',
          'description': 'Tanya apapun dengan AI',
          'color': Color(0xFF4D96FF),
          'route': 'ai_assistant',
          'available': true,
        },
        {
          'icon': Icons.document_scanner_rounded,
          'label': 'Scanner',
          'description': 'Scan dokumen ke teks',
          'color': Color(0xFFFF6B6B),
          'route': 'scanner',
          'available': false,
        },
        {
          'icon': Icons.image_search_rounded,
          'label': 'Pict to Text',
          'description': 'Extract teks dari gambar',
          'color': Color(0xFFB79CED),
          'route': 'pict_to_text',
          'available': false,
        },
      ],
    },
    {
      'title': 'Belajar',
      'description': 'Alat bantu produktivitas',
      'tools': [
        {
          'icon': Icons.timer_rounded,
          'label': 'Pomodoro',
          'description': 'Fokus 25 menit dengan timer',
          'color': Color(0xFFFF8C42),
          'route': 'pomodoro',
          'available': true,
        },
        {
          'icon': Icons.checklist_rounded,
          'label': 'To-Do List',
          'description': 'Kelola tugas harianmu',
          'color': Color(0xFF6BCB77),
          'route': 'todo',
          'available': true,
        },
        {
          'icon': Icons.style_rounded,
          'label': 'Flashcard',
          'description': 'Hafal materi dengan cepat',
          'color': Color(0xFFFFD166),
          'route': 'flashcard',
          'available': false,
        },
      ],
    },
    {
      'title': 'Konversi',
      'description': 'Currency, waktu, satuan',
      'tools': [
        {
          'icon': Icons.currency_exchange_rounded,
          'label': 'Mata Uang',
          'description': 'Konversi multi-currency',
          'color': Color(0xFF6BCB77),
          'route': 'currency',
          'available': true,
        },
        {
          'icon': Icons.schedule_rounded,
          'label': 'Zona Waktu',
          'description': 'WIB, WIT, UTC, dll',
          'color': Color(0xFF4D96FF),
          'route': 'timezone',
          'available': true,
        },
        {
          'icon': Icons.straighten_rounded,
          'label': 'Satuan',
          'description': 'Panjang, berat, suhu',
          'color': Color(0xFFB79CED),
          'route': 'unit',
          'available': true,
        },
      ],
    },
    {
      'title': 'Lokasi & Sensor',
      'description': 'LBS dan device sensor',
      'tools': [
        {
          'icon': Icons.explore_rounded,
          'label': 'Kompas',
          'description': 'Penunjuk arah mata angin',
          'color': Color(0xFFFF8C42),
          'route': 'compass',
          'available': true,
        },
        {
          'icon': Icons.architecture_rounded,
          'label': 'Waterpas',
          'description': 'Level permukaan datar',
          'color': Color(0xFFFFD166),
          'route': 'level',
          'available': false,
        },
      ],
    },
    {
      'title': 'Game',
      'description': 'Fun & edukasi',
      'tools': [
        {
          'icon': Icons.extension_rounded,
          'label': 'Memory',
          'description': 'Asah otak dengan memory',
          'color': Color(0xFFFF6B6B),
          'route': 'memory',
          'available': false,
        },
      ],
    },
  ];
}
