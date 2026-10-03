import 'package:flutter/material.dart';

import '../models/focus_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SessionHistoryCard extends StatelessWidget {
  const SessionHistoryCard({
    super.key,
    required this.session,
  });

  final FocusSession session;

  bool get _isCompleted {
    return session.isCompleted;
  }

  bool get _hasFocusTime {
    return session.completedSeconds > 0;
  }

  String get _statusLabel {
    if (_isCompleted) {
      return 'Completed';
    }

    if (_hasFocusTime) {
      return 'Partial';
    }

    return 'No focus';
  }

  Color get _statusColor {
    if (_isCompleted) {
      return AppColors.success;
    }

    if (_hasFocusTime) {
      return AppColors.warning;
    }

    return AppColors.textMuted;
  }

  IconData get _statusIcon {
    if (_isCompleted) {
      return Icons.check_circle_rounded;
    }

    if (_hasFocusTime) {
      return Icons.timelapse_rounded;
    }

    return Icons.remove_circle_outline_rounded;
  }

  String get _durationLabel {
    final completedMinutes =
        session.completedSeconds ~/ 60;

    final durationMinutes =
        session.durationSeconds ~/ 60;

    if (_isCompleted) {
      return '$completedMinutes min focused';
    }

    if (completedMinutes == 0) {
      return '0 min of $durationMinutes min';
    }

    return '$completedMinutes min of '
        '$durationMinutes min';
  }

  String get _dateLabel {
    final date = session.startedAt;
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final sessionDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today.difference(sessionDay).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    if (difference > 1 && difference < 7) {
      return '${difference}d ago';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get _timeLabel {
    final date = session.startedAt;

    final hour = date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute =
        date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          _buildStatusIcon(),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  session.taskTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$_dateLabel • $_timeLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),

                const SizedBox(height: 4),

                Text(
                  _durationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          _buildStatus(),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _statusColor.withValues(
          alpha: 0.12,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _statusIcon,
        size: 21,
        color: _statusColor,
      ),
    );
  }

  Widget _buildStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _statusColor.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.small,
        ),
      ),
      child: Text(
        _statusLabel,
        style: AppTextStyles.caption.copyWith(
          color: _statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}