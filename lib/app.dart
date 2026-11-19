import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/tech_palette.dart';
import 'routes/app_routes.dart';
import 'widgets/tech_backdrop.dart';

class AnimationGameApp extends StatelessWidget {
  const AnimationGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;
    return PaletteScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => MaterialApp(
          title: '方向匹配',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(controller.palette),
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          builder: (context, child) => PhoneShell(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// 手机壳：≤480dp 全屏铺满；更宽时收成 430dp 竖屏居中，两侧用当前配色柔化。
/// 路由、Hero、背景层与弹层都在壳内，桌面宽屏下不会跑到手机画布外。
class PhoneShell extends StatelessWidget {
  const PhoneShell({super.key, required this.child});

  static const _phoneWidth = 430.0;
  static const _wideThreshold = 480.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _wideThreshold) {
          return Stack(
            children: [
              const Positioned.fill(child: TechBackdrop()),
              child,
            ],
          );
        }
        final height = constraints.maxHeight - 24;
        return ColoredBox(
          color: palette.bgBottom,
          child: Stack(
            children: [
              Positioned.fill(child: _DeskBackdrop(palette: palette)),
              Center(
                child: Container(
                  key: const ValueKey('phone-shell'),
                  width: _phoneWidth,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MediaQuery(
                    // 让矮窗口也按手机尺寸进入紧凑布局。
                    data: MediaQuery.of(context).copyWith(
                      size: Size(_phoneWidth, height),
                      padding: EdgeInsets.zero,
                      viewPadding: EdgeInsets.zero,
                      viewInsets: EdgeInsets.zero,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const TechBackdrop(),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 桌面两侧的柔和底色：只保留渐变与两团光晕，避免抢走手机画布注意力。
class _DeskBackdrop extends StatelessWidget {
  const _DeskBackdrop({required this.palette});

  final TechPalette palette;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(palette.bgTop, Colors.black, 0.15)!,
            Color.lerp(palette.bgBottom, Colors.black, 0.35)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -180,
            right: -140,
            child: _glow(420, palette.glow.withValues(alpha: 0.12)),
          ),
          Positioned(
            bottom: -200,
            left: -160,
            child: _glow(460, palette.primary.withValues(alpha: 0.10)),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
}
