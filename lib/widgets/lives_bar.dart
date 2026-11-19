import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// 生命值：AnimatedContainer 随剩余生命自动过渡尺寸与颜色。
class LivesBar extends StatelessWidget {
  const LivesBar({super.key, required this.lives, this.total = 3});

  final int lives;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final alive = index < lives;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            width: alive ? 14 : 9,
            height: alive ? 14 : 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: alive ? AppColors.danger : AppColors.ink.withValues(alpha: 0.12),
            ),
          ),
        );
      }),
    );
  }
}
