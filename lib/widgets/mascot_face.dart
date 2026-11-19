import 'package:flutter/material.dart';

/// 最早版配色：深色身体 + 白色脸盘 + 粉色腮红，待机与受击动画不变。
class MascotFace extends StatelessWidget {
  const MascotFace({
    super.key,
    this.size = 96,
    this.color = const Color(0xFF1B2236),
    this.featureColor = const Color(0xFF1B2236),
    this.accent = const Color(0xFFF2B3AC),
  });

  final double size;
  final Color color;
  final Color featureColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MascotPainter(color: color, featureColor: featureColor, accent: accent),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter({
    required this.color,
    required this.featureColor,
    required this.accent,
  });

  final Color color;
  final Color featureColor;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Paint()..color = color;
    final paper = Paint()..color = Colors.white;
    final feature = Paint()..color = featureColor;
    final blush = Paint()..color = accent.withValues(alpha: 0.35);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.13, h * 0.30), width: w * 0.34, height: h * 0.46),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.87, h * 0.30), width: w * 0.34, height: h * 0.46),
      body,
    );

    canvas.drawCircle(Offset(w * 0.5, h * 0.56), w * 0.34, body);
    canvas.drawCircle(Offset(w * 0.5, h * 0.58), w * 0.26, paper);

    canvas.drawCircle(Offset(w * 0.42, h * 0.54), w * 0.035, feature);
    canvas.drawCircle(Offset(w * 0.58, h * 0.54), w * 0.035, feature);
    canvas.drawCircle(Offset(w * 0.34, h * 0.63), w * 0.045, blush);
    canvas.drawCircle(Offset(w * 0.66, h * 0.63), w * 0.045, blush);

    final smile = Paint()
      ..color = featureColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.60), width: w * 0.2, height: h * 0.14),
      0.2,
      2.74,
      false,
      smile,
    );
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.featureColor != featureColor ||
      oldDelegate.accent != accent;
}
