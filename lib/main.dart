// Entry point aplikasi Ploopy.
// Urutan inisialisasi: env → Supabase → orientasi → Isar → Notifikasi → runApp

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/isar_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat variabel environment dari file .env (SUPABASE_URL, SUPABASE_ANON_KEY, dll.)
  await dotenv.load(fileName: '.env');

  // Inisialisasi Supabase dengan kredensial dari .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Kunci orientasi hanya portrait agar layout konsisten di semua perangkat
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inisialisasi Isar (database lokal) lalu daftarkan ke DI
  final isar = await IsarService.getInstance();
  DependencyInjection.setIsar(isar);

  // Inisialisasi layanan notifikasi lokal (permission + channel)
  await NotificationService.initialize();

  runApp(const PloopyApp());
}