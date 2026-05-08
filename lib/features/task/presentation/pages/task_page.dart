import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/neo_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/task_bloc.dart';
import '../../data/models/task_model.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String? _currentUserId; // TAMBAHAN

  @override
  void initState() {
    super.initState();
    // Ambil userId dari AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.userId;
      context.read<TaskBloc>().add(LoadTasks(userId: _currentUserId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskOperationSuccess) {
            // Refresh tasks dengan userId terbaru
            if (_currentUserId != null) {
              context.read<TaskBloc>().add(LoadTasks(userId: _currentUserId!));
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addTask,
            arguments: _currentUserId,
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first task',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    // Separate pinned and unpinned tasks
    final pinnedTasks = tasks.where((t) => t.isPinned).toList();
    final unpinnedTasks = tasks.where((t) => !t.isPinned).toList();

    return ListView(
      padding: const EdgeInsets.all(AppStyle.paddingMedium),
      children: [
        if (pinnedTasks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.push_pin, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Pinned',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ...pinnedTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTaskCard(task),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...unpinnedTasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTaskCard(task),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: task.isPinned ? AppColors.textSecondary : AppColors.primary,
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
        ),
        child: Icon(
          task.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Toggle pin
          context.read<TaskBloc>().add(
            ToggleTaskPin(id: task.id, userId: _currentUserId!),
          );
          return false;
        } else {
          // Delete
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Task'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<TaskBloc>().add(
            DeleteTask(id: task.id, userId: _currentUserId!),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.editTask, arguments: task);
        },
        onLongPress: () {
          context.read<TaskBloc>().add(
            ToggleTaskPin(id: task.id, userId: _currentUserId!),
          );
        },
        child: NeoCard(
          accentColor: Color(task.color),
          onTap: () {
            context.read<TaskBloc>().add(
              ToggleTaskCompletion(id: task.id, userId: _currentUserId!),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppStyle.paddingMedium),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppColors.success.withOpacity(0.2)
                        : Color(task.color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    task.isCompleted ? Icons.check_circle : Icons.assignment,
                    color: task.isCompleted
                        ? AppColors.success
                        : Color(task.color),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (task.isPinned) ...[
                            const Icon(
                              Icons.push_pin,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              task.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (task.subject != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.subject!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: _getDeadlineColor(task.deadline, task),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateTimeUtils.formatDateTime(task.deadline),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDeadlineColor(task.deadline, task),
                            ),
                          ),
                        ],
                      ),
                      if (task.details != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.details!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: task.isCompleted
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDeadlineColor(DateTime deadline, TaskModel task) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (task.isCompleted) return AppColors.success;
    if (difference.isNegative) return AppColors.error;
    if (difference.inHours < 1) return AppColors.error;
    if (difference.inHours < 12) return AppColors.warning;
    return AppColors.textSecondary;
  }
}
