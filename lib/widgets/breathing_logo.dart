import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import 'mascot_face.dart';

/// 循环动画示例一：AnimationController.repeat(reverse: true) 驱动标志呼吸。
class BreathingLogo extends StatefulWidget {
  const BreathingLogo({super.key, this.size = 124});

  final double size;

  @override
  State<BreathingLogo> createState() => _BreathingLogoState();
}

class _BreathingLogoState extends State<BreathingLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: AppConfig.breathMs),
  )..repeat(reverse: true);

  late final Animation<double> _breath = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        final scale = lerpDouble(0.94, 1.04, _breath.value)!;
        final glow = lerpDouble(0.14, 0.30, _breath.value)!;
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.all(widget.size * 0.12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: glow),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: MascotFace(size: widget.size),
    );
  }
}
