class TimezoneData {
  static List<Map<String, String>> timezones = [
    _fromId('Asia/Jakarta', '+07:00', 'WIB'),
    _fromId('Asia/Makassar', '+08:00', 'WITA'),
    _fromId('Asia/Jayapura', '+09:00', 'WIT'),
    _fromId('Asia/Tokyo', '+09:00', 'JST'),
    _fromId('Europe/London', '+00:00', 'GMT'),
    _fromId('America/New_York', '-05:00', 'EST'),
  ];

  static void replaceAll(List<String> ids) {
    final rows = ids.map((id) => _fromId(id)).toList()
      ..sort((a, b) => a['id']!.compareTo(b['id']!));
    if (rows.isNotEmpty) timezones = rows;
  }

  static void upsertDetails({
    required String id,
    required String offset,
    String? abbreviation,
  }) {
    final index = timezones.indexWhere((timezone) => timezone['id'] == id);
    final row = _fromId(id, offset, abbreviation);
    if (index == -1) {
      timezones.add(row);
      timezones.sort((a, b) => a['id']!.compareTo(b['id']!));
    } else {
      timezones[index] = {...timezones[index], ...row};
    }
  }

  static Map<String, String>? getById(String id) {
    try {
      return timezones.firstWhere((t) => t['id'] == id);
    } catch (_) {
      return null;
    }
  }

  static Map<String, String> _fromId(
    String id, [
    String offset = '',
    String? abbreviation,
  ]) {
    final parts = id.split('/');
    final city = parts.isEmpty ? id : parts.last.replaceAll('_', ' ');
    final country = parts.length > 1 ? parts.first.replaceAll('_', ' ') : '';
    return {
      'id': id,
      'name': abbreviation ?? _shortName(id),
      'city': city,
      'country': country,
      'offset': offset,
    };
  }

  static String _shortName(String id) {
    final city = id.split('/').last.replaceAll('_', ' ');
    final words = city.split(' ').where((word) => word.isNotEmpty);
    final initials = words.map((word) => word[0].toUpperCase()).join();
    return initials.isEmpty ? id : initials;
  }
}
