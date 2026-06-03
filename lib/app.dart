// Root widget aplikasi Ploopy.
// Bertanggung jawab atas:
//   - Inisialisasi timezone & system UI
//   - Penyediaan semua BLoC global via MultiBlocProvider
//   - Konfigurasi tema Material 3
//   - Pendelegasian routing ke AppRoutes.generateRoute

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/constants/app_routes.dart';
import 'core/di/injection_container.dart';
import 'core/services/navigation_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';
import 'features/task/presentation/bloc/task_bloc.dart';
import 'features/study/presentation/bloc/study_bloc.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/activity/presentation/bloc/activity_bloc.dart';
import 'features/event/presentation/bloc/event_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

class PloopyApp extends StatelessWidget {
  const PloopyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi data timezone (diperlukan untuk fitur jadwal & kalender)
    tz.initializeTimeZones();

    // Atur tampilan status bar & navigation bar agar transparan/terang
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MultiBlocProvider(
      // Semua BLoC didaftarkan di level root agar bisa diakses di mana saja
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
        theme: AppTheme.lightTheme,
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: AppRoutes.splash,
        // Semua definisi route dipusatkan di AppRoutes agar tidak tersebar
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
