import 'package:flutter/material.dart';

import '../core/tech_palette.dart';
import 'scan_band.dart';

/// 全局背景：渐变底色、斜向主光、三团光晕、扫描带与暗角，页面自身保持透明。
class TechBackdrop extends StatelessWidget {
  const TechBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.bgTop, palette.bgBottom],
            ),
          ),
        ),
        // 斜向主光：让双色渐变有纵深，替代原来的网格。
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, 0.45, 1],
              colors: [
                palette.primary.withValues(alpha: 0.10),
                Colors.transparent,
                palette.glow.withValues(alpha: 0.08),
              ],
            ),
          ),
        ),
        Positioned(
          top: -150,
          right: -110,
          child: _Glow(size: 380, color: palette.glow.withValues(alpha: 0.30)),
        ),
        Positioned(
          bottom: -170,
          left: -120,
          child: _Glow(size: 400, color: palette.primary.withValues(alpha: 0.20)),
        ),
        Positioned(
          top: 210,
          left: -210,
          child: _Glow(size: 430, color: palette.primary.withValues(alpha: 0.10)),
        ),
        const Positioned.fill(child: ScanBand()),
        // 底部压暗，保证方向键与舞台区域始终有对比。
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0, 0.4],
                colors: [Colors.black.withValues(alpha: 0.30), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.3,
                stops: const [0.5, 1],
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.40)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
