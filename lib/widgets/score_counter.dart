import 'package:flutter/material.dart';

import '../core/app_config.dart';

/// 数字滚动：TweenAnimationBuilder 把分数用 double 插值后再取整。
class ScoreCounter extends StatelessWidget {
  const ScoreCounter({super.key, required this.score, this.style});

  final int score;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: AppConfig.scoreRollMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Text('${value.round()}', style: style),
    );
  }
}
