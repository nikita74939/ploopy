import 'package:flutter/material.dart';

class ToolsData {
  static final List<Map<String, dynamic>> categories = [
    {
      'title': 'Smart Tools',
      'description': 'Alat bantu produktivitas',
      'tools': [
        {
          'icon': Icons.document_scanner_rounded,
          'label': 'Scanner',
          'description': 'Scan dokumen ke teks',
          'color': Color(0xFFFF6B6B),
          'route': 'scanner',
          'available': true,
        },
        {
          'icon': Icons.image_search_rounded,
          'label': 'Pict to Text',
          'description': 'Extract teks dari gambar',
          'color': Color(0xFFB79CED),
          'route': 'pict_to_text',
          'available': true,
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
          'route': 'memory_game',
          'available': true,
        },
      ],
    },
  ];
}
