import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// 立式麦克风：三脚支架 + 底座 + 金属杆，封面与游戏舞台共用同一套绘制。
class StandingMic extends StatelessWidget {
  const StandingMic({super.key, this.size = 300, this.compact = false});

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: StandingMicPainter(compact: compact)),
    );
  }
}

class StandingMicPainter extends CustomPainter {
  const StandingMicPainter({this.compact = false});

  final bool compact;

  static const _silver = Color(0xFFD7DBE8);
  static const _metalDark = Color(0xFF3A3F58);
  static const _bodyDark = Color(0xFF202436);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.965), width: w * 0.66, height: h * 0.024),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // 三脚支架与底座
    final hub = Offset(cx, h * 0.80);
    final legPaint = Paint()
      ..color = _metalDark
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;
    for (final foot in [
      Offset(cx - w * 0.26, h * 0.95),
      Offset(cx + w * 0.26, h * 0.95),
      Offset(cx, h * 0.935),
    ]) {
      canvas.drawLine(hub, foot, legPaint);
      canvas.drawCircle(foot, w * 0.016, Paint()..color = _silver.withValues(alpha: 0.5));
    }
    canvas.drawOval(
      Rect.fromCenter(center: hub, width: w * 0.18, height: h * 0.03),
      Paint()..color = _metalDark,
    );

    // 金属立杆
    final poleRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - w * 0.022, h * 0.34, cx + w * 0.022, h * 0.805),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(
      poleRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [_metalDark, _silver, Colors.white, _silver, _metalDark],
          stops: [0, 0.25, 0.45, 0.72, 1],
        ).createShader(poleRect.outerRect),
    );

    // 托架
    final yokePaint = Paint()
      ..color = _silver.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.016
      ..strokeCap = StrokeCap.round;
    final yoke = Path()
      ..moveTo(cx - w * 0.20, h * 0.335)
      ..quadraticBezierTo(cx - w * 0.20, h * 0.215, cx - w * 0.15, h * 0.215)
      ..moveTo(cx + w * 0.20, h * 0.335)
      ..quadraticBezierTo(cx + w * 0.20, h * 0.215, cx + w * 0.15, h * 0.215);
    canvas.drawPath(yoke, yokePaint);
    if (!compact) {
      canvas.drawCircle(Offset(cx - w * 0.20, h * 0.335), w * 0.022, Paint()..color = _silver);
      canvas.drawCircle(Offset(cx + w * 0.20, h * 0.335), w * 0.022, Paint()..color = _silver);
    }

    // 麦克风主体
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.21), width: w * 0.30, height: h * 0.26),
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(body, Paint()..color = _bodyDark);
    canvas.drawRRect(
      body,
      Paint()
        ..color = _silver.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );

    // 网罩
    final grille = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.185), width: w * 0.24, height: h * 0.155),
      Radius.circular(w * 0.12),
    );
    canvas.save();
    canvas.clipRRect(grille);
    canvas.drawRRect(grille, Paint()..color = Colors.white.withValues(alpha: 0.10));
    final linePaint = Paint()
      ..color = _silver.withValues(alpha: 0.35)
      ..strokeWidth = w * 0.006;
    for (double y = grille.outerRect.top + h * 0.015; y < grille.outerRect.bottom; y += h * 0.02) {
      canvas.drawLine(
        Offset(grille.outerRect.left + w * 0.012, y),
        Offset(grille.outerRect.right - w * 0.012, y),
        linePaint,
      );
    }
    canvas.restore();
    canvas.drawArc(
      grille.outerRect.deflate(w * 0.01),
      -2.3,
      1.2,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.008
        ..strokeCap = StrokeCap.round,
    );

    // 底部饰环
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.325), width: w * 0.27, height: h * 0.016),
        Radius.circular(w * 0.01),
      ),
      Paint()..color = AppColors.mint,
    );

    if (compact) return;

    // 防喷罩与鹅颈
    final filterCenter = Offset(cx - w * 0.34, h * 0.16);
    final filterRadius = w * 0.10;
    final neck = Path()
      ..moveTo(cx - w * 0.145, h * 0.22)
      ..quadraticBezierTo(cx - w * 0.30, h * 0.27, filterCenter.dx, filterCenter.dy + filterRadius * 0.8);
    canvas.drawPath(
      neck,
      Paint()
        ..color = _silver.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(filterCenter, filterRadius, Paint()..color = AppColors.mint.withValues(alpha: 0.08));
    canvas.drawCircle(
      filterCenter,
      filterRadius,
      Paint()
        ..color = _silver.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );
    canvas.drawCircle(
      filterCenter,
      filterRadius * 0.72,
      Paint()
        ..color = _silver.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.006,
    );
  }

  @override
  bool shouldRepaint(covariant StandingMicPainter oldDelegate) =>
      oldDelegate.compact != compact;
}
