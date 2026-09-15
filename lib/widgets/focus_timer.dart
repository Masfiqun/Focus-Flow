import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FocusTimer extends StatelessWidget {
  const FocusTimer({
    super.key,
    required this.progress,
    required this.timeText,
    this.size,
  });

  final double progress;
  final String timeText;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final timerSize = size ??
        math.min(
          screenWidth * 0.65,
          280,
        );

    return SizedBox(
      width: timerSize,
      height: timerSize,
      child: CustomPaint(
        painter: _FocusTimerPainter(
          progress: progress.clamp(0.0, 1.0),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                timeText,
                style: AppTextStyles.timer.copyWith(
                  fontSize: timerSize * 0.19,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusTimerPainter extends CustomPainter {
  const _FocusTimerPainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 12;

    final backgroundPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusTimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}