import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../models/game_level.dart';
import '../routes/app_routes.dart';
import '../widgets/level_card.dart';
import '../widgets/orbit_layer.dart';
import '../widgets/palette_switcher.dart';

class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({super.key});

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: AppConfig.cardEntryMs),
  )..forward();

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  void _openLevel(GameLevel level) {
    Navigator.of(context).pushNamed(AppRoutes.game, arguments: level);
  }

  /// 卡片错峰入场：同一控制器配 Interval 曲线。
  Widget _staggered(int index, Widget child) {
    final start = index * 0.12;
    final animation = _entry.drive(
      CurveTween(curve: Interval(start, start + 0.55, curve: Curves.easeOutCubic)),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, card) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - animation.value)),
          child: card,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: OrbitLayer()),
        Scaffold(
          appBar: AppBar(
            title: const Text('选择关卡'),
            actions: const [PaletteButton(), SizedBox(width: 12)],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                Text('挑一关开始', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '每关 ${AppConfig.roundsPerLevel} 次指令、${AppConfig.maxHp} 点血量；窗口越短，节奏越快。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                ...List.generate(kGameLevels.length, (index) {
                  final level = kGameLevels[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _staggered(
                      index,
                      LevelCard(level: level, onTap: () => _openLevel(level)),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text(
                  '扩展位：卡片可按解锁状态置灰，或增加第四关。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
