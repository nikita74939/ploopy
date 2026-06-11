class CurrencyData {
  static List<Map<String, String>> currencies = [
    {'code': 'IDR', 'name': 'Indonesian Rupiah', 'symbol': 'Rp'},
    {'code': 'USD', 'name': 'US Dollar', 'symbol': r'$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': 'EUR'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': 'GBP'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': 'JPY'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$'},
  ];

  static void replaceAll(Map<String, String> apiCurrencies) {
    final rows =
        apiCurrencies.entries
            .map(
              (entry) => {
                'code': entry.key.toUpperCase(),
                'name': entry.value,
                'symbol': _symbolFor(entry.key.toUpperCase()),
              },
            )
            .toList()
          ..sort((a, b) => a['code']!.compareTo(b['code']!));

    if (rows.isNotEmpty) currencies = rows;
  }

  static Map<String, String>? getByCode(String code) {
    try {
      return currencies.firstWhere((c) => c['code'] == code);
    } catch (_) {
      return null;
    }
  }

  static String _symbolFor(String code) {
    switch (code) {
      case 'IDR':
        return 'Rp';
      case 'USD':
        return r'$';
      case 'SGD':
        return 'S\$';
      default:
        return code;
    }
  }
}
