import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_local_data_source.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleLocalDataSource localDataSource;

  ScheduleRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ScheduleEntity>> getSchedulesByDate(DateTime date) async {
    final models = await localDataSource.getSchedulesByDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    final models = await localDataSource.getAllSchedules();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ScheduleEntity?> getScheduleById(int id) async {
    final model = await localDataSource.getScheduleById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addSchedule(ScheduleEntity schedule) async {
    final model = ScheduleModel.fromEntity(schedule);
    await localDataSource.addSchedule(model);
  }

  @override
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    final model = ScheduleModel.fromEntity(schedule);
    await localDataSource.updateSchedule(model);
  }

  @override
  Future<void> deleteSchedule(int id) async {
    await localDataSource.deleteSchedule(id);
  }

  @override
  Future<List<ScheduleEntity>> getUpcomingSchedules(String userId) async {
    final models = await localDataSource.getUpcomingSchedules(userId);
    return models.map((m) => m.toEntity()).toList();
  }
}