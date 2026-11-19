import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../models/game_result.dart';
import '../routes/app_routes.dart';
import '../widgets/palette_switcher.dart';
import '../widgets/press_scale.dart';
import '../widgets/starlight_layer.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.result});

  final GameResult result;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: AppConfig.starPopMs),
  )..forward();

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  void _replay() {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.game,
      arguments: widget.result.level,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: StarlightLayer()),
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final result = widget.result;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const SizedBox(width: 36),
                  const Expanded(
                    child: Text(
                      '本局结算',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 3),
                    ),
                  ),
                  const PaletteButton(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => _buildStar(index, result.stars)),
              ),
              const SizedBox(height: 12),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: Text(
                    result.rating,
                    key: ValueKey<String>(result.rating),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '${result.level.name} · 目标分 ${result.level.targetScore}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    const Text(
                      '得分',
                      style: TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 2),
                    ),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: result.score.toDouble()),
                      duration: const Duration(milliseconds: AppConfig.resultRollMs),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Text(
                        '${value.round()}',
                        style: const TextStyle(
                          fontSize: 46,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _StatTile(label: '最高连击', value: 'x${result.maxCombo}')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      label: '命中率',
                      value: '${(result.accuracy * 100).round()}%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _StatTile(label: '剩余血量', value: '${result.hp}')),
                ],
              ),
              const SizedBox(height: 30),
              PressScale(
                child: FilledButton(onPressed: _replay, child: const Text('再来一局')),
              ),
              const SizedBox(height: 10),
              PressScale(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('返回关卡'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('回到首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStar(int index, int earned) {
    final start = index * 0.16;
    final animation = _entry.drive(
      CurveTween(curve: Interval(start, start + 0.55, curve: Curves.elasticOut)),
    );
    final filled = index < earned;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: ((_entry.value - start) / 0.25).clamp(0.0, 1.0),
        child: Transform.scale(scale: animation.value, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 48,
          color: filled ? AppColors.star : AppColors.muted.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}
