import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/tech_palette.dart';

/// 关卡选择页背景：两组倾斜轨道环，光点沿环缓慢运行。
class OrbitLayer extends StatefulWidget {
  const OrbitLayer({super.key});

  @override
  State<OrbitLayer> createState() => _OrbitLayerState();
}

class _OrbitLayerState extends State<OrbitLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _spin,
        builder: (context, child) => CustomPaint(
          painter: _OrbitPainter(
            progress: _spin.value,
            ringColor: palette.primary,
            dotColor: palette.glow,
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.progress, required this.ringColor, required this.dotColor});

  final double progress;
  final Color ringColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final base = math.min(size.width, size.height);
    _paintGroup(
      canvas,
      Offset(size.width * 0.90, size.height * 0.12),
      base,
      const [0.30, 0.48, 0.66, 0.86],
      1,
    );
    _paintGroup(
      canvas,
      Offset(size.width * 0.08, size.height * 0.90),
      base,
      const [0.24, 0.42],
      -1,
    );
  }

  /// 每组环压扁并倾斜，形成轨道透视；光点沿椭圆运动。
  void _paintGroup(Canvas canvas, Offset center, double base, List<double> radii, int direction) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.38 * direction);
    for (var i = 0; i < radii.length; i++) {
      final r = base * radii[i];
      final rect = Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 0.72);
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = ringColor.withValues(alpha: 0.16),
      );
      final angle = progress * 2 * math.pi * direction + i * 1.15;
      final dot = Offset(math.cos(angle) * r, math.sin(angle) * r * 0.36);
      canvas.drawCircle(dot, 5, Paint()..color = ringColor.withValues(alpha: 0.14));
      canvas.drawCircle(dot, 2.2, Paint()..color = dotColor.withValues(alpha: 0.75));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.dotColor != dotColor;
}
