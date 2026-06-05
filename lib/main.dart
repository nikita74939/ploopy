// Entry point aplikasi Ploopy.
// Urutan inisialisasi: env -> orientasi -> Isar -> Notifikasi -> runApp.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/isar_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat variabel environment dari file .env (API_BASE_URL, dll.).
  await dotenv.load(fileName: '.env');

  // Inisialisasi data locale untuk DateFormat('...', 'id_ID').
  await initializeDateFormatting('id_ID');

  // Kunci orientasi hanya portrait agar layout konsisten di semua perangkat.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inisialisasi Isar (database lokal) lalu daftarkan ke DI.
  final isar = await IsarService.getInstance();
  DependencyInjection.setIsar(isar);

  // Inisialisasi layanan notifikasi lokal (permission + channel).
  await NotificationService.initialize();

  runApp(const PloopyApp());
}
