import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/tech_palette.dart';
import 'standing_mic.dart';

/// 首页封面：标题之后居中一支立式麦克风，音符按远近分层上浮，四周留白。
class MicCover extends StatefulWidget {
  const MicCover({super.key});

  @override
  State<MicCover> createState() => _MicCoverState();
}

class _MicCoverState extends State<MicCover> with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  // 后排音符小、淡，先绘制以便被麦身自然遮挡；前排音符大、亮，带柔光。
  static const _notes = <_Note>[
    _Note(-0.50, -0.28, 13, 0.10, Color(0x99A4AEC9), front: false),
    _Note(0.50, -0.14, 15, 0.42, Color(0x7FA4AEC9), front: false),
    _Note(-0.28, 0.30, 12, 0.70, Color(0x7FA4AEC9), front: false),
    _Note(-0.52, 0.06, 30, 0.22, AppColors.mint, front: true),
    _Note(0.48, -0.36, 24, 0.55, AppColors.accent, front: true),
    _Note(0.40, 0.34, 32, 0.84, AppColors.mint, front: true),
    _Note(-0.16, -0.50, 19, 0.03, AppColors.accent, front: true),
  ];

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth * 0.82, constraints.maxHeight * 0.74)
            .clamp(168.0, 292.0)
            .toDouble();
        return Center(
          child: SizedBox(
            width: constraints.maxWidth,
            height: side * 1.3,
            child: AnimatedBuilder(
              animation: _loop,
              builder: (context, child) {
                final float = sin(_loop.value * 2 * pi) * 5;
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: side * 1.18,
                      height: side * 1.18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            palette.primary.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.72],
                        ),
                      ),
                    ),
                    for (final note in _notes)
                      if (!note.front) _buildNote(note, side),
                    Transform.translate(
                      offset: Offset(0, float),
                      child: StandingMic(size: side),
                    ),
                    for (final note in _notes)
                      if (note.front) _buildNote(note, side),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildNote(_Note note, double side) {
    final t = (_loop.value + note.phase) % 1;
    final rise = side * 0.14 * Curves.easeOut.transform(t);
    final sway = sin((t + note.phase) * 2 * pi) * side * 0.015;
    final opacity = (sin(t * pi) * (note.front ? 0.95 : 0.55)).clamp(0.0, 1.0);
    return Transform.translate(
      offset: Offset(side * note.dx + sway, side * note.dy - rise),
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: sin((t + note.phase) * 2 * pi) * 0.18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (note.front)
                Container(
                  width: note.size * 1.9,
                  height: note.size * 1.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [note.color.withValues(alpha: 0.18), Colors.transparent],
                    ),
                  ),
                ),
              Icon(Icons.music_note_rounded, size: note.size, color: note.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _Note {
  const _Note(this.dx, this.dy, this.size, this.phase, this.color, {required this.front});

  final double dx;
  final double dy;
  final double size;
  final double phase;
  final Color color;
  final bool front;
}
