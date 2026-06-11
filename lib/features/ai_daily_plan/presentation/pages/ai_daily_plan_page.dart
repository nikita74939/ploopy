import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/ai_daily_plan_model.dart';
import '../bloc/ai_daily_plan_bloc.dart';

class AiDailyPlanPage extends StatelessWidget {
  const AiDailyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjection.aiDailyPlanBloc,
      child: const _AiDailyPlanView(),
    );
  }
}

class _AiDailyPlanView extends StatefulWidget {
  const _AiDailyPlanView();

  @override
  State<_AiDailyPlanView> createState() => _AiDailyPlanViewState();
}

class _AiDailyPlanViewState extends State<_AiDailyPlanView> {
  final _revisionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String? get _userId {
    final state = context.read<AuthBloc>().state;
    return state is Authenticated ? state.user.userId : null;
  }

  @override
  void dispose() {
    _revisionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiDailyPlanBloc, AiDailyPlanState>(
      listener: (context, state) {
        if (state is AiDailyPlanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is AiDailyPlanLoaded && state.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jadwal AI berhasil disimpan ke schedule.'),
            ),
          );
        }
      },
      builder: (context, state) {
        final previousPlan = state is AiDailyPlanLoading
            ? state.previousPlan
            : state is AiDailyPlanError
            ? state.previousPlan
            : null;
        final loadedState = state is AiDailyPlanLoaded ? state : null;
        final loadedPlan = loadedState?.plan;
        final plan = loadedPlan ?? previousPlan;
        final isLoading = state is AiDailyPlanLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text('AI Daily Plan', style: AppTextStyles.title),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IntroCard(),
                  const SizedBox(height: 16),
                  _DatePickerCard(date: _selectedDate, onTap: _pickDate),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _generatePlan,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(
                        isLoading ? 'Menyusun rencana...' : 'Generate Plan',
                        style: AppTextStyles.buttonPrimary,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (state is AiDailyPlanInitial)
                    const _EmptyPrompt()
                  else if (isLoading && plan == null)
                    const _LoadingCard()
                  else if (plan != null) ...[
                    _PlanResultCard(summary: plan.summary, plans: plan.plans),
                    const SizedBox(height: 16),
                    _RevisionBox(
                      controller: _revisionController,
                      isLoading: isLoading,
                      onRevise: _revisePlan,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: isLoading || (loadedState?.saved ?? false)
                            ? null
                            : _acceptPlan,
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: Text(
                          loadedState?.saved == true
                              ? 'Sudah Disimpan'
                              : 'Accept & Save',
                          style: AppTextStyles.buttonSecondary.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedDate = picked);
  }

  void _generatePlan() {
    final userId = _userId;
    if (userId == null) {
      _showAuthMessage();
      return;
    }
    context.read<AiDailyPlanBloc>().add(
      GenerateAiDailyPlan(userId: userId, date: _selectedDate),
    );
  }

  void _revisePlan() {
    final userId = _userId;
    final instruction = _revisionController.text.trim();
    if (userId == null) {
      _showAuthMessage();
      return;
    }
    if (instruction.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi instruksi revisi terlebih dahulu.')),
      );
      return;
    }
    context.read<AiDailyPlanBloc>().add(
      ReviseAiDailyPlan(
        userId: userId,
        date: _selectedDate,
        instruction: instruction,
      ),
    );
  }

  void _acceptPlan() {
    final userId = _userId;
    if (userId == null) {
      _showAuthMessage();
      return;
    }
    context.read<AiDailyPlanBloc>().add(AcceptAiDailyPlan(userId: userId));
  }

  void _showAuthMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan login ulang terlebih dahulu.')),
    );
  }
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rencana harian otomatis', style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text(
                  'AI akan membaca task belum selesai dan schedule yang sudah ada, lalu menyusun rekomendasi tanpa bentrok.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerCard({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tanggal', style: AppTextStyles.caption),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanResultCard extends StatelessWidget {
  final String summary;
  final List<AiDailyPlanItemModel> plans;

  const _PlanResultCard({required this.summary, required this.plans});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Rekomendasi AI', style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 10),
          Text(summary, style: AppTextStyles.bodySmall.copyWith(height: 1.45)),
          const SizedBox(height: 14),
          for (final plan in plans) ...[
            _PlanTile(plan: plan),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final AiDailyPlanItemModel plan;

  const _PlanTile({required this.plan});

  @override
  Widget build(BuildContext context) {
    final start = DateFormat.Hm().format(plan.startTime);
    final end = DateFormat.Hm().format(plan.endTime);
    final description = plan.description;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Text(
              '$start\n$end',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.title.toString(),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const _AiBadge(),
                  ],
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'AI',
        style: AppTextStyles.small.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RevisionBox extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onRevise;

  const _RevisionBox({
    required this.controller,
    required this.isLoading,
    required this.onRevise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Contoh: buat lebih santai, mulai dari jam 9 pagi...',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onRevise,
              icon: const Icon(Icons.tune_rounded, size: 17),
              label: Text('Revise Plan', style: AppTextStyles.buttonPrimary),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textMain,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt();

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      icon: Icons.auto_awesome_motion_rounded,
      title: 'Belum ada rencana',
      subtitle: 'Pilih tanggal lalu tekan Generate Plan.',
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      icon: Icons.hourglass_top_rounded,
      title: 'AI sedang menyusun jadwal',
      subtitle: 'Sebentar ya, Ploopy sedang mencari slot waktu terbaik.',
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 34),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
