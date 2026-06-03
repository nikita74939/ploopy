import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  ScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ScheduleEntity>> getSchedulesByDate(DateTime date) async {
    final models = await remoteDataSource.getSchedulesByDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    final models = await remoteDataSource.getAllSchedules();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ScheduleEntity?> getScheduleById(int id) async {
    final model = await remoteDataSource.getScheduleById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addSchedule(ScheduleEntity schedule) async {
    final model = ScheduleModel.fromEntity(schedule);
    await remoteDataSource.addSchedule(model);
  }

  @override
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    final model = ScheduleModel.fromEntity(schedule);
    await remoteDataSource.updateSchedule(model);
  }

  @override
  Future<void> deleteSchedule(int id) async {
    await remoteDataSource.deleteSchedule(id);
  }

  @override
  Future<List<ScheduleEntity>> getUpcomingSchedules(String userId) async {
    final models = await remoteDataSource.getUpcomingSchedules(userId);
    return models.map((m) => m.toEntity()).toList();
  }
}
