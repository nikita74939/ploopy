import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/currency_data.dart';

class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.dev/v2';

  static Future<List<Map<String, String>>> getCurrencies() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/currencies'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return CurrencyData.currencies;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final currencies = data.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      CurrencyData.replaceAll(currencies);
      return CurrencyData.currencies;
    } catch (_) {
      return CurrencyData.currencies;
    }
  }

  /// Ambil exchange rate dengan base currency tertentu
  static Future<Map<String, dynamic>> getRates(String baseCurrency) async {
    try {
      await getCurrencies();
      final response = await http
          .get(Uri.parse('$_baseUrl/rates?base=$baseCurrency'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rows = data is List ? data : <dynamic>[];
        final rates = <String, double>{baseCurrency: 1};
        String? lastUpdate;

        for (final row in rows) {
          if (row is! Map<String, dynamic>) continue;
          final quote = row['quote']?.toString();
          final rate = (row['rate'] as num?)?.toDouble();
          if (quote == null || rate == null) continue;
          rates[quote] = rate;
          lastUpdate ??= row['date']?.toString();
        }

        return {
          'success': true,
          'base': baseCurrency,
          'rates': rates,
          'lastUpdate': lastUpdate,
        };
      }
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    }
  }

  /// Konversi dari satu currency ke currency lain
  static double convert({required double amount, required double rate}) {
    return amount * rate;
  }
}
