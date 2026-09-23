import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompleted,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggleCompleted;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.success.withValues(alpha: 0.35)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          _buildCheckButton(),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '${task.duration} min',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: 4),

          _buildMenuButton(),
        ],
      ),
    );
  }

  Widget _buildCheckButton() {
    return Semantics(
      button: true,
      label: task.isCompleted
          ? 'Mark ${task.title} as incomplete'
          : 'Mark ${task.title} as completed',
      child: GestureDetector(
        onTap: onToggleCompleted,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: task.isCompleted
                ? AppColors.success
                : Colors.transparent,
            border: Border.all(
              color: task.isCompleted
                  ? AppColors.success
                  : AppColors.textMuted,
              width: 1.5,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: task.isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    key: ValueKey('completed'),
                    size: 17,
                    color: Colors.white,
                  )
                : const SizedBox(
                    key: ValueKey('incomplete'),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
      tooltip: 'Task options',
      color: AppColors.surfaceLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
      ),
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: AppColors.textMuted,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: AppColors.error,
                ),
                const SizedBox(width: 10),
                Text(
                  'Delete task',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}