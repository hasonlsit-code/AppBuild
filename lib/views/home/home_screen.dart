import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../services/database_service.dart';
import '../../core/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _cardAnims = List.generate(3, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            i * 0.18,
            0.45 + i * 0.18,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndAnimate());
  }

  Future<void> _loadAndAnimate() async {
    if (!mounted) return;
    DatabaseService().getDbPath(); // in path ra Debug Console
    final homeVM = context.read<HomeViewModel>();
    await homeVM.loadStats();
    if (mounted) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final authVM = context.read<AuthViewModel>();
    final today = DateFormat('EEE, MMM d yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // Collapsible gradient header
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () {
                  authVM.logout();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3730A3), Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                    ),
                  ),
                  // Blobs
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  // Text content
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome back 🎓',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white70,
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              today,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section label
                  const Text(
                    'Task Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Stat cards with stagger
                  homeVM.isLoading
                      ? const Center(
                          heightFactor: 3,
                          child: CircularProgressIndicator(),
                        )
                      : Row(
                          children: [
                            for (int i = 0; i < 3; i++) ...[
                              if (i > 0) const SizedBox(width: 10),
                              Expanded(
                               child: AnimatedBuilder(
                                animation: _cardAnims[i],
                                builder: (_, child) => Transform.scale(
                                  scale: _cardAnims[i].value.clamp(0.0, 1.0),
                                  child: Opacity(
                                    opacity: _cardAnims[i].value.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                ),
                                child: [
                                  StatCard(
                                    label: 'Total',
                                    count: homeVM.totalTasks,
                                    color: AppColors.primary,
                                    icon: Icons.assignment_rounded,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  StatCard(
                                    label: 'Done ✅',
                                    count: homeVM.completedTasks,
                                    color: AppColors.success,
                                    icon: Icons.check_circle_rounded,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  StatCard(
                                    label: 'Pending ⏳',
                                    count: homeVM.pendingTasks,
                                    color: AppColors.warning,
                                    icon: Icons.pending_actions_rounded,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ][i],
                              ),
                             ),
                            ],
                          ],
                        ),

                  const SizedBox(height: 32),

                  // View tasks action card
                  GestureDetector(
                    onTap: () {
                      final homeVM = context.read<HomeViewModel>();
                      Navigator.pushNamed(context, AppRoutes.taskList)
                          .then((_) => homeVM.loadStats());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.42),
                            blurRadius: 18,
                            offset: const Offset(0, 9),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.list_alt_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'View All Tasks',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Manage and track your progress',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white60,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
