import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Login menggunakan biometrik (user sudah terdaftar sebelumnya)
class BiometricAuthRequested extends AuthEvent {}

/// Aktivasi biometrik pertama kali setelah login dengan email+password
class EnableBiometricRequested extends AuthEvent {}

class SetBiometricEnabledRequested extends AuthEvent {
  final bool enabled;

  SetBiometricEnabledRequested({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class LogoutRequested extends AuthEvent {}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthChecking extends AuthState {}

class AuthLogoutLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Biometrik berhasil diaktifkan (bukan login — hanya aktivasi)
class BiometricEnabled extends AuthState {
  final UserEntity user;
  BiometricEnabled({required this.user});

  @override
  List<Object?> get props => [user];
}

class BiometricPreferenceUpdated extends AuthState {
  final UserEntity user;

  BiometricPreferenceUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<BiometricAuthRequested>(_onBiometricAuthRequested);
    on<EnableBiometricRequested>(_onEnableBiometricRequested);
    on<SetBiometricEnabledRequested>(_onSetBiometricEnabledRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthChecking());
    try {
      final isLoggedIn = await repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await repository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(event.email, event.password);
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(AuthError(message: 'Email atau password salah.'));
      }
    } catch (e) {
      emit(AuthError(message: _cleanError(e)));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.register(
        event.email,
        event.password,
        event.name,
      );
      if (user == null) {
        emit(AuthError(message: 'Registrasi gagal. Coba lagi.'));
      } else {
        emit(Authenticated(user: user));
      }
    } catch (e) {
      emit(AuthError(message: _cleanError(e)));
    }
  }

  /// Login biometrik: verifikasi sidik jari → ambil user dari cache → Authenticated
  Future<void> _onBiometricAuthRequested(
    BiometricAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final authenticated = await repository.authenticateWithBiometrics();
      if (!authenticated) {
        emit(AuthError(message: 'Autentikasi biometrik gagal.'));
        return;
      }

      final user = await repository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        // Tidak ada user lokal — minta login ulang dengan email/password
        emit(
          AuthError(
            message:
                'Sesi habis. Silakan login dengan email & password terlebih dahulu.',
          ),
        );
      }
    } catch (e) {
      emit(AuthError(message: _cleanError(e)));
    }
  }

  /// Aktivasi biometrik: verifikasi sidik jari → aktifkan flag → BiometricEnabled
  Future<void> _onEnableBiometricRequested(
    EnableBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.enableBiometric();
      if (user != null) {
        emit(BiometricEnabled(user: user));
      } else {
        emit(AuthError(message: 'Gagal mengaktifkan biometrik.'));
      }
    } catch (e) {
      emit(AuthError(message: _cleanError(e)));
    }
  }

  Future<void> _onSetBiometricEnabledRequested(
    SetBiometricEnabledRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.setBiometricEnabled(event.enabled);
      if (user == null) {
        emit(
          AuthError(
            message: event.enabled
                ? 'Gagal mengaktifkan biometrik.'
                : 'Gagal menonaktifkan biometrik.',
          ),
        );
        return;
      }
      emit(BiometricPreferenceUpdated(user: user));
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _cleanError(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLogoutLoading());
    try {
      await repository.logout();
      emit(Unauthenticated());
    } catch (e) {
      // Logout lokal tetap berhasil — emit Unauthenticated
      emit(Unauthenticated());
    }
  }

  String _cleanError(Object e) {
    final msg = e.toString();
    // Buang prefix "Exception: " yang ditambahkan Dart
    final cleaned = msg.startsWith('Exception: ') ? msg.substring(11) : msg;
    if (cleaned.trim().isEmpty) return 'Terjadi kesalahan. Coba lagi.';
    return cleaned;
  }
}
