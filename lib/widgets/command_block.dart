import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/tech_palette.dart';
import '../models/direction.dart';

/// 指令块只负责箭头，倒计时交给独立的 WindowGauge，避免同屏叠在一起。
class CommandBlock extends StatelessWidget {
  const CommandBlock({
    super.key,
    required this.direction,
    required this.progress,
    required this.size,
    this.resolved = false,
    this.mirrored = false,
  });

  final Direction direction;
  final double progress;
  final double size;
  final bool resolved;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    // 这里换成你的具体玩法：把方块换成角色、音符或地鼠等图形。
    final appear = Curves.easeOutBack.transform((progress / 0.22).clamp(0.0, 1.0));
    final scale = Tween<double>(begin: 0.55, end: 1).transform(appear);
    final urgency = Curves.easeIn.transform(((progress - 0.7) / 0.3).clamp(0.0, 1.0));
    final tint = Color.lerp(context.palette.primary, AppColors.danger, urgency)!;

    return AnimatedOpacity(
      opacity: resolved ? 0.35 : 1,
      duration: const Duration(milliseconds: 240),
      child: Transform.scale(
        scale: resolved ? scale * 0.94 : scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tint, Color.lerp(tint, AppColors.background, 0.45)!],
            ),
            border: mirrored ? Border.all(color: AppColors.accent, width: 3) : null,
            boxShadow: [
              BoxShadow(
                color: tint.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(direction.icon, size: size * 0.46, color: Colors.white),
              if (resolved)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Icon(Icons.check_circle_rounded, size: size * 0.2, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
