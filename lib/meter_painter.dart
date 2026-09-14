import 'dart:math';
import 'package:flutter/material.dart';

class MeterPainter extends CustomPainter {
  const MeterPainter({
    super.repaint,
    required this.percentage,
    required this.unitLabel,
  });

  final double percentage;
  final String unitLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = min(size.width, size.height);
    final center = Offset(size.width / 2, size.height * 0.58);
    final radius = shortestSide * 0.43;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = _toRadians(140);
    final sweepAngle = _toRadians(260);
    final valueSweep = _toRadians(260 * percentage.clamp(0, 100) / 100);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18
      ..color = const Color(0xFF1A2D48);
    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 22
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: pi * 2,
        colors: [
          Color(0xFFFF8B35),
          Color(0xFFFFE45C),
          Color(0xFF48F17A),
          Color(0xFF2F8DFF),
          Color(0xFF1B2740),
        ],
      ).createShader(rect);
    canvas.drawArc(rect, startAngle, valueSweep, false, glowPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: pi * 2,
        colors: [
          Color(0xFFFF884D),
          Color(0xFFFFED68),
          Color(0xFF4AF179),
          Color(0xFF2F8DFF),
          Color(0xFF263A56),
        ],
      ).createShader(rect);
    canvas.drawArc(rect, startAngle, valueSweep, false, progressPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF245E9C).withValues(alpha: 0.55);
    canvas.drawCircle(center, radius + 26, borderPaint);

    _drawTicks(canvas, center, radius);
    _drawNeedle(canvas, center, radius);
    _drawCenterDial(canvas, center, radius);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final smallTickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.28);
    final majorTickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = Colors.white.withValues(alpha: 0.85);

    for (var i = 0; i <= 50; i++) {
      final angle = 140 + (260 / 50) * i;
      final isMajor = i % 5 == 0;
      final start = _point(center, angle, radius - (isMajor ? 4 : 2));
      final end = _point(center, angle, radius - (isMajor ? 34 : 22));
      canvas.drawLine(start, end, isMajor ? majorTickPaint : smallTickPaint);
    }

    for (var i = 0; i <= 10; i++) {
      final value = i * 10;
      final angle = 140 + (260 / 10) * i;
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final textPoint = _point(center, angle, radius - 60);
      textPainter.paint(
        canvas,
        Offset(
          textPoint.dx - textPainter.width / 2,
          textPoint.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final needleAngle = 140 + 260 * percentage.clamp(0, 100) / 100;
    final needleEnd = _point(center, needleAngle, radius * 0.68);
    final needlePaint = Paint()
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 5
      ..color = const Color(0xFFFF4053);
    canvas.drawLine(center, needleEnd, needlePaint);
  }

  void _drawCenterDial(Canvas canvas, Offset center, double radius) {
    final dialRadius = radius * 0.45;
    final dialRect = Rect.fromCircle(center: center, radius: dialRadius);
    final dialPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF123B69),
          Color(0xFF06172A),
        ],
      ).createShader(dialRect);
    canvas.drawCircle(center, dialRadius, dialPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF1C91FF).withValues(alpha: 0.7);
    canvas.drawCircle(center, dialRadius, ringPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Speed\n',
        style: const TextStyle(
          color: Color(0xFF9DBCF4),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: '${percentage.round()}\n',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 58,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: unitLabel,
            style: const TextStyle(
              color: Color(0xFFB4C5E8),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  Offset _point(Offset center, num angle, double distance) {
    final radians = _toRadians(angle);
    return Offset(
      center.dx + distance * cos(radians),
      center.dy + distance * sin(radians),
    );
  }

  double _toRadians(num angle) => angle * pi / 180;

  @override
  bool shouldRepaint(MeterPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.unitLabel != unitLabel;
  }
}
