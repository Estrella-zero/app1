import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';

/// 血量条：数值与条放在 HUD 区，不进入箭头和窗口指示区域。
class HealthBar extends StatelessWidget {
  const HealthBar({super.key, required this.hp, this.maxHp = AppConfig.maxHp});

  final int hp;
  final int maxHp;

  @override
  Widget build(BuildContext context) {
    final ratio = (hp / maxHp).clamp(0.0, 1.0);
    return Row(
      children: [
        const Icon(Icons.favorite_rounded, size: 15, color: AppColors.danger),
        const SizedBox(width: 7),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(height: 8, color: AppColors.line),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOut,
                    width: constraints.maxWidth * ratio,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$hp/$maxHp',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
      ],
    );
  }
}
