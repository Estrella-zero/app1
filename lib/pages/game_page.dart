import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../core/score_store.dart';
import '../core/tech_palette.dart';
import '../models/direction.dart';
import '../models/game_level.dart';
import '../routes/app_routes.dart';
import '../state/game_session.dart';
import '../widgets/command_block.dart';
import '../widgets/direction_button.dart';
import '../widgets/health_bar.dart';
import '../widgets/level_badge.dart';
import '../widgets/lottie_slot.dart';
import '../widgets/mascot_scene.dart';
import '../widgets/press_scale.dart';
import '../widgets/pulse_layer.dart';
import '../widgets/score_counter.dart';
import '../widgets/window_gauge.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.level});

  final GameLevel level;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late final GameSession _session;
  Offset _drag = Offset.zero;
  bool _navigated = false;
  bool _showPulse = false;

  @override
  void initState() {
    super.initState();
    _session = GameSession(level: widget.level, vsync: this);
    _session.addListener(_onSessionChanged);
    // 首帧先渲染玩法内容，背景脉冲层在下一帧挂载，降低转场首帧开销。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _showPulse = true);
    });
  }

  void _onSessionChanged() {
    if (!_session.isFinished || _navigated) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScoreStore.submit(_session.score);
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.result,
        arguments: _session.toResult(),
      );
    });
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _session.dispose();
    super.dispose();
  }

  String get _feedbackText {
    return switch (_session.feedback) {
      null => '看准箭头，别抢拍',
      RoundFeedback.hit => '命中 +${AppConfig.baseScore}',
      RoundFeedback.wrong => '方向不对',
      RoundFeedback.timeout => '超时',
    };
  }

  Color get _feedbackColor {
    return switch (_session.feedback) {
      null => AppColors.muted,
      RoundFeedback.hit => AppColors.mint,
      RoundFeedback.wrong || RoundFeedback.timeout => AppColors.danger,
    };
  }

  String get _gaugeBadge {
    if (_session.isMirrorRound) return '镜像 · 反着按';
    if (_session.tokens.length > 1) return '复合 · 两个都要按';
    return '单指令';
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    // 矮屏（如 320×568）收紧间距与舞台高度，避免箭头区被挤爆。
    final compact = MediaQuery.sizeOf(context).height < 700;
    return Scaffold(
      body: ListenableBuilder(
        listenable: _session,
        builder: (context, child) => Stack(
          children: [
            if (_showPulse)
              const Positioned.fill(child: RepaintBoundary(child: PulseLayer())),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Column(
                  children: [
                    _buildTopBar(level),
                    SizedBox(height: compact ? 4 : 8),
                    HealthBar(hp: _session.hp),
                    SizedBox(height: compact ? 5 : 10),
                    _buildScoreRow(compact),
                    SizedBox(height: compact ? 4 : 8),
                    WindowGauge(
                      clock: _session.windowClock,
                      windowMs: level.windowMs,
                      badge: _gaugeBadge,
                    ),
                    SizedBox(height: compact ? 4 : 8),
                    Expanded(child: _buildPlayArea()),
                    if (compact)
                      SizedBox(
                        height: 150,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _DirectionPad(onTap: _session.answer),
                        ),
                      )
                    else
                      _DirectionPad(onTap: _session.answer),
                    SizedBox(height: compact ? 0 : 2),
                    MascotScene(
                      attackTick: _session.attackTick,
                      height: compact ? 78 : 100,
                    ),
                  ],
                ),
              ),
            ),
            _buildPauseOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(GameLevel level) {
    return Row(
      children: [
        Tooltip(
          message: '暂停',
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _session.isPaused ? _session.resume : _session.pause,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.palette.primary.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(
                    color: context.palette.primary.withValues(alpha: 0.18),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.pause_rounded, size: 18, color: AppColors.ink),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Hero(
          tag: LevelBadge.tagFor(level),
          child: Material(
            color: Colors.transparent,
            child: LevelBadge(level: level, size: 44),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                '目标分 ${level.targetScore}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        _TotalTimer(clock: _session.totalClock),
      ],
    );
  }

  Widget _buildScoreRow(bool compact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '得分',
              style: TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 1.5),
            ),
            ScoreCounter(
              score: _session.score,
              style: TextStyle(
                fontSize: compact ? 28 : 34,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: _session.combo > 1
              ? _ComboChip(key: ValueKey<int>(_session.combo), combo: _session.combo)
              : const SizedBox(key: ValueKey<String>('combo-empty'), width: 1, height: 1),
        ),
      ],
    );
  }

  Widget _buildPlayArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dual = _session.tokens.length > 1;
        final blockSize = dual
            ? (constraints.maxHeight * 0.42).clamp(48.0, 116.0)
            : (constraints.maxHeight * 0.52).clamp(52.0, 164.0);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) => _drag = Offset.zero,
          onPanUpdate: (details) => _drag += details.delta,
          onPanEnd: (_) {
            final direction = Direction.fromOffset(_drag);
            if (direction != null) _session.answer(direction);
          },
          child: Column(
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _session.windowClock,
                builder: (context, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final token in _session.tokens)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CommandBlock(
                          direction: token.direction,
                          progress: _session.windowProgress,
                          size: blockSize,
                          resolved: token.resolved,
                          mirrored: token.mirrored,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LottieSlot(size: 28),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      _feedbackText,
                      key: ValueKey<String>(_feedbackText),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _feedbackColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !_session.isPaused,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          child: _session.isPaused
              ? _PauseOverlay(
                  key: const ValueKey<String>('pause'),
                  onResume: _session.resume,
                  onRestart: _restart,
                  onExit: _exitToLevels,
                )
              : const SizedBox.shrink(key: ValueKey<String>('playing')),
        ),
      ),
    );
  }

  void _restart() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.game, arguments: widget.level);
  }

  void _exitToLevels() {
    Navigator.of(context).pop();
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        color: Colors.black.withValues(alpha: 0.62),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.94, end: 1),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1F33),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mint.withValues(alpha: 0.14),
                    ),
                    child: const Icon(Icons.pause_rounded, color: AppColors.mint, size: 26),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '已暂停',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '窗口与总计时都已停止',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.white38),
                ),
                const SizedBox(height: 22),
                PressScale(
                  child: FilledButton(
                    onPressed: onResume,
                    child: const Text('继续游戏'),
                  ),
                ),
                const SizedBox(height: 10),
                PressScale(
                  child: OutlinedButton(
                    onPressed: onRestart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    child: const Text('重开本局'),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: onExit,
                  child: const Text('返回关卡选择'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TotalTimer extends StatelessWidget {
  const _TotalTimer({required this.clock});

  final Animation<double> clock;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: clock,
      builder: (context, child) {
        final remaining = ((1 - clock.value) * AppConfig.totalSeconds).ceil();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.mint.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: AppColors.mint.withValues(alpha: 0.16),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: AppColors.mint),
              const SizedBox(width: 5),
              Text(
                '总计时 ${remaining}s',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ComboChip extends StatelessWidget {
  const _ComboChip({super.key, required this.combo});

  final int combo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'COMBO x$combo',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.mint,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DirectionPad extends StatelessWidget {
  const _DirectionPad({required this.onTap});

  final ValueChanged<Direction> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DirectionButton(direction: Direction.up, onTap: () => onTap(Direction.up)),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DirectionButton(direction: Direction.left, onTap: () => onTap(Direction.left)),
            const SizedBox(width: 74),
            DirectionButton(direction: Direction.right, onTap: () => onTap(Direction.right)),
          ],
        ),
        const SizedBox(height: 8),
        DirectionButton(direction: Direction.down, onTap: () => onTap(Direction.down)),
      ],
    );
  }
}
