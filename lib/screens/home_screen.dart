import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_page_route.dart';
import '../widgets/focus_progress_card.dart';
import '../widgets/quick_start_card.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'focus_screen.dart';
import 'statistics_screen.dart';
import 'task_details_screen.dart';
import '../models/focus_session.dart';
import '../services/focus_session_storage_service.dart';

class _DeletedTaskBackup {
  final Task task;
  final List<FocusSession> sessions;

  const _DeletedTaskBackup({
    required this.task,
    required this.sessions,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  List<FocusSession> _focusSessions = [];

  int get _todayFocusSeconds {
    final now = DateTime.now();

    return _focusSessions
        .where(
          (session) {
            final date = session.startedAt;

            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          },
        )
        .fold(
          0,
          (total, session) {
            return total + session.completedSeconds;
          },
        );
  }

  int get _todayFocusMinutes {
    return _todayFocusSeconds ~/ 60;
  }

  int get _todayFocusTargetMinutes {
    return 125;
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadFocusSessions();
  }

  // ------------------------------------------------------------
  // TASK STORAGE
  // ------------------------------------------------------------

  void _loadTasks() {
    final savedTasks = TaskStorageService.getTasks();

    if (savedTasks.isEmpty &&
        !TaskStorageService.initialTasksCreated) {
      _createInitialTasks();
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks = savedTasks;
    });
  }

  void _loadFocusSessions() {
    final sessions =
        FocusSessionStorageService.getSessions();

    if (!mounted) {
      return;
    }

    setState(() {
      _focusSessions = sessions;
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

    await TaskStorageService.markInitialTasksCreated();

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks = initialTasks;
    });
  }

  // ------------------------------------------------------------
  // ADD TASK
  // ------------------------------------------------------------

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

    _showSnackBar(
      '"${newTask.title}" was added successfully.',
    );
  }

  // ------------------------------------------------------------
  // TASK DETAILS
  // ------------------------------------------------------------

  Future<void> _openTaskDetailsScreen(Task task) async {
    final TaskDetailsResult? result =
        await Navigator.push<TaskDetailsResult>(
      context,
      AppPageRoute<TaskDetailsResult>(
        page: TaskDetailsScreen(
          task: task,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    _loadTasks();
    _loadFocusSessions();

    if (result == null) {
      return;
    }

    if (result.action == TaskDetailsAction.updated) {
      _showSnackBar(
        '"${result.task.title}" was updated successfully.',
      );

      return;
    }

    if (result.action == TaskDetailsAction.deleted) {
      _showSnackBar(
        '"${result.task.title}" was deleted.',
      );
    }
  }

  // ------------------------------------------------------------
  // TOGGLE COMPLETED
  // ------------------------------------------------------------

  Future<void> _toggleTaskCompleted(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
    );

    await TaskStorageService.updateTask(
      updatedTask,
    );

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

  // ------------------------------------------------------------
  // DELETE TASK
  // ------------------------------------------------------------

  Future<void> _deleteTask(Task task) async {
    final taskIndex = _tasks.indexWhere(
      (currentTask) => currentTask.id == task.id,
    );

    if (taskIndex == -1) {
      return;
    }

    // Create a complete backup before deleting anything.
    final deletedTaskBackup = _DeletedTaskBackup(
      task: task,
      sessions: FocusSessionStorageService.getSessionsForTask(
        task.id,
      ),
    );

    try {
      // Delete the task's focus-session history first.
      await FocusSessionStorageService.deleteSessionsForTask(
        task.id,
      );

      // Then delete the task itself.
      await TaskStorageService.deleteTask(
        task.id,
      );

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

      // Keep the Home statistics in sync.
      _loadFocusSessions();

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

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
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.medium,
            ),
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.primaryLight,
            onPressed: () async {
              await _restoreDeletedTask(
                deletedTaskBackup,
                taskIndex,
              );
            },
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      _showSnackBar(
        'Unable to delete the task. Please try again.',
      );
    }
  }

  Future<void> _restoreDeletedTask(
      _DeletedTaskBackup backup,
      int originalIndex,
    ) async {
      try {
        // Restore the task.
        await TaskStorageService.saveTask(
          backup.task,
        );

        // Restore all focus sessions that belonged to it.
        await FocusSessionStorageService.restoreSessions(
          backup.sessions,
        );

        if (!mounted) {
          return;
        }

        final safeIndex = originalIndex > _tasks.length
            ? _tasks.length
            : originalIndex;

        setState(() {
          _tasks = List<Task>.from(_tasks)
            ..insert(
              safeIndex,
              backup.task,
            );
        });

        _loadFocusSessions();

        _showSnackBar(
          '"${backup.task.title}" was restored.',
        );
      } catch (_) {
        if (!mounted) {
          return;
        }

        _showSnackBar(
          'Unable to restore the task. Please try again.',
        );
      }
    }

  // ------------------------------------------------------------
  // FOCUS SCREEN
  // ------------------------------------------------------------

  Future<void> _openFocusScreen() async {
    final FocusSessionResult? result =
        await Navigator.push<FocusSessionResult>(
      context,
      AppPageRoute<FocusSessionResult>(
        page: const FocusScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

      _loadTasks();
      _loadFocusSessions();

      if (result == FocusSessionResult.completed) {
        _showSnackBar(
          'Focus session completed successfully.',
        );
      }
  }

  // ------------------------------------------------------------
  // STATISTICS SCREEN
  // ------------------------------------------------------------

  void _openStatisticsScreen() {
    Navigator.push(
      context,
      AppPageRoute(
        page: const StatisticsScreen(),
      ),
    );
  }

  // ------------------------------------------------------------
  // SNACKBAR
  // ------------------------------------------------------------

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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
        if (isWide)
          _buildWideTopSection()
        else
          _buildMobileTopSection(),
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
        Expanded(
          flex: 5,
          child: FocusProgressCard(
            focusedMinutes: _todayFocusMinutes,
            targetMinutes: _todayFocusTargetMinutes,
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
        FocusProgressCard(
          focusedMinutes: _todayFocusMinutes,
          targetMinutes: _todayFocusTargetMinutes,
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
                  child: _buildTaskItem(task),
                );
              },
            ).toList(),
          ),
      ],
    );
  }

  Widget _buildTaskItem(Task task) {
    return TaskCard(
      task: task,
      onTap: () {
        _openTaskDetailsScreen(task);
      },
      onToggleCompleted: () {
        _toggleTaskCompleted(task);
      },
      onDelete: () {
        _deleteTask(task);
      },
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 32,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          Text(
            'No tasks yet',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            'Create your first task and start '
            'building your focus routine.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          ElevatedButton.icon(
            onPressed: _openAddTaskScreen,
            icon: const Icon(
              Icons.add_rounded,
              size: 19,
            ),
            label: Text(
              'Add Your First Task',
              style: AppTextStyles.button,
            ),
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