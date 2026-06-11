import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/timezone_data.dart';

class TimezoneService {
  static const String _baseUrl = 'https://www.timeapi.io/api/TimeZone';
  static final Map<String, TimezoneDetails> _details = {};

  static Future<List<Map<String, String>>> getTimezones() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/AvailableTimeZones'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return TimezoneData.timezones;

      final data = json.decode(response.body);
      final ids = data is List
          ? data.map((value) => value.toString()).toList()
          : <String>[];
      TimezoneData.replaceAll(ids);
      return TimezoneData.timezones;
    } catch (_) {
      return TimezoneData.timezones;
    }
  }

  static Future<TimezoneDetails?> getDetails(String id) async {
    final cached = _details[id];
    if (cached != null) return cached;

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/zone?timeZone=${Uri.encodeComponent(id)}'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final seconds =
          ((data['currentUtcOffset'] as Map<String, dynamic>?)?['seconds']
                  as num?)
              ?.toInt() ??
          0;
      final details = TimezoneDetails(
        id: id,
        offsetSeconds: seconds,
        currentLocalTime: DateTime.tryParse(
          data['currentLocalTime']?.toString() ?? '',
        ),
        abbreviation: _abbrFromOffset(seconds),
      );
      _details[id] = details;
      TimezoneData.upsertDetails(
        id: id,
        offset: details.offsetLabel,
        abbreviation: details.abbreviation,
      );
      return details;
    } catch (_) {
      return null;
    }
  }

  static Future<void> warmUp(Iterable<String> ids) async {
    await getTimezones();
    await Future.wait(ids.map(getDetails));
  }

  static DateTime convertWithApiOffsets({
    required DateTime sourceTime,
    required String sourceId,
    required String targetId,
  }) {
    final sourceOffset = _details[sourceId]?.offsetSeconds ?? 0;
    final targetOffset = _details[targetId]?.offsetSeconds ?? 0;
    final utc = sourceTime.subtract(Duration(seconds: sourceOffset));
    return utc.add(Duration(seconds: targetOffset));
  }

  static int diffMinutes(String sourceId, String targetId) {
    final sourceOffset = _details[sourceId]?.offsetSeconds ?? 0;
    final targetOffset = _details[targetId]?.offsetSeconds ?? 0;
    return (targetOffset - sourceOffset) ~/ 60;
  }

  static String _abbrFromOffset(int seconds) {
    final sign = seconds >= 0 ? '+' : '-';
    final absSeconds = seconds.abs();
    final hours = (absSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((absSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }
}

class TimezoneDetails {
  final String id;
  final int offsetSeconds;
  final DateTime? currentLocalTime;
  final String abbreviation;

  const TimezoneDetails({
    required this.id,
    required this.offsetSeconds,
    required this.currentLocalTime,
    required this.abbreviation,
  });

  String get offsetLabel {
    final sign = offsetSeconds >= 0 ? '+' : '-';
    final absSeconds = offsetSeconds.abs();
    final hours = (absSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((absSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    return '$sign$hours:$minutes';
  }
}
