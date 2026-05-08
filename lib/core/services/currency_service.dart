import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Gratis & no API key needed!
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';

  /// Ambil exchange rate dengan base currency tertentu
  static Future<Map<String, dynamic>> getRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['result'] == 'success') {
          return {
            'success': true,
            'base': data['base_code'],
            'rates': data['rates'],
            'lastUpdate': data['time_last_update_utc'],
          };
        }
        return {'success': false, 'message': 'Gagal mengambil data'};
      }
      return {'success': false, 'message': 'Server error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    }
  }

  /// Konversi dari satu currency ke currency lain
  static double convert({
    required double amount,
    required double rate,
  }) {
    return amount * rate;
  }
}