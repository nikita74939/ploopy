import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_form_sheet.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadForCurrentUser();
  }

  void _loadForCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.userId;
      context.read<TaskBloc>().add(LoadTasks(userId: _currentUserId!));
    }
  }

  void _showTaskSheet({TaskEntity? task}) {
    final userId = _currentUserId;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: TaskFormSheet(userId: userId, task: task),
      ),
    );
  }

  void _showTaskDetail(TaskEntity task) {
    final userId = _currentUserId;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: _TaskDetailSheet(
          task: task,
          onEdit: () {
            Navigator.pop(context);
            _showTaskSheet(task: task);
          },
          onToggleCompleted: () {
            context.read<TaskBloc>().add(
              ToggleTaskCompletion(id: task.id, userId: userId),
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tasks')),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is TaskLoading || state is TaskInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskLoaded) {
            if (state.tasks.isEmpty) return _buildEmptyState();
            return _buildTaskList(state.tasks);
          }

          if (state is TaskError) {
            return _buildMessageState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat task',
              subtitle: state.message,
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskSheet(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState() {
    return _buildMessageState(
      icon: Icons.assignment_outlined,
      title: 'Belum ada task',
      subtitle: 'Tekan tombol tambah untuk membuat task pertamamu.',
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 14),
            Text(title, style: AppTextStyles.heading),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskEntity> tasks) {
    final pinnedTasks = tasks.where((task) => task.isPinned).toList();
    final otherTasks = tasks.where((task) => !task.isPinned).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        if (pinnedTasks.isNotEmpty) ...[
          _buildSectionTitle('Pinned', Icons.push_pin_rounded),
          const SizedBox(height: 10),
          ...pinnedTasks.map(_buildTaskCard),
          const SizedBox(height: 18),
        ],
        if (otherTasks.isNotEmpty) ...[
          if (pinnedTasks.isNotEmpty)
            _buildSectionTitle('Task lainnya', Icons.list_alt_rounded),
          if (pinnedTasks.isNotEmpty) const SizedBox(height: 10),
          ...otherTasks.map(_buildTaskCard),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskEntity task) {
    final color = Color(task.color);
    final deadlineColor = _getDeadlineColor(task.deadline, task);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(
        alignment: Alignment.centerLeft,
        color: task.isPinned ? AppColors.textSecondary : AppColors.primary,
        icon: task.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
      ),
      secondaryBackground: _buildDismissBackground(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        icon: Icons.delete_outline_rounded,
      ),
      confirmDismiss: (direction) async {
        final userId = _currentUserId;
        if (userId == null) return false;

        if (direction == DismissDirection.startToEnd) {
          context.read<TaskBloc>().add(
            ToggleTaskPin(id: task.id, userId: userId),
          );
          return false;
        }

        return _confirmDeleteTask(task);
      },
      onDismissed: (_) {
        final userId = _currentUserId;
        if (userId == null) return;
        context.read<TaskBloc>().add(DeleteTask(id: task.id, userId: userId));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _showTaskDetail(task),
            onLongPress: () {
              final userId = _currentUserId;
              if (userId == null) return;
              context.read<TaskBloc>().add(
                ToggleTaskPin(id: task.id, userId: userId),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.greyBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_taskIcon(task.iconName), color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (task.isPinned) ...[
                              const Icon(
                                Icons.push_pin_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                task.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.title.copyWith(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted
                                      ? AppColors.textMuted
                                      : AppColors.textMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (task.subject?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.subject!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: deadlineColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                DateTimeUtils.formatDateTime(task.deadline),
                                style: AppTextStyles.caption.copyWith(
                                  color: deadlineColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (task.details?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.details!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: task.isCompleted
                        ? 'Tandai belum selesai'
                        : 'Selesai',
                    onPressed: () {
                      final userId = _currentUserId;
                      if (userId == null) return;
                      context.read<TaskBloc>().add(
                        ToggleTaskCompletion(id: task.id, userId: userId),
                      );
                    },
                    icon: Icon(
                      task.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: task.isCompleted
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit task',
                    onPressed: () => _showTaskSheet(task: task),
                    icon: const Icon(Icons.edit_outlined),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      alignment: alignment,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: AppColors.white),
    );
  }

  Future<bool> _confirmDeleteTask(TaskEntity task) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Hapus Task', style: AppTextStyles.heading),
            content: Text(
              'Yakin ingin menghapus "${task.name}"?',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Color _getDeadlineColor(DateTime deadline, TaskEntity task) {
    final difference = deadline.difference(DateTime.now());

    if (task.isCompleted) return AppColors.success;
    if (difference.isNegative || difference.inHours < 1) return AppColors.error;
    if (difference.inHours < 12) return AppColors.warning;
    return AppColors.textSecondary;
  }

  IconData _taskIcon(String? iconName) {
    switch (iconName) {
      case 'homework':
        return Icons.home_work_rounded;
      case 'exam':
        return Icons.quiz_rounded;
      case 'project':
        return Icons.folder_rounded;
      case 'personal':
        return Icons.person_rounded;
      default:
        return Icons.assignment_rounded;
    }
  }
}

class _TaskDetailSheet extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompleted;

  const _TaskDetailSheet({
    required this.task,
    required this.onEdit,
    required this.onToggleCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(task.color);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyBorder,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(_taskIcon(task.iconName), color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.name, style: AppTextStyles.heading),
                      const SizedBox(height: 4),
                      Text(
                        task.subject?.trim().isNotEmpty == true
                            ? task.subject!
                            : 'Tanpa mata pelajaran',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _DetailRow(
              icon: Icons.schedule_rounded,
              label: 'Deadline',
              value: DateTimeUtils.formatDateTime(task.deadline),
            ),
            const SizedBox(height: 10),
            _DetailRow(
              icon: task.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              label: 'Status',
              value: task.isCompleted ? 'Selesai' : 'Belum selesai',
            ),
            if (task.details?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Text('Detail', style: AppTextStyles.title),
              const SizedBox(height: 6),
              Text(task.details!, style: AppTextStyles.body),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onToggleCompleted,
                    icon: Icon(
                      task.isCompleted
                          ? Icons.undo_rounded
                          : Icons.check_circle_rounded,
                    ),
                    label: Text(
                      task.isCompleted ? 'Tandai Belum' : 'Tandai Selesai',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _taskIcon(String? iconName) {
    switch (iconName) {
      case 'homework':
        return Icons.home_work_rounded;
      case 'exam':
        return Icons.quiz_rounded;
      case 'project':
        return Icons.folder_rounded;
      case 'personal':
        return Icons.person_rounded;
      default:
        return Icons.assignment_rounded;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: AppTextStyles.bodySmall),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
