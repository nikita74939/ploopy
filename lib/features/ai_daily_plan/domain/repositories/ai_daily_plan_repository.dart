import '../../data/models/ai_daily_plan_model.dart';

abstract class AiDailyPlanRepository {
  Future<AiDailyPlanResponseModel> generatePlan({
    required String userId,
    required DateTime date,
  });

  Future<AiDailyPlanResponseModel> revisePlan({
    required String userId,
    required DateTime date,
    required AiDailyPlanResponseModel previousPlan,
    required String instruction,
  });

  Future<void> acceptPlan({
    required String userId,
    required AiDailyPlanResponseModel plan,
  });
}
