import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../core/score_store.dart';
import '../routes/app_routes.dart';
import '../widgets/mic_cover.dart';
import '../widgets/palette_switcher.dart';
import '../widgets/press_scale.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: AppConfig.homeFadeMs),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Align(alignment: Alignment.centerLeft, child: _CoursePill()),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: ScoreStore.best,
                      builder: (context, best, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '最高分',
                            style: TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: 1),
                          ),
                          Text(
                            '$best',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const PaletteButton(),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  AppConfig.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppConfig.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.muted, letterSpacing: 1),
                ),
                const Expanded(child: MicCover()),
                const SizedBox(height: 8),
                PressScale(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.levels),
                    child: const Text(AppConfig.startLabel),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppConfig.hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoursePill extends StatelessWidget {
  const _CoursePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.mint),
          ),
          const SizedBox(width: 7),
          const Flexible(
            child: Text(
              AppConfig.courseLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
