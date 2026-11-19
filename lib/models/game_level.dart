import 'package:flutter/material.dart';

/// 关卡参数表：页面不按关卡编号写分支，差异全部来自这里。
class GameLevel {
  const GameLevel({
    required this.index,
    required this.name,
    required this.subtitle,
    required this.windowMs,
    required this.targetScore,
    required this.accent,
    this.dualCommand = false,
    this.mirrorEvery,
  });

  final int index;
  final String name;
  final String subtitle;
  final int windowMs;
  final int targetScore;
  final Color accent;
  final bool dualCommand;
  final int? mirrorEvery;

  Duration get window => Duration(milliseconds: windowMs);
}

const kGameLevels = <GameLevel>[
  GameLevel(
    index: 1,
    name: '第一关',
    subtitle: '单指令 · 慢节奏',
    windowMs: 1800,
    targetScore: 2400,
    accent: Color(0xFF37BFA6),
  ),
  GameLevel(
    index: 2,
    name: '第二关',
    subtitle: '复合指令 · 两个方向',
    windowMs: 1700,
    targetScore: 3200,
    accent: Color(0xFFFFA94D),
    dualCommand: true,
  ),
  GameLevel(
    index: 3,
    name: '第三关',
    subtitle: '复合 + 每 6 条镜像',
    windowMs: 1500,
    targetScore: 4000,
    accent: Color(0xFFE4576B),
    dualCommand: true,
    mirrorEvery: 6,
  ),
];
