import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/todo_service.dart';
import '../../domain/todo_model.dart';
import '../widgets/todo_empty_state.dart';
import '../widgets/todo_filter_tabs.dart';
import '../widgets/todo_form_sheet.dart';
import '../widgets/todo_item_card.dart';
import '../widgets/todo_stats_card.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo> _allTodos = [];
  TodoFilter _currentFilter = TodoFilter.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await TodoService.getAll();

    // Sort: undone first, then by priority (high first), then by due date
    todos.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;

      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }

      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;

      return b.createdAt.compareTo(a.createdAt);
    });

    if (!mounted) return;
    setState(() {
      _allTodos = todos;
      _isLoading = false;
    });
  }

  List<Todo> get _filteredTodos {
    switch (_currentFilter) {
      case TodoFilter.all:
        return _allTodos.where((t) => !t.isDone).toList();
      case TodoFilter.today:
        return _allTodos.where((t) => t.isToday && !t.isDone).toList();
      case TodoFilter.upcoming:
        return _allTodos.where((t) => t.isUpcoming && !t.isDone).toList();
      case TodoFilter.done:
        return _allTodos.where((t) => t.isDone).toList();
    }
  }

  Map<TodoFilter, int> get _counts {
    return {
      TodoFilter.all: _allTodos.where((t) => !t.isDone).length,
      TodoFilter.today: _allTodos.where((t) => t.isToday && !t.isDone).length,
      TodoFilter.upcoming:
          _allTodos.where((t) => t.isUpcoming && !t.isDone).length,
      TodoFilter.done: _allTodos.where((t) => t.isDone).length,
    };
  }

  Future<void> _addTodo() async {
    HapticFeedback.lightImpact();
    final newTodo = await TodoFormSheet.showCreate(context);
    if (newTodo == null) return;

    await TodoService.create(
      title: newTodo.title,
      description: newTodo.description,
      dueDate: newTodo.dueDate,
      dueTime: newTodo.dueTime,
      priority: newTodo.priority,
      category: newTodo.category,
    );

    await _loadTodos();
    _showSuccess('Tugas berhasil ditambahkan ✨');
  }

  Future<void> _editTodo(Todo todo) async {
    final edited = await TodoFormSheet.showEdit(context, todo);
    if (edited == null) return;

    await TodoService.update(edited);
    await _loadTodos();
    _showSuccess('Tugas berhasil diperbarui ✨');
  }

  Future<void> _toggleDone(Todo todo) async {
    HapticFeedback.mediumImpact();
    await TodoService.toggleDone(todo.id);
    await _loadTodos();

    if (!todo.isDone) {
      _showSuccess('Yeay, tugas selesai! 🎉');
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    await TodoService.delete(todo.id);
    await _loadTodos();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tugas dihapus',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearDone() async {
    final doneCount = _allTodos.where((t) => t.isDone).length;
    if (doneCount == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Row(
          children: [
            const Text('🧹', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Hapus Selesai?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          '$doneCount tugas selesai akan dihapus permanen',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TodoService.deleteAllDone();
      await _loadTodos();
      _showSuccess('$doneCount tugas dihapus 🧹');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _buildFab(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final hasDone = _allTodos.any((t) => t.isDone);

    return AppBar(
      backgroundColor: Colors.grey.shade50,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'To-Do List',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        if (hasDone)
          IconButton(
            icon: Icon(
              Icons.cleaning_services_rounded,
              color: Colors.grey.shade700,
              size: 20,
            ),
            onPressed: _clearDone,
            tooltip: 'Hapus yang selesai',
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final total = _allTodos.where((t) => t.isToday).length;
    final done =
        _allTodos.where((t) => t.isToday && t.isDone).length;
    final pending = total - done;

    return Column(
      children: [
        const SizedBox(height: 4),
        if (total > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TodoStatsCard(
              total: total,
              done: done,
              pending: pending,
            ),
          ),
        const SizedBox(height: 4),
        TodoFilterTabs(
          selected: _currentFilter,
          onChanged: (f) => setState(() => _currentFilter = f),
          counts: _counts,
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    final todos = _filteredTodos;

    if (todos.isEmpty) {
      return TodoEmptyState(filter: _currentFilter);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: todos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final todo = todos[i];
        return Dismissible(
          key: ValueKey(todo.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteTodo(todo),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: Text(
                      'Hapus tugas?',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      '"${todo.title}" akan dihapus permanen',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Hapus',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          child: TodoItemCard(
            todo: todo,
            onToggle: () => _toggleDone(todo),
            onTap: () => _editTodo(todo),
          ),
        );
      },
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _addTodo,
      backgroundColor: AppColors.primary,
      elevation: 6,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}