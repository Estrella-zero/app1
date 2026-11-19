import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/tech_palette.dart';

/// 背景色调入口：首页、关卡页、结算页共用。
class PaletteButton extends StatelessWidget {
  const PaletteButton({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '背景色调',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showPaletteSheet(context),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.palette.primary.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: context.palette.primary.withValues(alpha: 0.25),
                blurRadius: 14,
              ),
            ],
          ),
          child: Icon(Icons.palette_outlined, size: size * 0.5, color: AppColors.mint),
        ),
      ),
    );
  }
}

Future<void> showPaletteSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => const _PaletteSheet(),
  );
}

class _PaletteSheet extends StatelessWidget {
  const _PaletteSheet();

  @override
  Widget build(BuildContext context) {
    final current = context.themeController.index;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: context.palette.primary.withValues(alpha: 0.45))),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '背景色调',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 4),
            const Text(
              '切换后封面、关卡、游戏与结算同步更新',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < kTechPalettes.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PaletteTile(palette: kTechPalettes[i], selected: i == current, index: i),
              ),
            const SizedBox(height: 2),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('完成')),
          ],
        ),
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.palette, required this.selected, required this.index});

  final TechPalette palette;
  final bool selected;
  final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => ThemeController.instance.select(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? palette.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? palette.primary.withValues(alpha: 0.75) : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [palette.bgTop, palette.bgBottom]),
                border: Border.all(color: palette.primary.withValues(alpha: 0.8)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                palette.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 20, color: palette.primary)
            else
              const Icon(Icons.circle_outlined, size: 20, color: AppColors.line),
          ],
        ),
      ),
    );
  }
}
