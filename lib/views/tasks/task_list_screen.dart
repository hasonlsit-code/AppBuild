import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../viewmodels/task_viewmodel.dart';
import 'widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = context.watch<TaskViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          final taskVM = context.read<TaskViewModel>();
          Navigator.pushNamed(context, AppRoutes.addTask).then((_) {
            taskVM.loadTasks();
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: taskVM.setSearch,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: taskVM.statusFilter == null,
                        onSelected: () => taskVM.setStatusFilter(null),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pending',
                        selected: taskVM.statusFilter == 0,
                        color: AppColors.warning,
                        onSelected: () => taskVM.setStatusFilter(0),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Completed',
                        selected: taskVM.statusFilter == 1,
                        color: AppColors.success,
                        onSelected: () => taskVM.setStatusFilter(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: taskVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : taskVM.filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text(
                              'No tasks found',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: taskVM.filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = taskVM.filteredTasks[index];
                          return TaskCard(
                            task: task,
                            onToggle: () => taskVM.toggleStatus(task.id!, task.status),
                            onDelete: () => taskVM.deleteTask(task.id!),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color = AppColors.primary,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: selected ? color : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: selected ? color : Colors.grey.shade300),
    );
  }
}
