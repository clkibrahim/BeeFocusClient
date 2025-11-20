import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../state/timer_state.dart';

class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.mode,
    required this.isRunning,
    required this.progress,
    required this.beeOffset,
    required this.beeTilt,
  });

  final TimerMode mode;
  final bool isRunning;
  final double progress;
  final Animation<double> beeOffset;
  final Animation<double> beeTilt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(260, 260),
            painter: _RingPainter(
              progress: progress,
              backgroundColor: AppColors.ring,
              progressColor: AppColors.darkBrown,
              strokeWidth: 16,
            ),
          ),
          AnimatedBuilder(
            animation: beeOffset,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, beeOffset.value),
                child: Transform.rotate(angle: beeTilt.value, child: child),
              );
            },
            child: SizedBox(
              height: 144,
              width: 144,
              child: Image.asset('assets/images/bee.png'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final basePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi,
      false,
      basePaint,
    );

    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      progressPaint,
    );

    final knobAngle = startAngle + sweep;
    final knobRadius = strokeWidth / 2 + 2;
    final knobCenter = Offset(
      center.dx + radius * math.cos(knobAngle),
      center.dy + radius * math.sin(knobAngle),
    );
    canvas.drawCircle(knobCenter, knobRadius, Paint()..color = progressColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
