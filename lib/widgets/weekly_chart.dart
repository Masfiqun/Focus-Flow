import 'package:flutter/material.dart';

import '../models/focus_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    super.key,
    required this.sessions,
  });

  final List<FocusSession> sessions;

  List<_DayFocus> _buildWeeklyData() {
    final now = DateTime.now();

    final startOfToday = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final days = List.generate(
      7,
      (index) => startOfToday.subtract(
        Duration(days: 6 - index),
      ),
    );

    return days.map((day) {
      final seconds = sessions
          .where((session) {
            final date = session.startedAt;

            return date.year == day.year &&
                date.month == day.month &&
                date.day == day.day;
          })
          .fold<int>(
            0,
            (total, session) {
              return total + session.completedSeconds;
            },
          );

      return _DayFocus(
        date: day,
        minutes: seconds ~/ 60,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _buildWeeklyData();

    final maxMinutes = weeklyData.fold<int>(
      0,
      (maximum, day) {
        return day.minutes > maximum
            ? day.minutes
            : maximum;
      },
    );

    final chartMax = maxMinutes == 0
        ? 60
        : ((maxMinutes / 30).ceil() * 30);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Focus',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            'Your actual focus time over the last 7 days.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(
            height: AppSpacing.xl,
          ),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                ...weeklyData.map(
                  (day) => Expanded(
                    child: _buildBar(
                      day,
                      chartMax,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
    _DayFocus day,
    int chartMax,
  ) {
    final ratio = chartMax <= 0
        ? 0.0
        : (day.minutes / chartMax)
            .clamp(0.0, 1.0);

    final isToday = _isToday(day.date);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 24,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                day.minutes > 0
                    ? '${day.minutes}m'
                    : '—',
                style: AppTextStyles.caption.copyWith(
                  color: isToday
                      ? AppColors.primaryLight
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: ratio == 0
                    ? 0.015
                    : ratio,
                widthFactor: 0.55,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 400,
                  ),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primary
                        : AppColors.primary
                            .withValues(alpha: 0.55),
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.small,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            _dayLabel(day.date),
            style: AppTextStyles.caption.copyWith(
              color: isToday
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
              fontWeight: isToday
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime date) {
    const labels = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return labels[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _DayFocus {
  const _DayFocus({
    required this.date,
    required this.minutes,
  });

  final DateTime date;
  final int minutes;
}