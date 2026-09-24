import 'package:flutter/material.dart';

import '../widgets/app_page_route.dart';
import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/focus_progress_card.dart';
import '../widgets/quick_start_card.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'focus_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // ------------------------------------------------------------
  // TASK STORAGE
  // ------------------------------------------------------------

  void _loadTasks() {
    final savedTasks = TaskStorageService.getTasks();

    // Add the original demo tasks only if storage is empty.
    if (savedTasks.isEmpty) {
      _createInitialTasks();
      return;
    }

    setState(() {
      _tasks = savedTasks;
    });
  }

  Future<void> _createInitialTasks() async {
    const initialTasks = [
      Task(
        id: '1',
        title: 'Complete Flutter Assignment',
        description: 'Finish the FocusFlow internship assignment.',
        category: 'Study',
        duration: 45,
      ),
      Task(
        id: '2',
        title: 'Practice Dart',
        description: 'Practice Dart fundamentals and problem solving.',
        category: 'Study',
        duration: 30,
      ),
      Task(
        id: '3',
        title: 'Read Documentation',
        description: 'Read Flutter documentation and learn new widgets.',
        category: 'Work',
        duration: 25,
      ),
    ];

    for (final task in initialTasks) {
      await TaskStorageService.saveTask(task);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks = initialTasks;
    });
  }

  Future<void> _openAddTaskScreen() async {
    final Task? newTask = await Navigator.push<Task>(
      context,
      AppPageRoute<Task>(
        page: const AddTaskScreen(),
      ),
    );

    if (!mounted || newTask == null) {
      return;
    }

    setState(() {
      _tasks.insert(0, newTask);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${newTask.title}" was added successfully.',
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.medium,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleTaskCompleted(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
    );

    await TaskStorageService.updateTask(updatedTask);

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks = _tasks.map((currentTask) {
        if (currentTask.id == task.id) {
          return updatedTask;
        }

        return currentTask;
      }).toList();
    });
}

  Future<void> _deleteTask(Task task) async {
    final taskIndex = _tasks.indexWhere(
      (currentTask) => currentTask.id == task.id,
    );

    if (taskIndex == -1) {
      return;
    }

    await TaskStorageService.deleteTask(task.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks = _tasks
          .where(
            (currentTask) => currentTask.id != task.id,
          )
          .toList();
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${task.title}" was deleted.',
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceLight,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.medium,
          ),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryLight,
          onPressed: () async {
            await TaskStorageService.saveTask(task);

            if (!mounted) {
              return;
            }

            final restoreIndex = taskIndex > _tasks.length
                ? _tasks.length
                : taskIndex;

            setState(() {
              _tasks = List<Task>.from(_tasks)
                ..insert(
                  restoreIndex,
                  task,
                );
            });
          },
        ),
      ),
    );
  }

  void _openFocusScreen() {
    Navigator.push(
      context,
      AppPageRoute(
        page: const FocusScreen(),
      ),
    );
  }

  void _openStatisticsScreen() {
    Navigator.push(
      context,
      AppPageRoute(
        page: const StatisticsScreen(),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getHorizontalPadding(
                        constraints.maxWidth,
                      ),
                      vertical: AppSpacing.xl,
                    ),
                    child: _buildContent(
                      constraints.maxWidth,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(double width) {
    final isWide = width >= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(
          height: AppSpacing.xxl,
        ),
        if (isWide) _buildWideTopSection() else _buildMobileTopSection(),
        const SizedBox(
          height: AppSpacing.section,
        ),
        _buildTasksSection(),
        const SizedBox(
          height: AppSpacing.section,
        ),
        _buildQuickStartSection(),
        const SizedBox(
          height: AppSpacing.xxl,
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(
                height: AppSpacing.xs,
              ),
              Text(
                'Stay focused.',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                'Plan your work. Focus on what matters.',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
        const SizedBox(
          width: AppSpacing.md,
        ),
        _buildProfileButton(),
      ],
    );
  }

  Widget _buildProfileButton() {
    return Semantics(
      button: true,
      label: 'Profile',
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppRadius.medium,
          ),
          border: Border.all(
            color: AppColors.divider,
          ),
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          color: AppColors.textSecondary,
          size: 21,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TOP SECTION
  // ------------------------------------------------------------

  Widget _buildWideTopSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 5,
          child: FocusProgressCard(
            focusedMinutes: 85,
            targetMinutes: 125,
          ),
        ),
        const SizedBox(
          width: AppSpacing.xl,
        ),
        Expanded(
          flex: 4,
          child: _buildAddTaskCard(),
        ),
      ],
    );
  }

  Widget _buildMobileTopSection() {
    return Column(
      children: [
        const FocusProgressCard(
          focusedMinutes: 85,
          targetMinutes: 125,
        ),
        const SizedBox(
          height: AppSpacing.lg,
        ),
        _buildAddTaskCard(),
      ],
    );
  }

  // ------------------------------------------------------------
  // ADD TASK CARD
  // ------------------------------------------------------------

  Widget _buildAddTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(
                AppRadius.medium,
              ),
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: AppColors.primaryLight,
              size: 23,
            ),
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          Text(
            'Plan your next task',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Text(
            'Create a task and set a focus duration for your next session.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(
            height: AppSpacing.xl,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAddTaskScreen,
              icon: const Icon(
                Icons.add_rounded,
                size: 19,
              ),
              label: Text(
                'Add New Task',
                style: AppTextStyles.button,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(
                  double.infinity,
                  52,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppRadius.medium,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TASKS
  // ------------------------------------------------------------

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                "Today's Tasks",
                style: AppTextStyles.heading2,
              ),
            ),
            Text(
              '${_tasks.length} tasks',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(
          height: AppSpacing.lg,
        ),
        if (_tasks.isEmpty)
          _buildEmptyTaskState()
        else
          Column(
            children: _tasks.map(
              (task) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.md,
                  ),
                  child: TaskCard(
                    task: task,
                    onToggleCompleted: () {
                      _toggleTaskCompleted(task);
                    },
                    onDelete: () {
                      _deleteTask(task);
                    },
                  ),
                );
              },
            ).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyTaskState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.task_alt_rounded,
            size: 46,
            color: AppColors.textMuted,
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Text(
            'No tasks yet',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            'Create your first task to get started.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // QUICK START
  // ------------------------------------------------------------

  Widget _buildQuickStartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Start',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(
          height: AppSpacing.lg,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final useRow = constraints.maxWidth >= 560;

            if (useRow) {
              return Row(
                children: [
                  Expanded(
                    child: QuickStartCard(
                      title: 'Focus Session',
                      subtitle: 'Start a deep work session',
                      minutes: 25,
                      icon: Icons.timer_rounded,
                      onTap: _openFocusScreen,
                    ),
                  ),
                  const SizedBox(
                    width: AppSpacing.md,
                  ),
                  Expanded(
                    child: QuickStartCard(
                      title: 'Statistics',
                      subtitle: 'View your productivity',
                      minutes: 0,
                      icon: Icons.bar_chart_rounded,
                      onTap: _openStatisticsScreen,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                QuickStartCard(
                  title: 'Focus Session',
                  subtitle: 'Start a deep work session',
                  minutes: 25,
                  icon: Icons.timer_rounded,
                  onTap: _openFocusScreen,
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                QuickStartCard(
                  title: 'Statistics',
                  subtitle: 'View your productivity',
                  minutes: 0,
                  icon: Icons.bar_chart_rounded,
                  onTap: _openStatisticsScreen,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  double _getHorizontalPadding(double width) {
    if (width < 360) {
      return 16;
    }

    if (width < 600) {
      return 20;
    }

    if (width < 900) {
      return 28;
    }

    return 40;
  }
}