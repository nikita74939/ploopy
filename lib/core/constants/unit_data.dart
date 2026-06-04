import 'package:flutter/material.dart';

class UnitCategory {
  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final Color color;
  final List<UnitItem> units;

  const UnitCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.units,
  });
}

class UnitItem {
  final String code;
  final String name;
  final String symbol;
  final double factor; // relatif ke base unit
  final double? offset; // untuk suhu

  const UnitItem({
    required this.code,
    required this.name,
    required this.symbol,
    required this.factor,
    this.offset,
  });
}

class UnitData {
  static final List<UnitCategory> categories = [
    // ========== PANJANG ==========
    UnitCategory(
      id: 'length',
      name: 'Panjang',
      emoji: '',
      icon: Icons.straighten_rounded,
      color: Color(0xFF4D96FF),
      units: [
        UnitItem(code: 'mm', name: 'Milimeter', symbol: 'mm', factor: 0.001),
        UnitItem(code: 'cm', name: 'Sentimeter', symbol: 'cm', factor: 0.01),
        UnitItem(code: 'm', name: 'Meter', symbol: 'm', factor: 1),
        UnitItem(code: 'km', name: 'Kilometer', symbol: 'km', factor: 1000),
        UnitItem(code: 'in', name: 'Inci', symbol: 'in', factor: 0.0254),
        UnitItem(code: 'ft', name: 'Kaki', symbol: 'ft', factor: 0.3048),
        UnitItem(code: 'yd', name: 'Yard', symbol: 'yd', factor: 0.9144),
        UnitItem(code: 'mi', name: 'Mil', symbol: 'mi', factor: 1609.344),
      ],
    ),

    // ========== BERAT ==========
    UnitCategory(
      id: 'weight',
      name: 'Berat',
      emoji: '',
      icon: Icons.scale_rounded,
      color: Color(0xFF6BCB77),
      units: [
        UnitItem(code: 'mg', name: 'Miligram', symbol: 'mg', factor: 0.001),
        UnitItem(code: 'g', name: 'Gram', symbol: 'g', factor: 1),
        UnitItem(code: 'kg', name: 'Kilogram', symbol: 'kg', factor: 1000),
        UnitItem(code: 'ton', name: 'Ton', symbol: 't', factor: 1000000),
        UnitItem(code: 'oz', name: 'Ons', symbol: 'oz', factor: 28.3495),
        UnitItem(code: 'lb', name: 'Pound', symbol: 'lb', factor: 453.592),
        UnitItem(code: 'st', name: 'Stone', symbol: 'st', factor: 6350.29),
      ],
    ),

    // ========== SUHU ==========
    UnitCategory(
      id: 'temperature',
      name: 'Suhu',
      emoji: '',
      icon: Icons.thermostat_rounded,
      color: Color(0xFFFF6B6B),
      units: [
        UnitItem(code: 'c', name: 'Celsius', symbol: '°C', factor: 1),
        UnitItem(code: 'f', name: 'Fahrenheit', symbol: '°F', factor: 1),
        UnitItem(code: 'k', name: 'Kelvin', symbol: 'K', factor: 1),
      ],
    ),

    // ========== VOLUME ==========
    UnitCategory(
      id: 'volume',
      name: 'Volume',
      emoji: '',
      icon: Icons.water_drop_rounded,
      color: Color(0xFFB79CED),
      units: [
        UnitItem(code: 'ml', name: 'Mililiter', symbol: 'ml', factor: 0.001),
        UnitItem(code: 'l', name: 'Liter', symbol: 'L', factor: 1),
        UnitItem(code: 'm3', name: 'Meter Kubik', symbol: 'm³', factor: 1000),
        UnitItem(
          code: 'gal',
          name: 'Galon (US)',
          symbol: 'gal',
          factor: 3.78541,
        ),
        UnitItem(code: 'qt', name: 'Quart', symbol: 'qt', factor: 0.946353),
        UnitItem(code: 'pt', name: 'Pint', symbol: 'pt', factor: 0.473176),
        UnitItem(code: 'cup', name: 'Cangkir', symbol: 'cup', factor: 0.236588),
      ],
    ),

    // ========== LUAS ==========
    UnitCategory(
      id: 'area',
      name: 'Luas',
      emoji: '',
      icon: Icons.crop_square_rounded,
      color: Color(0xFFFF8C42),
      units: [
        UnitItem(
          code: 'mm2',
          name: 'Milimeter²',
          symbol: 'mm²',
          factor: 0.000001,
        ),
        UnitItem(
          code: 'cm2',
          name: 'Sentimeter²',
          symbol: 'cm²',
          factor: 0.0001,
        ),
        UnitItem(code: 'm2', name: 'Meter²', symbol: 'm²', factor: 1),
        UnitItem(
          code: 'km2',
          name: 'Kilometer²',
          symbol: 'km²',
          factor: 1000000,
        ),
        UnitItem(code: 'ha', name: 'Hektar', symbol: 'ha', factor: 10000),
        UnitItem(code: 'ac', name: 'Acre', symbol: 'ac', factor: 4046.86),
        UnitItem(code: 'ft2', name: 'Kaki²', symbol: 'ft²', factor: 0.092903),
      ],
    ),

    // ========== KECEPATAN ==========
    UnitCategory(
      id: 'speed',
      name: 'Kecepatan',
      emoji: '',
      icon: Icons.speed_rounded,
      color: Color(0xFFFFD166),
      units: [
        UnitItem(code: 'ms', name: 'Meter/detik', symbol: 'm/s', factor: 1),
        UnitItem(
          code: 'kmh',
          name: 'Kilometer/jam',
          symbol: 'km/h',
          factor: 0.277778,
        ),
        UnitItem(code: 'mph', name: 'Mil/jam', symbol: 'mph', factor: 0.44704),
        UnitItem(code: 'kn', name: 'Knot', symbol: 'kn', factor: 0.514444),
        UnitItem(
          code: 'fts',
          name: 'Kaki/detik',
          symbol: 'ft/s',
          factor: 0.3048,
        ),
      ],
    ),

    // ========== WAKTU ==========
    UnitCategory(
      id: 'time',
      name: 'Waktu',
      emoji: '',
      icon: Icons.access_time_rounded,
      color: Color(0xFF4D96FF),
      units: [
        UnitItem(code: 'ms', name: 'Milidetik', symbol: 'ms', factor: 0.001),
        UnitItem(code: 's', name: 'Detik', symbol: 's', factor: 1),
        UnitItem(code: 'min', name: 'Menit', symbol: 'min', factor: 60),
        UnitItem(code: 'h', name: 'Jam', symbol: 'h', factor: 3600),
        UnitItem(code: 'd', name: 'Hari', symbol: 'd', factor: 86400),
        UnitItem(code: 'w', name: 'Minggu', symbol: 'w', factor: 604800),
        UnitItem(code: 'mo', name: 'Bulan', symbol: 'mo', factor: 2628000),
        UnitItem(code: 'y', name: 'Tahun', symbol: 'y', factor: 31536000),
      ],
    ),

    // ========== DATA ==========
    UnitCategory(
      id: 'data',
      name: 'Data',
      emoji: '',
      icon: Icons.storage_rounded,
      color: Color(0xFF6BCB77),
      units: [
        UnitItem(code: 'b', name: 'Byte', symbol: 'B', factor: 1),
        UnitItem(code: 'kb', name: 'Kilobyte', symbol: 'KB', factor: 1024),
        UnitItem(code: 'mb', name: 'Megabyte', symbol: 'MB', factor: 1048576),
        UnitItem(
          code: 'gb',
          name: 'Gigabyte',
          symbol: 'GB',
          factor: 1073741824,
        ),
        UnitItem(
          code: 'tb',
          name: 'Terabyte',
          symbol: 'TB',
          factor: 1099511627776,
        ),
      ],
    ),
  ];

  static UnitCategory? getCategory(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Konversi umum (kecuali suhu)
  static double convertGeneral({
    required double value,
    required UnitItem from,
    required UnitItem to,
  }) {
    final baseValue = value * from.factor;
    return baseValue / to.factor;
  }

  /// Konversi suhu (special case)
  static double convertTemperature({
    required double value,
    required String fromCode,
    required String toCode,
  }) {
    // Convert to Celsius first
    double celsius;
    switch (fromCode) {
      case 'c':
        celsius = value;
        break;
      case 'f':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'k':
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }

    // Convert from Celsius to target
    switch (toCode) {
      case 'c':
        return celsius;
      case 'f':
        return celsius * 9 / 5 + 32;
      case 'k':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }
}
