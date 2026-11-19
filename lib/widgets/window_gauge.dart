import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/tech_palette.dart';

/// 单条指令的窗口指示：独立面板，放在箭头区域上方，不与箭头重叠。
class WindowGauge extends StatelessWidget {
  const WindowGauge({
    super.key,
    required this.clock,
    required this.windowMs,
    this.badge,
  });

  final Animation<double> clock;
  final int windowMs;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final primary = context.palette.primary;
    return AnimatedBuilder(
      animation: clock,
      builder: (context, child) {
        final remaining = windowMs * (1 - clock.value);
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primary.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    '本指令窗口',
                    style: TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: 1.2),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${(remaining / 1000).toStringAsFixed(1)}s',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (1 - clock.value).clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: AppColors.line,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
