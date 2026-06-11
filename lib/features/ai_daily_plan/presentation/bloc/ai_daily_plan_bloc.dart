import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/ai_daily_plan_model.dart';
import '../../domain/repositories/ai_daily_plan_repository.dart';

abstract class AiDailyPlanEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GenerateAiDailyPlan extends AiDailyPlanEvent {
  final String userId;
  final DateTime date;

  GenerateAiDailyPlan({required this.userId, required this.date});

  @override
  List<Object?> get props => [userId, date];
}

class ReviseAiDailyPlan extends AiDailyPlanEvent {
  final String userId;
  final DateTime date;
  final String instruction;

  ReviseAiDailyPlan({
    required this.userId,
    required this.date,
    required this.instruction,
  });

  @override
  List<Object?> get props => [userId, date, instruction];
}

class AcceptAiDailyPlan extends AiDailyPlanEvent {
  final String userId;

  AcceptAiDailyPlan({required this.userId});

  @override
  List<Object?> get props => [userId];
}

abstract class AiDailyPlanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AiDailyPlanInitial extends AiDailyPlanState {}

class AiDailyPlanLoading extends AiDailyPlanState {
  final AiDailyPlanResponseModel? previousPlan;

  AiDailyPlanLoading({this.previousPlan});

  @override
  List<Object?> get props => [previousPlan];
}

class AiDailyPlanLoaded extends AiDailyPlanState {
  final DateTime date;
  final AiDailyPlanResponseModel plan;
  final bool saved;

  AiDailyPlanLoaded({
    required this.date,
    required this.plan,
    this.saved = false,
  });

  AiDailyPlanLoaded copyWith({bool? saved, AiDailyPlanResponseModel? plan}) {
    return AiDailyPlanLoaded(
      date: date,
      plan: plan ?? this.plan,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [date, plan, saved];
}

class AiDailyPlanError extends AiDailyPlanState {
  final String message;
  final AiDailyPlanResponseModel? previousPlan;

  AiDailyPlanError({required this.message, this.previousPlan});

  @override
  List<Object?> get props => [message, previousPlan];
}

class AiDailyPlanBloc extends Bloc<AiDailyPlanEvent, AiDailyPlanState> {
  final AiDailyPlanRepository repository;

  AiDailyPlanBloc({required this.repository}) : super(AiDailyPlanInitial()) {
    on<GenerateAiDailyPlan>(_onGenerate);
    on<ReviseAiDailyPlan>(_onRevise);
    on<AcceptAiDailyPlan>(_onAccept);
  }

  Future<void> _onGenerate(
    GenerateAiDailyPlan event,
    Emitter<AiDailyPlanState> emit,
  ) async {
    emit(AiDailyPlanLoading());
    try {
      final plan = await repository.generatePlan(
        userId: event.userId,
        date: event.date,
      );
      emit(AiDailyPlanLoaded(date: event.date, plan: plan));
    } catch (e) {
      emit(AiDailyPlanError(message: _cleanError(e)));
    }
  }

  Future<void> _onRevise(
    ReviseAiDailyPlan event,
    Emitter<AiDailyPlanState> emit,
  ) async {
    final current = state;
    if (current is! AiDailyPlanLoaded) {
      emit(
        AiDailyPlanError(
          message: 'Generate rencana terlebih dahulu sebelum revisi.',
        ),
      );
      return;
    }

    emit(AiDailyPlanLoading(previousPlan: current.plan));
    try {
      final plan = await repository.revisePlan(
        userId: event.userId,
        date: event.date,
        previousPlan: current.plan,
        instruction: event.instruction,
      );
      emit(AiDailyPlanLoaded(date: event.date, plan: plan));
    } catch (e) {
      emit(
        AiDailyPlanError(message: _cleanError(e), previousPlan: current.plan),
      );
    }
  }

  Future<void> _onAccept(
    AcceptAiDailyPlan event,
    Emitter<AiDailyPlanState> emit,
  ) async {
    final current = state;
    if (current is! AiDailyPlanLoaded) return;

    emit(AiDailyPlanLoading(previousPlan: current.plan));
    try {
      await repository.acceptPlan(userId: event.userId, plan: current.plan);
      emit(current.copyWith(saved: true));
    } catch (e) {
      emit(
        AiDailyPlanError(message: _cleanError(e), previousPlan: current.plan),
      );
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();
    final cleaned = message.startsWith('Exception: ')
        ? message.substring(11)
        : message;
    return cleaned.trim().isEmpty
        ? 'AI Daily Plan gagal diproses.'
        : cleaned.trim();
  }
}
