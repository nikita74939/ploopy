class CurrencyData {
  static const List<Map<String, String>> currencies = [
    {'code': 'IDR', 'name': 'Rupiah Indonesia', 'flag': '🇮🇩', 'symbol': 'Rp'},
    {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'flag': '🇯🇵', 'symbol': '¥'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'flag': '🇨🇳', 'symbol': '¥'},
    {'code': 'KRW', 'name': 'Korean Won', 'flag': '🇰🇷', 'symbol': '₩'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'flag': '🇸🇬', 'symbol': 'S\$'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'flag': '🇲🇾', 'symbol': 'RM'},
    {'code': 'THB', 'name': 'Thai Baht', 'flag': '🇹🇭', 'symbol': '฿'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'flag': '🇦🇺', 'symbol': 'A\$'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'flag': '🇨🇦', 'symbol': 'C\$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'flag': '🇨🇭', 'symbol': 'Fr'},
    {'code': 'HKD', 'name': 'Hong Kong Dollar', 'flag': '🇭🇰', 'symbol': 'HK\$'},
    {'code': 'INR', 'name': 'Indian Rupee', 'flag': '🇮🇳', 'symbol': '₹'},
    {'code': 'SAR', 'name': 'Saudi Riyal', 'flag': '🇸🇦', 'symbol': '﷼'},
    {'code': 'AED', 'name': 'UAE Dirham', 'flag': '🇦🇪', 'symbol': 'د.إ'},
    {'code': 'NZD', 'name': 'New Zealand Dollar', 'flag': '🇳🇿', 'symbol': 'NZ\$'},
    {'code': 'PHP', 'name': 'Philippine Peso', 'flag': '🇵🇭', 'symbol': '₱'},
    {'code': 'VND', 'name': 'Vietnamese Dong', 'flag': '🇻🇳', 'symbol': '₫'},
  ];

  static Map<String, String>? getByCode(String code) {
    try {
      return currencies.firstWhere((c) => c['code'] == code);
    } catch (e) {
      return null;
    }
  }
}