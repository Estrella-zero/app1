import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Lottie 资源位：现在用原生脉冲占位，接入 lottie 包后替换为 Lottie.asset。
class LottieSlot extends StatefulWidget {
  const LottieSlot({
    super.key,
    this.size = 30,
    this.asset = 'assets/lottie/feedback.json',
  });

  final double size;
  final String asset;

  @override
  State<LottieSlot> createState() => _LottieSlotState();
}

class _LottieSlotState extends State<LottieSlot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 替换示例：
    // return Lottie.asset(widget.asset, repeat: true, fit: BoxFit.contain);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: 1 + 0.12 * sin(_controller.value * pi),
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withValues(alpha: 0.14),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          size: widget.size * 0.55,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
