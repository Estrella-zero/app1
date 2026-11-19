import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/tech_palette.dart';

/// 游戏页背景：从底部舞台向外扩散的脉冲波纹，低透明度以免干扰箭头。
class PulseLayer extends StatefulWidget {
  const PulseLayer({super.key});

  @override
  State<PulseLayer> createState() => _PulseLayerState();
}

class _PulseLayerState extends State<PulseLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) => CustomPaint(
          painter: _PulsePainter(
            progress: _pulse.value,
            color: palette.primary,
            glow: palette.glow,
          ),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.color, required this.glow});

  final double progress;
  final Color color;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 1.02);

    // 底部冷光托底，避免去网格后舞台区域发空。
    canvas.drawCircle(
      origin,
      size.width * 0.62,
      Paint()
        ..shader = RadialGradient(
          colors: [glow.withValues(alpha: 0.10), Colors.transparent],
        ).createShader(Rect.fromCircle(center: origin, radius: size.width * 0.62)),
    );

    for (var i = 0; i < 4; i++) {
      final t = (progress + i / 4) % 1;
      final radius = size.height * 0.08 + size.height * 0.95 * t;
      final fade = math.pow(1 - t, 2).toDouble();
      canvas.drawOval(
        Rect.fromCenter(center: origin, width: radius * 2, height: radius * 1.2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color.withValues(alpha: 0.18 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.glow != glow;
}
