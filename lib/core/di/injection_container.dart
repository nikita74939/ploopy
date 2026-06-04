// Manual Dependency Injection untuk seluruh fitur aplikasi.
//
// Pola yang digunakan: static getter (factory) — setiap getter membuat
// instance baru. Jika suatu dependency perlu singleton (misal: Dio),
// simpan dalam field static private seperti _dio di bawah.
//
// Urutan inisialisasi (dilakukan di main.dart):
//   1. setIsar(isar)  ← harus dipanggil sebelum getter apapun diakses

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/api_config.dart';

// Auth
import '../../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';

// Home
import '../../../features/home/data/repositories/home_repository_impl.dart';
import '../../../features/home/domain/repositories/home_repository.dart';
import '../../../features/home/presentation/bloc/home_bloc.dart';

// Schedule
import '../../../features/schedule/data/datasources/schedule_local_data_source.dart';
import '../../../features/schedule/data/datasources/schedule_remote_data_source.dart';
import '../../../features/schedule/data/repositories/schedule_repository_impl.dart';
import '../../../features/schedule/domain/repositories/schedule_repository.dart';
import '../../../features/schedule/presentation/bloc/schedule_bloc.dart';

// Task
import '../../../features/task/data/datasources/task_local_data_source.dart';
import '../../../features/task/data/datasources/task_remote_data_source.dart';
import '../../../features/task/data/repositories/task_repository_impl.dart';
import '../../../features/task/domain/repositories/task_repository.dart';
import '../../../features/task/presentation/bloc/task_bloc.dart';

// Study
import '../../../features/study/data/datasources/study_local_data_source.dart';
import '../../../features/study/data/datasources/study_remote_data_source.dart';
import '../../../features/study/data/repositories/study_repository_impl.dart';
import '../../../features/study/domain/repositories/study_repository.dart';
import '../../../features/study/presentation/bloc/study_bloc.dart';

// Notification
import '../../../features/notification/data/datasources/notification_local_data_source.dart';
import '../../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../../features/notification/domain/repositories/notification_repository.dart';
import '../../../features/notification/presentation/bloc/notification_bloc.dart';

// Activity (remote-only: Supabase)
import '../../../features/activity/data/datasources/activity_remote_data_source.dart';
import '../../../features/activity/data/repositories/activity_repository_impl.dart';
import '../../../features/activity/domain/repositories/activity_repository.dart';
import '../../../features/activity/presentation/bloc/activity_bloc.dart';

// Event (remote-only: Supabase)
import '../../../features/event/data/datasources/event_remote_data_source.dart';
import '../../../features/event/data/repositories/event_repository_impl.dart';
import '../../../features/event/domain/repositories/event_repository.dart';
import '../../../features/event/presentation/bloc/event_bloc.dart';

// Profile (remote: Supabase + local: Isar)
import '../../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../../features/profile/domain/repositories/profile_repository.dart';
import '../../../features/profile/presentation/bloc/profile_bloc.dart';

class DependencyInjection {
  // Konstruktor privat — kelas ini tidak boleh diinstansiasi
  DependencyInjection._();

  // ─── Singleton shared dependencies ────────────────────────────────────────

  /// Penyimpanan token/kunci secara enkripsi di perangkat
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Plugin autentikasi biometrik (sidik jari / Face ID)
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// HTTP client ringan untuk request sederhana
  static final http.Client _httpClient = http.Client();

  /// Dio HTTP client dengan timeout 30 detik (singleton)
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  /// Isar diset dari main.dart setelah database dibuka
  static Isar? _isar;

  // ─── Public accessors untuk shared dependencies ────────────────────────────

  static http.Client get httpClient => _httpClient;
  static Dio get dio => _dio;

  /// Klien Supabase yang sudah diinisialisasi di main.dart
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Dipanggil sekali dari main.dart setelah IsarService.getInstance()
  static void setIsar(Isar isar) => _isar = isar;

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH
  // Mengelola login, register, logout, biometrik, dan sesi token
  // ═══════════════════════════════════════════════════════════════════════════

  static AuthLocalDataSource get authLocalDataSource => AuthLocalDataSourceImpl(
    isar: _isar!,
    secureStorage: _secureStorage,
    localAuth: _localAuth,
  );

  static AuthRemoteDataSource get authRemoteDataSource =>
      AuthRemoteDataSourceImpl(client: _httpClient, baseUrl: ApiConfig.baseUrl);

  static AuthRepository get authRepository => AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    secureStorage: _secureStorage,
    localAuth: _localAuth,
    isar: _isar!,
  );

  static AuthBloc get authBloc => AuthBloc(repository: authRepository);

  // ═══════════════════════════════════════════════════════════════════════════
  // HOME
  // Agregasi data dari Schedule, Task, dan Study untuk dashboard utama
  // ═══════════════════════════════════════════════════════════════════════════

  static HomeRepository get homeRepository => HomeRepositoryImpl(
    scheduleRepository: scheduleRepository,
    taskRepository: taskRepository,
    studyRepository: studyRepository,
  );

  static HomeBloc get homeBloc => HomeBloc(repository: homeRepository);

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULE
  // Jadwal harian/mingguan — disimpan lokal di Isar
  // ═══════════════════════════════════════════════════════════════════════════

  static ScheduleRemoteDataSource get scheduleRemoteDataSource =>
      ScheduleRemoteDataSourceImpl(
        client: _httpClient,
        baseUrl: ApiConfig.baseUrl,
        secureStorage: _secureStorage,
      );

  static ScheduleLocalDataSource get scheduleLocalDataSource =>
      ScheduleLocalDataSourceImpl(isar: _isar!);

  static ScheduleRepository get scheduleRepository => ScheduleRepositoryImpl(
    localDataSource: scheduleLocalDataSource,
    remoteDataSource: scheduleRemoteDataSource,
  );

  static ScheduleBloc get scheduleBloc =>
      ScheduleBloc(repository: scheduleRepository);

  // ═══════════════════════════════════════════════════════════════════════════
  // TASK
  // Tugas/to-do — disimpan lokal di Isar
  // ═══════════════════════════════════════════════════════════════════════════

  static TaskRemoteDataSource get taskRemoteDataSource =>
      TaskRemoteDataSourceImpl(
        client: _httpClient,
        baseUrl: ApiConfig.baseUrl,
        secureStorage: _secureStorage,
      );

  static TaskLocalDataSource get taskLocalDataSource =>
      TaskLocalDataSourceImpl(isar: _isar!);

  static TaskRepository get taskRepository => TaskRepositoryImpl(
    localDataSource: taskLocalDataSource,
    remoteDataSource: taskRemoteDataSource,
  );

  static TaskBloc get taskBloc => TaskBloc(repository: taskRepository);

  // ═══════════════════════════════════════════════════════════════════════════
  // STUDY
  // Sesi belajar & timer pomodoro — disimpan lokal di Isar
  // ═══════════════════════════════════════════════════════════════════════════

  static StudyLocalDataSource get studyLocalDataSource =>
      StudyLocalDataSourceImpl(isar: _isar!);

  static StudyRemoteDataSource get studyRemoteDataSource =>
      StudyRemoteDataSourceImpl(
        client: _httpClient,
        baseUrl: ApiConfig.baseUrl,
        secureStorage: _secureStorage,
      );

  static StudyRepository get studyRepository => StudyRepositoryImpl(
    localDataSource: studyLocalDataSource,
    remoteDataSource: studyRemoteDataSource,
  );

  static StudyBloc get studyBloc => StudyBloc(repository: studyRepository);

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION
  // Notifikasi lokal terjadwal — disimpan lokal di Isar
  // ═══════════════════════════════════════════════════════════════════════════

  static NotificationLocalDataSource get notificationLocalDataSource =>
      NotificationLocalDataSourceImpl(isar: _isar!);

  static NotificationRepository get notificationRepository =>
      NotificationRepositoryImpl(localDataSource: notificationLocalDataSource);

  static NotificationBloc get notificationBloc =>
      NotificationBloc(repository: notificationRepository);

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVITY
  // Feed aktivitas pengguna — remote-only via Supabase
  // ═══════════════════════════════════════════════════════════════════════════

  static ActivityRemoteDataSource get activityRemoteDataSource =>
      ActivityRemoteDataSourceImpl(supabase: _supabase);

  static ActivityRepository get activityRepository =>
      ActivityRepositoryImpl(remoteDataSource: activityRemoteDataSource);

  static ActivityBloc get activityBloc =>
      ActivityBloc(repository: activityRepository);

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT
  // Acara/kegiatan kampus — remote-only via Supabase
  // ═══════════════════════════════════════════════════════════════════════════

  static EventRemoteDataSource get eventRemoteDataSource =>
      EventRemoteDataSourceImpl(supabase: _supabase);

  static EventRepository get eventRepository =>
      EventRepositoryImpl(remoteDataSource: eventRemoteDataSource);

  static EventBloc get eventBloc => EventBloc(repository: eventRepository);

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // Data profil pengguna — sumber utama Supabase, cache lokal di Isar
  // ═══════════════════════════════════════════════════════════════════════════

  static ProfileRemoteDataSource get profileRemoteDataSource =>
      ProfileRemoteDataSourceImpl(
        supabase: _supabase,
        client: _httpClient,
        baseUrl: ApiConfig.baseUrl,
        secureStorage: _secureStorage,
      );

  static ProfileLocalDataSource get profileLocalDataSource =>
      ProfileLocalDataSourceImpl(isar: _isar!);

  static ProfileRepository get profileRepository => ProfileRepositoryImpl(
    remoteDataSource: profileRemoteDataSource,
    localDataSource: profileLocalDataSource,
  );

  static ProfileBloc get profileBloc =>
      ProfileBloc(repository: profileRepository);
}
