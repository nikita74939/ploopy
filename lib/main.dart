import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ploopy/shared/services/local_db_service.dart';
import 'app.dart';
import 'shared/services/notification_service.dart'; // ⭐ ADD

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.initialize();
  await LocalDbService.instance;
  await LocalDbService.seedAchievements();
  runApp(const PloopyApp());
}
