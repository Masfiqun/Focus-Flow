import 'package:flutter/material.dart';

import '../models/focus_session.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.tasks,
    required this.sessions,
  });

  final List<Task> tasks;
  final List<FocusSession> sessions;

  int get _completedTasks {
    return tasks
        .where((task) => task.isCompleted)
        .length;
  }

  int get _completedSessions {
    return sessions
        .where((session) => session.isCompleted)
        .length;
  }

  int get _totalFocusSeconds {
    return sessions.fold(
      0,
      (total, session) {
        return total + session.completedSeconds;
      },
    );
  }

  bool get _hasDeepFocusSession {
    return sessions.any(
      (session) =>
          session.isCompleted &&
          session.completedSeconds >= 60 * 60,
    );
  }

  _Achievement get _achievement {
    if (_totalFocusSeconds >= 5 * 60 * 60) {
      return const _Achievement(
        title: 'Focus Master',
        description:
            'You have completed 5 hours of actual focus time.',
        icon: Icons.psychology_rounded,
        color: AppColors.primaryLight,
      );
    }

    if (_hasDeepFocusSession) {
      return const _Achievement(
        title: 'Deep Focus',
        description:
            'You completed a focus session lasting at least 60 minutes.',
        icon: Icons.hourglass_bottom_rounded,
        color: AppColors.warning,
      );
    }

    if (_completedTasks >= 5) {
      return const _Achievement(
        title: 'Task Finisher',
        description:
            'You have completed 5 tasks. Keep the momentum going.',
        icon: Icons.task_alt_rounded,
        color: AppColors.success,
      );
    }

    if (_completedSessions >= 1) {
      return const _Achievement(
        title: 'First Focus',
        description:
            'You completed your first focus session. Great start.',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.warning,
      );
    }

    return const _Achievement(
      title: 'Getting Started',
      description:
          'Complete your first focus session to unlock an achievement.',
      icon: Icons.rocket_launch_rounded,
      color: AppColors.primaryLight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final achievement = _achievement;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement.color.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.color,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTextStyles.heading3,
                ),

                const SizedBox(height: 4),

                Text(
                  achievement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}