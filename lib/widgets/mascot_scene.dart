import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import 'mascot_face.dart';
import 'standing_mic.dart';

/// 页面底部舞台：小人待机呼吸，失误时由右侧立式麦克风发射音符并触发受击抖动。
class MascotScene extends StatefulWidget {
  const MascotScene({super.key, required this.attackTick, this.height = 100});

  final int attackTick;
  final double height;

  @override
  State<MascotScene> createState() => _MascotSceneState();
}

class _MascotSceneState extends State<MascotScene> with TickerProviderStateMixin {
  static const _mascotSize = 62.0;
  static const _micSize = 82.0;

  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: AppConfig.mascotIdleMs),
  )..repeat(reverse: true);

  late final AnimationController _attack = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: AppConfig.attackMs),
  );

  @override
  void didUpdateWidget(covariant MascotScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.attackTick != oldWidget.attackTick) _attack.forward(from: 0);
  }

  @override
  void dispose() {
    _idle.dispose();
    _attack.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = widget.height;
          // 矮屏舞台收紧时同步缩小立麦，避免立麦顶端探出舞台压到方向键。
          final micSize = h < 90 ? h * 0.76 : _micSize;
          final mascotCenter = Offset(16 + _mascotSize / 2, h - 10 - _mascotSize / 2);
          final micCenter = Offset(w - 10 - micSize / 2, h - 6 - micSize * 0.79);

          return AnimatedBuilder(
            animation: Listenable.merge([_idle, _attack]),
            builder: (context, child) {
              final t = _attack.value;
              final bob = lerpDouble(0, -4, _idle.value)!;
              final noteT = (t / 0.72).clamp(0.0, 1.0);
              final flying = t > 0 && noteT < 1;
              final notePos = Offset.lerp(
                    micCenter,
                    mascotCenter,
                    Curves.easeIn.transform(noteT),
                  )! +
                  Offset(0, -18 * sin(pi * noteT));
              final hitT = ((t - 0.6) / 0.4).clamp(0.0, 1.0);
              final shake = sin(hitT * pi * 6) * 4 * (1 - hitT);
              final flash = hitT > 0 ? sin(hitT * pi * 5).abs() * (1 - hitT) * 0.9 : 0.0;

              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 6,
                    child: Container(height: 2, color: AppColors.line),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 10 + bob,
                    child: Transform.rotate(
                      angle: shake * 0.03,
                      child: Transform.translate(
                        offset: Offset(shake, 0),
                        child: SizedBox(
                          width: _mascotSize,
                          height: _mascotSize,
                          child: Stack(
                            children: [
                              const MascotFace(size: _mascotSize),
                              if (flash > 0)
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: flash,
                                    child: const ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        AppColors.danger,
                                        BlendMode.srcIn,
                                      ),
                                      child: MascotFace(size: _mascotSize),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 6,
                    child: Transform.scale(
                      scale: 1 + _idle.value * 0.02,
                      alignment: Alignment.bottomCenter,
                      child: StandingMic(size: micSize, compact: true),
                    ),
                  ),
                  if (flying)
                    Positioned(
                      left: notePos.dx - 10,
                      top: notePos.dy - 10,
                      child: Transform.rotate(
                        angle: noteT * 1.4,
                        child: const Icon(
                          Icons.music_note_rounded,
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
