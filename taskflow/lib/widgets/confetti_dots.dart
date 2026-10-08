import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ConfettiDots extends StatefulWidget {
  const ConfettiDots({super.key});

  @override
  State<ConfettiDots> createState() => _ConfettiDotsState();
}

class _ConfettiDotsState extends State<ConfettiDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _dots = [
    _Dot(x: 0.1, y: 0.1, r: 6, color: AppColors.orange, phase: 0),
    _Dot(x: 0.85, y: 0.08, r: 4, color: AppColors.amber, phase: 0.5),
    _Dot(x: 0.9, y: 0.55, r: 5, color: AppColors.primary, phase: 1.0),
    _Dot(x: 0.15, y: 0.7, r: 3, color: AppColors.green, phase: 1.5),
    _Dot(x: 0.75, y: 0.2, r: 3, color: AppColors.primaryLight, phase: 2.0),
    _Dot(x: 0.25, y: 0.3, r: 4, color: AppColors.textSecondary, phase: 0.8),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => CustomPaint(
        painter: _DotsPainter(_ctrl.value, _dots),
        size: Size.infinite,
      ),
    );
  }
}

class _Dot {
  const _Dot({
    required this.x,
    required this.y,
    required this.r,
    required this.color,
    required this.phase,
  });

  final double x;
  final double y;
  final double r;
  final Color color;
  final double phase;
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter(this.t, this.dots);

  final double t;
  final List<_Dot> dots;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final d in dots) {
      final offset = sin((t * 2 * pi) + d.phase) * 6;
      paint.color = d.color.withValues(alpha: 0.7);
      canvas.drawCircle(
        Offset(size.width * d.x, size.height * d.y + offset),
        d.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.t != t;
}
