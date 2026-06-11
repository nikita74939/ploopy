import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../schedule/presentation/bloc/schedule_bloc.dart';
import '../../../schedule/presentation/widgets/schedule_form_sheet.dart';
import '../../../task/presentation/bloc/task_bloc.dart';
import '../../../task/presentation/widgets/task_form_sheet.dart';

class ScheduleTaskAddSheet extends StatelessWidget {
  final String userId;
  final DateTime? initialDate;

  const ScheduleTaskAddSheet({
    super.key,
    required this.userId,
    this.initialDate,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyHandle,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 42,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.tabActive.copyWith(
                  color: AppColors.white,
                ),
                unselectedLabelStyle: AppTextStyles.tabInactive,
                dividerColor: AppColors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Schedule'),
                  Tab(text: 'Task'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BlocProvider.value(
                    value: context.read<ScheduleBloc>(),
                    child: ScheduleFormSheet(
                      userId: userId,
                      initialDate: initialDate,
                    ),
                  ),
                  BlocProvider.value(
                    value: context.read<TaskBloc>(),
                    child: TaskFormSheet(
                      userId: userId,
                      initialDate: initialDate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
