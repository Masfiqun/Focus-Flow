import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ProductivityBreakdown extends StatelessWidget {
  const ProductivityBreakdown({
    super.key,
    required this.taskScore,
    required this.focusScore,
    required this.sessionScore,
  });

  final double taskScore;
  final double focusScore;
  final double sessionScore;

  @override
  Widget build(BuildContext context) {
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
            'Score Breakdown',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(
            height: AppSpacing.xs,
          ),

          Text(
            'How your productivity score was calculated today.',
            style: AppTextStyles.caption,
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          _buildMetric(
            icon: Icons.task_alt_rounded,
            title: 'Task completion',
            score: taskScore,
            weight: '40%',
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _buildMetric(
            icon: Icons.timer_outlined,
            title: "Today's focus",
            score: focusScore,
            weight: '40%',
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _buildMetric(
            icon: Icons.check_circle_outline_rounded,
            title: 'Session completion',
            score: sessionScore,
            weight: '20%',
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String title,
    required double score,
    required String weight,
  }) {
    final safeScore = score.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: AppColors.primaryLight,
            ),

            const SizedBox(
              width: 9,
            ),

            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body,
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Text(
              '${safeScore.round()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(
              width: 6,
            ),

            Text(
              weight,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(
            AppRadius.small,
          ),
          child: LinearProgressIndicator(
            value: safeScore / 100,
            minHeight: 7,
            backgroundColor:
                AppColors.surfaceLight,
            valueColor:
                const AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}