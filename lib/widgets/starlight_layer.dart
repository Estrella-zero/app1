import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/tech_palette.dart';

/// 结算页背景：星点缓慢闪烁，底部升起三道光柱。
class StarlightLayer extends StatefulWidget {
  const StarlightLayer({super.key});

  @override
  State<StarlightLayer> createState() => _StarlightLayerState();
}

class _StarlightLayerState extends State<StarlightLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  final List<_Star> _stars = _buildStars();

  static List<_Star> _buildStars() {
    final random = math.Random(11);
    return List.generate(32, (_) {
      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 0.7 + random.nextDouble() * 1.4,
        phase: random.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _twinkle,
        builder: (context, child) => CustomPaint(
          painter: _StarlightPainter(
            progress: _twinkle.value,
            stars: _stars,
            beamColor: palette.primary,
            glowColor: palette.glow,
          ),
        ),
      ),
    );
  }
}

class _Star {
  const _Star({required this.x, required this.y, required this.radius, required this.phase});

  final double x;
  final double y;
  final double radius;
  final double phase;
}

class _StarlightPainter extends CustomPainter {
  _StarlightPainter({
    required this.progress,
    required this.stars,
    required this.beamColor,
    required this.glowColor,
  });

  final double progress;
  final List<_Star> stars;
  final Color beamColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 光柱：自底部向上渐隐，宽度错落。
    const positions = [0.16, 0.50, 0.84];
    const widths = [76.0, 124.0, 64.0];
    for (var i = 0; i < positions.length; i++) {
      final rect = Rect.fromLTWH(
        size.width * positions[i] - widths[i] / 2,
        size.height * 0.16,
        widths[i],
        size.height * 0.84,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [beamColor.withValues(alpha: 0.14), Colors.transparent],
          ).createShader(rect),
      );
    }

    for (final star in stars) {
      final twinkle = 0.5 + 0.5 * math.sin(progress * 2 * math.pi + star.phase);
      final center = Offset(size.width * star.x, size.height * star.y);
      canvas.drawCircle(
        center,
        star.radius,
        Paint()..color = Colors.white.withValues(alpha: 0.18 + 0.34 * twinkle),
      );
      if (star.radius > 1.5) {
        canvas.drawCircle(
          center,
          star.radius * 3,
          Paint()..color = glowColor.withValues(alpha: 0.10 * twinkle),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarlightPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.beamColor != beamColor ||
      oldDelegate.glowColor != glowColor;
}
