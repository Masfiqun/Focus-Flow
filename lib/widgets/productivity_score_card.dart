import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProductivityScoreCard extends StatelessWidget {
  const ProductivityScoreCard({
    super.key,
    required this.score,
    required String label,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    final normalizedScore = score.clamp(0, 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          _ScoreIndicator(
            score: normalizedScore,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRODUCTIVITY SCORE',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 7),
                Text(
                  _scoreLabel(normalizedScore),
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 5),
                Text(
                  'You are doing better than last week.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _scoreLabel(int value) {
    if (value >= 90) {
      return 'Outstanding';
    }

    if (value >= 75) {
      return 'Great work';
    }

    if (value >= 60) {
      return 'Good progress';
    }

    return 'Keep going';
  }
}

class _ScoreIndicator extends StatelessWidget {
  const _ScoreIndicator({
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: CustomPaint(
        painter: _ScorePainter(
          progress: score / 100,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$score',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePainter extends CustomPainter {
  const _ScorePainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 6;

    final backgroundPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScorePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
