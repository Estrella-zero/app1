import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/direction.dart';

/// 方向键：霓虹描边 + 按下放大回弹，Transform 不影响布局。
class DirectionButton extends StatefulWidget {
  const DirectionButton({super.key, required this.direction, required this.onTap});

  final Direction direction;
  final VoidCallback onTap;

  @override
  State<DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<DirectionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 1.08 : 1,
      duration: Duration(milliseconds: _pressed ? 120 : 260),
      curve: _pressed ? Curves.easeOut : Curves.elasticOut,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) {
          _setPressed(false);
          widget.onTap();
        },
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.mint.withValues(alpha: 0.6), width: 1.4),
            boxShadow: [
              BoxShadow(color: AppColors.mint.withValues(alpha: 0.22), blurRadius: 18),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(widget.direction.icon, color: AppColors.ink, size: 28),
        ),
      ),
    );
  }
}
