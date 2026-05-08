import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
import '../../../features/schedule/data/repositories/schedule_repository_impl.dart';
import '../../../features/schedule/domain/repositories/schedule_repository.dart';
import '../../../features/schedule/presentation/bloc/schedule_bloc.dart';

// Task
import '../../../features/task/data/datasources/task_local_data_source.dart';
import '../../../features/task/data/repositories/task_repository_impl.dart';
import '../../../features/task/domain/repositories/task_repository.dart';
import '../../../features/task/presentation/bloc/task_bloc.dart';

// Study
import '../../../features/study/data/datasources/study_local_data_source.dart';
import '../../../features/study/data/repositories/study_repository_impl.dart';
import '../../../features/study/domain/repositories/study_repository.dart';
import '../../../features/study/presentation/bloc/study_bloc.dart';

// Notification
import '../../../features/notification/data/datasources/notification_local_data_source.dart';
import '../../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../../features/notification/domain/repositories/notification_repository.dart';
import '../../../features/notification/presentation/bloc/notification_bloc.dart';

// Chat
import '../../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../../features/chat/domain/repositories/chat_repository.dart';
import '../../../features/chat/presentation/bloc/chat_bloc.dart';

// Activity
import '../../../features/activity/data/datasources/activity_remote_data_source.dart';
import '../../../features/activity/data/repositories/activity_repository_impl.dart';
import '../../../features/activity/domain/repositories/activity_repository.dart';
import '../../../features/activity/presentation/bloc/activity_bloc.dart';

// Event
import '../../../features/event/data/datasources/event_remote_data_source.dart';
import '../../../features/event/data/repositories/event_repository_impl.dart';
import '../../../features/event/domain/repositories/event_repository.dart';
import '../../../features/event/presentation/bloc/event_bloc.dart';

// Profile
import '../../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../../features/profile/domain/repositories/profile_repository.dart';
import '../../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';

class DependencyInjection {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final Dio _dio = Dio();
  static final http.Client _httpClient = http.Client();
  
  // HTTP Client
  static http.Client get httpClient => _httpClient;

  // Dio - Singleton
  static Dio get dio {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );
    return _dio;
  }

  static Isar? _isar;

  static void setIsar(Isar isar) {
    _isar = isar;
  }

  static SupabaseClient get _supabase => Supabase.instance.client;

  // ─────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────

  static AuthLocalDataSource get authLocalDataSource => AuthLocalDataSourceImpl(
    isar: _isar!,
    secureStorage: _secureStorage,
    localAuth: _localAuth,
  );

  static AuthRemoteDataSource get authRemoteDataSource =>
      AuthRemoteDataSourceImpl(supabase: _supabase);

  static AuthRepository get authRepository => AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    secureStorage: _secureStorage,
    localAuth: _localAuth,
    isar: _isar!,
    supabase: _supabase,
  );

  static AuthBloc get authBloc => AuthBloc(repository: authRepository);

  // ─────────────────────────────────────────
  // Home
  // ─────────────────────────────────────────

  static HomeRepository get homeRepository => HomeRepositoryImpl(
    scheduleRepository: scheduleRepository,
    taskRepository: taskRepository,
    studyRepository: studyRepository,
  );

  static HomeBloc get homeBloc => HomeBloc(repository: homeRepository);

  // ─────────────────────────────────────────
  // Schedule
  // ─────────────────────────────────────────

  static ScheduleLocalDataSource get scheduleLocalDataSource =>
      ScheduleLocalDataSourceImpl(isar: _isar!);

  static ScheduleRepository get scheduleRepository =>
      ScheduleRepositoryImpl(localDataSource: scheduleLocalDataSource);

  static ScheduleBloc get scheduleBloc =>
      ScheduleBloc(repository: scheduleRepository);

  // ─────────────────────────────────────────
  // Task
  // ─────────────────────────────────────────

  static TaskLocalDataSource get taskLocalDataSource =>
      TaskLocalDataSourceImpl(isar: _isar!);

  static TaskRepository get taskRepository =>
      TaskRepositoryImpl(localDataSource: taskLocalDataSource);

  static TaskBloc get taskBloc => TaskBloc(repository: taskRepository);

  // ─────────────────────────────────────────
  // Study
  // ─────────────────────────────────────────

  static StudyLocalDataSource get studyLocalDataSource =>
      StudyLocalDataSourceImpl(isar: _isar!);

  static StudyRepository get studyRepository =>
      StudyRepositoryImpl(localDataSource: studyLocalDataSource);

  static StudyBloc get studyBloc => StudyBloc(repository: studyRepository);

  // ─────────────────────────────────────────
  // Notification
  // ─────────────────────────────────────────

  static NotificationLocalDataSource get notificationLocalDataSource =>
      NotificationLocalDataSourceImpl(isar: _isar!);

  static NotificationRepository get notificationRepository =>
      NotificationRepositoryImpl(localDataSource: notificationLocalDataSource);

  static NotificationBloc get notificationBloc =>
      NotificationBloc(repository: notificationRepository);

  // ─────────────────────────────────────────
  // Chat
  // ─────────────────────────────────────────

  static ChatRemoteDataSource get chatRemoteDataSource =>
      ChatRemoteDataSourceImpl(supabase: _supabase);

  static ChatRepository get chatRepository =>
      ChatRepositoryImpl(remoteDataSource: chatRemoteDataSource);

  static ChatBloc get chatBloc => ChatBloc(repository: chatRepository);

  // ─────────────────────────────────────────
  // Activity  ← Supabase (remote only)
  // ─────────────────────────────────────────

  static ActivityRemoteDataSource get activityRemoteDataSource =>
      ActivityRemoteDataSourceImpl(supabase: _supabase);

  static ActivityRepository get activityRepository =>
      ActivityRepositoryImpl(remoteDataSource: activityRemoteDataSource);

  static ActivityBloc get activityBloc =>
      ActivityBloc(repository: activityRepository);

  // ─────────────────────────────────────────
  // Event  ← Supabase (remote only)
  // ─────────────────────────────────────────

  static EventRemoteDataSource get eventRemoteDataSource =>
      EventRemoteDataSourceImpl(supabase: _supabase);

  static EventRepository get eventRepository =>
      EventRepositoryImpl(remoteDataSource: eventRemoteDataSource);

  static EventBloc get eventBloc => EventBloc(repository: eventRepository);


  // ─────────────────────────────────────────
  // Profile
  // ─────────────────────────────────────────

  static ProfileRemoteDataSource get profileRemoteDataSource =>
      ProfileRemoteDataSourceImpl(supabase: _supabase);

  static ProfileLocalDataSource get profileLocalDataSource =>
      ProfileLocalDataSourceImpl(isar: _isar!);

  static ProfileRepository get profileRepository => ProfileRepositoryImpl(
    remoteDataSource: profileRemoteDataSource,
    localDataSource: profileLocalDataSource,
  );

  static ProfileBloc get profileBloc =>
      ProfileBloc(repository: profileRepository);
}
