import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/constants/app_constants.dart' hide AppColors;
import 'core/constants/app_routes.dart';
import 'core/di/injection_container.dart';
import 'core/services/navigation_service.dart';
import 'core/theme/app_colors.dart';
import 'features/ai/presentation/pages/ai_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/pages/main_page.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';
import 'features/schedule/presentation/pages/schedule_page.dart';
import 'features/task/presentation/bloc/task_bloc.dart';
import 'features/study/presentation/bloc/study_bloc.dart';
import 'features/study/presentation/pages/study_page.dart';
import 'features/calendar/presentation/pages/calendar_page.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/notification/presentation/pages/notification_page.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/chat/presentation/pages/chat_list_page.dart';
import 'features/chat/presentation/pages/chat_room_page.dart';
import 'features/activity/presentation/bloc/activity_bloc.dart';
import 'features/activity/presentation/pages/activity_page.dart';
import 'features/event/presentation/bloc/event_bloc.dart';
import 'features/event/presentation/pages/event_page.dart';
import 'features/social/presentation/pages/social_page.dart';
import 'features/task/presentation/pages/add_task_page.dart';
import 'features/task/presentation/pages/task_page.dart';
import 'features/tools/presentation/pages/tools_page.dart';
import 'features/tools/presentation/pages/currency_converter_page.dart';
import 'features/tools/presentation/pages/timezone_converter_page.dart';
import 'features/tools/presentation/pages/unit_converter_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';

class PloopyApp extends StatelessWidget {
  const PloopyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize timezone
    tz.initializeTimeZones();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => DependencyInjection.authBloc),
        BlocProvider<HomeBloc>(create: (_) => DependencyInjection.homeBloc),
        BlocProvider<ScheduleBloc>(
          create: (_) => DependencyInjection.scheduleBloc,
        ),
        BlocProvider<TaskBloc>(create: (_) => DependencyInjection.taskBloc),
        BlocProvider<StudyBloc>(create: (_) => DependencyInjection.studyBloc),
        BlocProvider<NotificationBloc>(
          create: (_) => DependencyInjection.notificationBloc,
        ),
        BlocProvider<ChatBloc>(create: (_) => DependencyInjection.chatBloc),
        BlocProvider<ActivityBloc>(
          create: (_) => DependencyInjection.activityBloc,
        ),
        BlocProvider<EventBloc>(create: (_) => DependencyInjection.eventBloc),
        BlocProvider<ProfileBloc>(
          create: (_) => DependencyInjection.profileBloc,
        ),
      ],
      child: MaterialApp(
        title: 'Ploopy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.white,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: AppColors.black),
            titleTextStyle: TextStyle(
              color: AppColors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyle.borderRadius),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyle.borderRadius),
              borderSide: BorderSide(color: AppColors.greyBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyle.borderRadius),
              borderSide: BorderSide(color: AppColors.greyBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyle.borderRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyle.borderRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          cardTheme: CardThemeData(
            color: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyle.borderRadius),
              side: BorderSide(color: AppColors.greyBorder),
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.white,
            contentTextStyle: const TextStyle(color: AppColors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      // Auth
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      // Main
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // Schedule
      case AppRoutes.schedule:
        return MaterialPageRoute(builder: (_) => const SchedulePage());
      // case AppRoutes.addSchedule:
      //   return MaterialPageRoute(builder: (_) => const AddSchedulePage(existingSchedule: null,));
      // case AppRoutes.editSchedule:
      //   final schedule = settings.arguments;
      //   return MaterialPageRoute(
      //     builder: (_) => AddSchedulePage(schedule: schedule),
      //   );

      // Task
      case AppRoutes.task:
        return MaterialPageRoute(builder: (_) => const TaskPage());
      case AppRoutes.addTask:
        return MaterialPageRoute(builder: (_) => const AddTaskPage());
      // case AppRoutes.editTask:
      //   final task = settings.arguments;
      //   return MaterialPageRoute(
      //     builder: (_) => AddTaskPage(task: task),
      //   );

      // Study
      case AppRoutes.study:
        return MaterialPageRoute(builder: (_) => const StudyPage());

      // Calendar
      case AppRoutes.calendar:
        return MaterialPageRoute(builder: (_) => const CalendarPage());

      // Notification
      case AppRoutes.notification:
        return MaterialPageRoute(builder: (_) => const NotificationPage());

      // Chat
      case AppRoutes.chatList:
        return MaterialPageRoute(
          builder:
              (_) => ChatListPage(
                currentUserId: Supabase.instance.client.auth.currentUser!.id,
              ),
        );
      case AppRoutes.chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => ChatRoomPage(
                userId: args['userId'].toString(),
                otherUserId: args['otherUserId'].toString(),
                otherUserName: args['otherUserName']?.toString() ?? 'User',
              ),
        );

      // Activity
      case AppRoutes.activity:
        return MaterialPageRoute(builder: (_) => const ActivityPage());

      // Event
      case AppRoutes.event:
        return MaterialPageRoute(builder: (_) => const EventPage());

      // AI
      case AppRoutes.aiChat:
        return MaterialPageRoute(builder: (_) => const AiPage());

      // Social
      case AppRoutes.social:
        return MaterialPageRoute(builder: (_) => const SocialPage());

      // Tools
      case AppRoutes.tools:
        return MaterialPageRoute(builder: (_) => const ToolsPage());
      case AppRoutes.currencyConverter:
        return MaterialPageRoute(builder: (_) => const CurrencyConverterPage());
      case AppRoutes.timezoneConverter:
        return MaterialPageRoute(builder: (_) => const TimezoneConverterPage());
      case AppRoutes.unitConverter:
        return MaterialPageRoute(builder: (_) => const UnitConverterPage());

      // Profile
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      // Settings
      case AppRoutes.settingsprofile:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
