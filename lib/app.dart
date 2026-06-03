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

import 'core/constants/app_constants.dart' hide AppColors;
import 'core/constants/app_routes.dart';
import 'core/di/injection_container.dart';
import 'core/services/navigation_service.dart';
import 'core/theme/app_colors.dart';
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
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MultiBlocProvider(
      // Semua BLoC didaftarkan di level root agar bisa diakses di mana saja
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => DependencyInjection.authBloc,
        ),
        BlocProvider<HomeBloc>(
          create: (_) => DependencyInjection.homeBloc,
        ),
        BlocProvider<ScheduleBloc>(
          create: (_) => DependencyInjection.scheduleBloc,
        ),
        BlocProvider<TaskBloc>(
          create: (_) => DependencyInjection.taskBloc,
        ),
        BlocProvider<StudyBloc>(
          create: (_) => DependencyInjection.studyBloc,
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => DependencyInjection.notificationBloc,
        ),
        BlocProvider<ChatBloc>(
          create: (_) => DependencyInjection.chatBloc,
        ),
        BlocProvider<ActivityBloc>(
          create: (_) => DependencyInjection.activityBloc,
        ),
        BlocProvider<EventBloc>(
          create: (_) => DependencyInjection.eventBloc,
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => DependencyInjection.profileBloc,
        ),
      ],
      child: MaterialApp(
        title: 'Ploopy',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: AppRoutes.splash,
        // Semua definisi route dipusatkan di AppRoutes agar tidak tersebar
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }

  /// Konfigurasi tema global aplikasi (Material 3).
  /// Ubah di sini jika ingin mengganti warna, bentuk, atau tipografi secara global.
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.white,

      // AppBar: putih, tanpa elevasi, judul di tengah
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

      // ElevatedButton: warna primary, sudut membulat sesuai AppStyle
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

      // TextButton: warna primary
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      // Input field: fill putih, border abu, fokus primary
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

      // Card: putih, tanpa bayangan, hanya border tipis
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
          side: BorderSide(color: AppColors.greyBorder),
        ),
      ),

      // SnackBar: floating, sudut membulat
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.white,
        contentTextStyle: const TextStyle(color: AppColors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}