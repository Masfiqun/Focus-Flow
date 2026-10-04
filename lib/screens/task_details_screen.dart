import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_page_route.dart';
import 'edit_task_screen.dart';
import 'focus_screen.dart';
import '../services/task_storage_service.dart';
import '../services/focus_session_storage_service.dart';

enum TaskDetailsAction {
  updated,
  deleted,
}

class TaskDetailsResult {
  final Task task;
  final TaskDetailsAction action;

  const TaskDetailsResult({
    required this.task,
    required this.action,
  });
}

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _openEditTaskScreen() async {
    final Task? updatedTask = await Navigator.push<Task>(
      context,
      AppPageRoute<Task>(
        page: EditTaskScreen(
          task: _task,
        ),
      ),
    );

    if (!mounted || updatedTask == null) {
      return;
    }

    setState(() {
      _task = updatedTask;
    });

    Navigator.pop<TaskDetailsResult>(
      context,
      TaskDetailsResult(
        task: updatedTask,
        action: TaskDetailsAction.updated,
      ),
    );
  }

  Future<void> _openFocusScreen() async {
    final FocusSessionResult? result =
        await Navigator.push<FocusSessionResult>(
      context,
      AppPageRoute<FocusSessionResult>(
        page: FocusScreen(
          task: _task,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == FocusSessionResult.completed) {
      // Read the latest version directly from Hive.
      final savedTasks = TaskStorageService.getTasks();

      Task? updatedTask;

      for (final savedTask in savedTasks) {
        if (savedTask.id == _task.id) {
          updatedTask = savedTask;
          break;
        }
      }

      if (updatedTask != null) {
        setState(() {
          _task = updatedTask!;
        });

        Navigator.pop<TaskDetailsResult>(
          context,
          TaskDetailsResult(
            task: updatedTask,
            action: TaskDetailsAction.updated,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.large,
            ),
          ),
          title: Text(
            'Delete task?',
            style: AppTextStyles.heading3,
          ),
          content: Text(
            'Are you sure you want to delete "${_task.title}"?',
            style: AppTextStyles.bodySecondary,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Delete',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }

    try {
      // Remove all focus-session history associated
      // with this task first.
      await FocusSessionStorageService.deleteSessionsForTask(
        _task.id,
      );

      // Then remove the task itself.
      await TaskStorageService.deleteTask(
        _task.id,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop<TaskDetailsResult>(
        context,
        TaskDetailsResult(
          task: _task,
          action: TaskDetailsAction.deleted,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete the task. Please try again.',
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
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return Icons.school_rounded;

      case 'work':
        return Icons.work_outline_rounded;

      case 'personal':
        return Icons.person_outline_rounded;

      case 'health':
        return Icons.favorite_outline_rounded;

      default:
        return Icons.label_outline_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return AppColors.primary;

      case 'work':
        return AppColors.warning;

      case 'personal':
        return AppColors.primaryLight;

      case 'health':
        return AppColors.success;

      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Task Details',
          style: AppTextStyles.heading3,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double horizontalPadding =
                constraints.maxWidth < 360
                    ? 16
                    : constraints.maxWidth < 600
                        ? 20
                        : constraints.maxWidth < 900
                            ? 28
                            : 40;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 720,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      SizedBox(
                        height: AppSpacing.xxl,
                      ),
                      _buildDescriptionCard(),
                      SizedBox(
                        height: AppSpacing.xxl,
                      ),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final Color categoryColor =
        _getCategoryColor(_task.category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _task.title,
                  style: AppTextStyles.heading1,
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoChip(
                icon: _getCategoryIcon(
                  _task.category,
                ),
                label: _task.category,
                color: categoryColor,
              ),
              _buildInfoChip(
                icon: Icons.timer_outlined,
                label: '${_task.duration} min',
                color: AppColors.primaryLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool completed = _task.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(
          AppRadius.small,
        ),
      ),
      child: Text(
        completed ? 'Completed' : 'Pending',
        style: AppTextStyles.caption.copyWith(
          color: completed
              ? AppColors.success
              : AppColors.primaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
          Text(
            'Description',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 12),
          Text(
            _task.description,
            style: AppTextStyles.bodySecondary.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openFocusScreen,
            icon: const Icon(
              Icons.play_arrow_rounded,
            ),
            label: const Text(
              'Start Focus',
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openEditTaskScreen,
            icon: const Icon(
              Icons.edit_outlined,
            ),
            label: const Text(
              'Edit Task',
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
            ),
            label: const Text(
              'Delete Task',
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}