import 'package:flutter/material.dart';

import '../models/game_level.dart';

/// Hero 共享元素：关卡卡片与游戏页顶部共用同一个 tag。
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level, this.size = 44});

  final GameLevel level;
  final double size;

  static String tagFor(GameLevel level) => 'level-badge-${level.index}';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: level.accent,
        boxShadow: [
          BoxShadow(
            color: level.accent.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        '${level.index}',
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
