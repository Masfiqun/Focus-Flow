import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    super.key,
  });

  static const List<double> _values = [
    0.42,
    0.68,
    0.55,
    0.88,
    0.72,
    0.94,
    0.63,
  ];

  static const List<String> _days = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WEEKLY ACTIVITY',
            style: AppTextStyles.caption,
          ),

          const SizedBox(height: 6),

          const Text(
            'Focus time',
            style: AppTextStyles.heading2,
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildBars(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBars() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        _values.length,
        (index) {
          return Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: _ChartBar(
                value: _values[index],
                day: _days[index],
                isToday: index == 5,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.value,
    required this.day,
    required this.isToday,
  });

  final double value;
  final String day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: value,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  maxWidth: 24,
                  minHeight: 4,
                ),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary
                      : AppColors.surfaceLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 9),

        Text(
          day,
          style: AppTextStyles.caption.copyWith(
            color: isToday
                ? AppColors.primaryLight
                : AppColors.textMuted,
            fontWeight:
                isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}