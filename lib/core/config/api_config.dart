import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    final configured = dotenv.env['API_BASE_URL']?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/$'), '');
    }

    return 'http://10.0.2.2:3000';
  }
}
