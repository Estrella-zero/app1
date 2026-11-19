import 'package:flutter/material.dart';

import '../core/app_config.dart';

/// 首页 → 关卡选择：淡入 + 轻微上移。
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  FadeSlideRoute({required Widget page, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: AppConfig.routeFadeMs),
        reverseTransitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = animation.drive(CurveTween(curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}

/// 关卡选择 → 游戏：整页缩放穿过，同时让 Hero 徽章飞入。
class ScaleThroughRoute<T> extends PageRouteBuilder<T> {
  ScaleThroughRoute({required Widget page, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: AppConfig.routeScaleMs),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = animation.drive(CurveTween(curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      );
}

/// 游戏 → 结算：从底部滑入。
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  SlideUpRoute({required Widget page, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: AppConfig.routeSlideMs),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = animation.drive(CurveTween(curve: Curves.easeOutQuint));
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.16),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}
