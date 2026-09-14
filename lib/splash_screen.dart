import 'dart:math';

import 'package:flutter/material.dart';

import 'speedometer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.75, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.repeat(reverse: true);
    _navigateToHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation1, animation2) => const Speedometer(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04101F),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF04101F),
              Color(0xFF0B3157),
              Color(0xFF020914),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Column(
              children: [
                const Spacer(),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return _SpeedTrackMark(progress: _controller.value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text.rich(
                  TextSpan(
                    text: 'Speed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                    children: [
                      TextSpan(
                        text: 'Track',
                        style: TextStyle(color: Color(0xFF43B3FF)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Drive Safe, Go Further',
                  style: TextStyle(
                    color: Color(0xFFA8BCE1),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 34),
                const _LoadingBar(),
                const Spacer(),
                const _SplashFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedTrackMark extends StatelessWidget {
  const _SpeedTrackMark({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      height: 156,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF0E4B8D),
            Color(0xFF071C34),
          ],
        ),
        border: Border.all(color: const Color(0xFF2E6AA5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43B3FF).withValues(alpha: 0.26),
            blurRadius: 40,
            spreadRadius: 6,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SplashGaugePainter(progress: progress),
        child: const Center(
          child: Icon(
            Icons.speed_rounded,
            color: Colors.white,
            size: 58,
          ),
        ),
      ),
    );
  }
}

class _SplashGaugePainter extends CustomPainter {
  const _SplashGaugePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.39;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = _toRadians(140);
    final sweepAngle = _toRadians(260);
    final animatedSweep = sweepAngle * (0.55 + 0.35 * progress);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1B3755);
    canvas.drawArc(rect, startAngle, sweepAngle, false, track);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF35E676),
          Color(0xFF43B3FF),
          Color(0xFF3159FF),
        ],
      ).createShader(rect);
    canvas.drawArc(rect, startAngle, animatedSweep, false, progressPaint);

    final needleAngle = 140 + 260 * (0.45 + 0.18 * sin(progress * pi));
    final needleEnd = _point(center, needleAngle, radius * 0.72);
    final needlePaint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFF4053);
    canvas.drawLine(center, needleEnd, needlePaint);
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
  bool shouldRepaint(_SplashGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: const LinearProgressIndicator(
            minHeight: 5,
            backgroundColor: Color(0xFF173A62),
            color: Color(0xFF43B3FF),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Preparing your dashboard',
          style: TextStyle(
            color: Color(0xFF7F94B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SplashFooter extends StatelessWidget {
  const _SplashFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, color: Color(0xFF35E676), size: 18),
        SizedBox(width: 8),
        Text(
          'Safety first',
          style: TextStyle(
            color: Color(0xFFA8BCE1),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
