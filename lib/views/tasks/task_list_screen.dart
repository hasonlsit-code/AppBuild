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

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _fabCtrl;

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final taskVM = context.read<TaskViewModel>();
      await taskVM.loadTasks();
      if (mounted) _fabCtrl.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = context.watch<TaskViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabCtrl, curve: Curves.elasticOut),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          elevation: 6,
          onPressed: () {
            final vm = context.read<TaskViewModel>();
            Navigator.pushNamed(context, AppRoutes.addTask)
                .then((_) => vm.loadTasks());
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Add Task',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'My Tasks',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(58),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: taskVM.setSearch,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AppColors.textSecondary, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                taskVM.setSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Filter chips bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  _AnimChip(
                    label: 'All',
                    icon: Icons.grid_view_rounded,
                    selected: taskVM.statusFilter == null,
                    selectedGradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    selectedColor: AppColors.primary,
                    onTap: () => taskVM.setStatusFilter(null),
                  ),
                  const SizedBox(width: 10),
                  _AnimChip(
                    label: 'Pending',
                    icon: Icons.hourglass_top_rounded,
                    selected: taskVM.statusFilter == 0,
                    selectedGradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    ),
                    selectedColor: AppColors.warning,
                    onTap: () => taskVM.setStatusFilter(0),
                  ),
                  const SizedBox(width: 10),
                  _AnimChip(
                    label: 'Done',
                    icon: Icons.check_circle_rounded,
                    selected: taskVM.statusFilter == 1,
                    selectedGradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    ),
                    selectedColor: AppColors.success,
                    onTap: () => taskVM.setStatusFilter(1),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEF2F7)),

            // Task list
            Expanded(
              child: taskVM.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : taskVM.filteredTasks.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount: taskVM.filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = taskVM.filteredTasks[index];
                            return _SlideInItem(
                              key: ValueKey(task.id),
                              index: index,
                              child: TaskCard(
                                task: task,
                                onToggle: () =>
                                    taskVM.toggleStatus(task.id!, task.status),
                                onDelete: () => taskVM.deleteTask(task.id!),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// Staggered slide-in wrapper for each list item
class _SlideInItem extends StatefulWidget {
  final Widget child;
  final int index;
  const _SlideInItem({super.key, required this.child, required this.index});

  @override
  State<_SlideInItem> createState() => _SlideInItemState();
}

class _SlideInItemState extends State<_SlideInItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.4, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    final delay = Duration(milliseconds: widget.index.clamp(0, 7) * 55);
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _fade, child: widget.child),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 62,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No tasks yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first task ✨',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AnimChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final LinearGradient selectedGradient;
  final VoidCallback onTap;

  const _AnimChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.selectedGradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            gradient: selected ? selectedGradient : null,
            color: selected ? null : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : selectedColor,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
