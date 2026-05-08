// lib/core/constants/app_routes.dart
import 'package:flutter/material.dart';
import '../../features/ai/presentation/pages/ai_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/main_page.dart';
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/schedule/presentation/pages/add_schedule_page.dart';
import '../../features/task/presentation/pages/task_page.dart';
import '../../features/task/presentation/pages/add_task_page.dart';
import '../../features/study/presentation/pages/study_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/event/presentation/pages/event_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/social/presentation/pages/social_page.dart';
import '../../features/tools/presentation/pages/tools_page.dart';
import '../../features/tools/presentation/pages/currency_converter_page.dart';
import '../../features/tools/presentation/pages/timezone_converter_page.dart';
import '../../features/tools/presentation/pages/unit_converter_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String schedule = '/schedule';
  static const String addSchedule = '/add-schedule';
  static const String editSchedule = '/edit-schedule';
  static const String task = '/task';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
  static const String study = '/study';
  static const String calendar = '/calendar';
  static const String notification = '/notification';
  static const String activity = '/activity';
  static const String activityDetail = '/activity-detail';
  static const String event = '/event';
  static const String eventDetail = '/event-detail';
  static const String chatList = '/chat-list';
  static const String chatRoom = '/chat-room';
  static const String social = '/social';
  static const String aiChat = '/ai-chat';
  static const String tools = '/tools';
  static const String scanner = '/scanner';
  static const String ocr = '/ocr';
  static const String currencyConverter = '/currency-converter';
  static const String timezoneConverter = '/timezone-converter';
  static const String unitConverter = '/unit-converter';
  static const String memoryGame = '/memory-game';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String achievement = '/achievement';
  static const String settingsprofile = '/settings';
  static const String security = '/security';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case schedule:
        return MaterialPageRoute(builder: (_) => const SchedulePage());
      case addSchedule:
        return MaterialPageRoute(builder: (_) => const AddSchedulePage());
      case task:
        return MaterialPageRoute(builder: (_) => const TaskPage());
      case addTask:
        return MaterialPageRoute(builder: (_) => const AddTaskPage());
      case study:
        return MaterialPageRoute(builder: (_) => const StudyPage());
      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarPage());
      case notification:
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case activity:
        return MaterialPageRoute(builder: (_) => const ActivityPage());
      case event:
        return MaterialPageRoute(builder: (_) => const EventPage());
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListPage(currentUserId: '1'));
      case social:
        return MaterialPageRoute(builder: (_) => const SocialPage());
      case aiChat:
        return MaterialPageRoute(builder: (_) => const AiPage());
      case tools:
        return MaterialPageRoute(builder: (_) => const ToolsPage());
      case currencyConverter:
        return MaterialPageRoute(builder: (_) => const CurrencyConverterPage());
      case timezoneConverter:
        return MaterialPageRoute(builder: (_) => const TimezoneConverterPage());
      case unitConverter:
        return MaterialPageRoute(builder: (_) => const UnitConverterPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      // case editProfile:
      //   return MaterialPageRoute(builder: (_) => const EditProfilePage());
      // case achievement:
      //   return MaterialPageRoute(builder: (_) => const AchievementPage());
      case settingsprofile:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      // case security:
      //   return MaterialPageRoute(builder: (_) => const SecurityPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}