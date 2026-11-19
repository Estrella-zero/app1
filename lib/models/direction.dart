import 'package:flutter/material.dart';

enum Direction {
  up(Icons.arrow_upward_rounded, '上'),
  right(Icons.arrow_forward_rounded, '右'),
  down(Icons.arrow_downward_rounded, '下'),
  left(Icons.arrow_back_rounded, '左');

  const Direction(this.icon, this.label);

  final IconData icon;
  final String label;

  /// 方向单位向量，指令块飞出/下坠时可直接用于位移插值。
  Offset get vector => switch (this) {
    Direction.up => const Offset(0, -1),
    Direction.right => const Offset(1, 0),
    Direction.down => const Offset(0, 1),
    Direction.left => const Offset(-1, 0),
  };

  Direction get opposite => switch (this) {
    Direction.up => Direction.down,
    Direction.down => Direction.up,
    Direction.left => Direction.right,
    Direction.right => Direction.left,
  };

  /// 把滑动位移换算为方向：小于阈值或主轴占比不足 60% 视为无效输入。
  static Direction? fromOffset(Offset delta, {double minDistance = 48}) {
    if (delta.distance < minDistance) return null;
    final horizontal = delta.dx.abs() >= delta.dy.abs();
    final major = horizontal ? delta.dx.abs() : delta.dy.abs();
    if (major < delta.distance * 0.6) return null;
    if (horizontal) return delta.dx > 0 ? Direction.right : Direction.left;
    return delta.dy > 0 ? Direction.down : Direction.up;
  }
}
