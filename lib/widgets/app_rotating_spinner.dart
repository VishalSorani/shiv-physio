import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A lightweight rotating ring spinner (track + short arc) similar to CSS
/// `border-t` spinners.
class AppRotatingSpinner extends StatelessWidget {
  final Animation<double> turns;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  const AppRotatingSpinner({
    super.key,
    required this.turns,
    this.size = 24,
    this.strokeWidth = 3,
    required this.color,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: turns,
      child: CustomPaint(
        size: Size.square(size),
        painter: _SpinnerPainter(
          strokeWidth: strokeWidth,
          color: color,
          trackColor: trackColor,
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  _SpinnerPainter({
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track
    canvas.drawCircle(center, radius, trackPaint);

    // Short arc starting at the top (-90°), mimicking "border-top-color".
    const sweep = math.pi / 2; // 90 degrees
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
