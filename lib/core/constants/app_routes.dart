// Pusat definisi nama route dan logika navigasi aplikasi.
// Tambahkan route baru di sini — jangan buat navigasi ad-hoc di widget.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/ai/presentation/pages/ai_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/home/presentation/pages/main_page.dart';
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/task/presentation/pages/task_page.dart';
import '../../features/study/presentation/pages/study_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/event/presentation/pages/event_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/social/presentation/pages/social_page.dart';
import '../../features/tools/presentation/pages/tools_page.dart';
import '../../features/tools/presentation/pages/currency_converter_page.dart';
import '../../features/tools/presentation/pages/timezone_converter_page.dart';
import '../../features/tools/presentation/pages/unit_converter_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRoutes {
  // Konstruktor privat — kelas ini hanya berisi konstanta & factory method
  AppRoutes._();

  // ─── Nama-nama route ──────────────────────────────────────────────────────

  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';

  static const String schedule = '/schedule';
  static const String task = '/task';

  static const String study = '/study';
  static const String calendar = '/calendar';
  static const String notification = '/notification';

  static const String activity = '/activity';
  static const String activityDetail = '/activity-detail'; // args: Activity

  static const String event = '/event';
  static const String eventDetail = '/event-detail'; // args: Event

  // chatRoom membutuhkan args: {userId, otherUserId, otherUserName}
  static const String chatList = '/chat-list';
  static const String chatRoom = '/chat-room';

  static const String social = '/social';
  static const String aiChat = '/ai-chat';

  static const String tools = '/tools';
  static const String scanner = '/scanner'; // TODO: belum diimplementasi
  static const String ocr = '/ocr'; // TODO: belum diimplementasi
  static const String currencyConverter = '/currency-converter';
  static const String timezoneConverter = '/timezone-converter';
  static const String unitConverter = '/unit-converter';
  static const String memoryGame = '/memory-game'; // TODO: belum diimplementasi

  static const String profile = '/profile';
  static const String editProfile =
      '/edit-profile'; // TODO: belum diimplementasi
  static const String achievement =
      '/achievement'; // TODO: belum diimplementasi
  static const String settingsprofile = '/settings';
  static const String security = '/security'; // TODO: belum diimplementasi

  // ─── Factory route ────────────────────────────────────────────────────────

  /// Dipanggil oleh [MaterialApp.onGenerateRoute].
  /// Semua navigasi harus melalui [Navigator.pushNamed] dengan nama di atas.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Splash & Auth ──────────────────────────────────────────────────────
      case splash:
        return _route(const SplashPage());
      case auth:
        return _route(const AuthPage());

      // ── Home ───────────────────────────────────────────────────────────────
      case home:
        return _route(const HomeScreen());

      // ── Schedule ───────────────────────────────────────────────────────────
      case schedule:
        return _route(const SchedulePage());

      // ── Task ───────────────────────────────────────────────────────────────
      case task:
        return _route(const TaskPage());

      // ── Study ──────────────────────────────────────────────────────────────
      case study:
        return _route(const StudyPage());

      // ── Calendar ───────────────────────────────────────────────────────────
      case calendar:
        return _route(const CalendarPage());

      // ── Notification ───────────────────────────────────────────────────────
      case notification:
        return _route(const NotificationPage());

      // ── Chat ───────────────────────────────────────────────────────────────
      // currentUserId diambil dari sesi Supabase yang sedang aktif
      case chatList:
        return _route(
          ChatListPage(
            currentUserId: Supabase.instance.client.auth.currentUser!.id,
          ),
        );
      // args wajib: {userId, otherUserId, otherUserName}
      case chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return _route(
          ChatRoomPage(
            userId: args['userId'].toString(),
            otherUserId: args['otherUserId'].toString(),
            otherUserName: args['otherUserName']?.toString() ?? 'User',
          ),
        );

      // ── Activity & Event ───────────────────────────────────────────────────
      case activity:
        return _route(const ActivityPage());
      case event:
        return _route(const EventPage());

      // ── AI ─────────────────────────────────────────────────────────────────
      case aiChat:
        return _route(const AiPage());

      // ── Social ─────────────────────────────────────────────────────────────
      case social:
        return _route(const SocialPage());

      // ── Tools ──────────────────────────────────────────────────────────────
      case tools:
        return _route(const ToolsPage());
      case currencyConverter:
        return _route(const CurrencyConverterPage());
      case timezoneConverter:
        return _route(const TimezoneConverterPage());
      case unitConverter:
        return _route(const UnitConverterPage());

      // ── Profile & Settings ─────────────────────────────────────────────────
      case profile:
        return _route(const ProfilePage());
      // case editProfile:
      //   return _route(const EditProfilePage());
      // case achievement:
      //   return _route(const AchievementPage());
      case settingsprofile:
        return _route(const SettingsPage());
      // case security:
      //   return _route(const SecurityPage());

      // Fallback jika route tidak dikenal → kembali ke auth
      default:
        return _route(const AuthPage());
    }
  }

  /// Helper agar penulisan MaterialPageRoute tidak berulang-ulang
  static MaterialPageRoute<dynamic> _route(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
