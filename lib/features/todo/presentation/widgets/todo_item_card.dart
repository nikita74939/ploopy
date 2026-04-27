import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/todo_model.dart';

class TodoItemCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TodoItemCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  todo.isOverdue ? Colors.red.shade200 : Colors.grey.shade100,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckbox(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: todo.isDone ? todo.priorityColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: todo.isDone ? todo.priorityColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child:
            todo.isDone
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                todo.title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: todo.isDone ? Colors.grey.shade400 : Colors.black87,
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            _buildPriorityFlag(),
          ],
        ),
        if (todo.description.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            todo.description,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildCategoryChip(),
            if (todo.dueDate != null) _buildDateChip(),
            if (todo.dueTime != null) _buildTimeChip(),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityFlag() {
    return Icon(
      Icons.flag_rounded,
      size: 14,
      color: todo.isDone ? Colors.grey.shade300 : todo.priorityColor,
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: todo.categoryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(todo.categoryEmoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            todo.categoryLabel,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: todo.categoryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip() {
    final overdueColor = todo.isOverdue ? Colors.red : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: todo.isOverdue ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 10, color: overdueColor),
          const SizedBox(width: 4),
          Text(
            _formatDate(todo.dueDate!),
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: overdueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 10,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            todo.dueTime!,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hari ini';
    if (dateOnly == tomorrow) return 'Besok';
    if (dateOnly == yesterday) return 'Kemarin';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
