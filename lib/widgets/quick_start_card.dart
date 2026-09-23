import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class QuickStartCard extends StatelessWidget {
  const QuickStartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int minutes;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(
        AppRadius.large,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 135,
          ),
          padding: const EdgeInsets.all(
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppRadius.large,
            ),
            border: Border.all(
              color: AppColors.divider,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading3,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  Text(
                    '$minutes min',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.14,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.small,
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color: AppColors.primaryLight,
      ),
    );
  }
}
