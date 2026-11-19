import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_config.dart';

/// 循环动画示例二：单向 repeat 的背景扫描光带，周期与呼吸动画错开。
class ScanBand extends StatefulWidget {
  const ScanBand({super.key});

  @override
  State<ScanBand> createState() => _ScanBandState();
}

class _ScanBandState extends State<ScanBand> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: AppConfig.scanMs),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topLeft,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            return Transform.translate(
              offset: Offset(lerpDouble(-160, 240, t)!, lerpDouble(-160, 900, t)!),
              child: Transform.rotate(angle: -0.35, child: child),
            );
          },
          child: Container(
            width: 240,
            height: 560,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
