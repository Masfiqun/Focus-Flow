import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FocusFlowLogo extends StatelessWidget {
  const FocusFlowLogo({
    super.key,
    this.showName = true,
    this.iconSize = 42,
  });

  final bool showName;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(
              iconSize * 0.3,
            ),
          ),
          child: Icon(
            Icons.bolt_rounded,
            size: iconSize * 0.55,
            color: Colors.white,
          ),
        ),
        if (showName) ...[
          SizedBox(width: iconSize * 0.28),
          Text(
            'FocusFlow',
            style: AppTextStyles.heading2.copyWith(
              fontSize: iconSize * 0.43,
            ),
          ),
        ],
      ],
    );
  }
}
