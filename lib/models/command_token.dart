import 'direction.dart';

/// 一条方向指令；镜像指令显示一个方向，但要求输入相反方向。
class CommandToken {
  CommandToken({required this.direction, this.mirrored = false});

  final Direction direction;
  final bool mirrored;
  bool resolved = false;

  Direction get required => mirrored ? direction.opposite : direction;
}
