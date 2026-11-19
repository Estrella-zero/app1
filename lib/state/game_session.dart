import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../core/app_config.dart';
import '../models/command_token.dart';
import '../models/direction.dart';
import '../models/game_level.dart';
import '../models/game_result.dart';

enum RoundFeedback {
  hit,
  wrong,
  timeout;

  String get label => switch (this) {
    RoundFeedback.hit => '命中',
    RoundFeedback.wrong => '方向错误',
    RoundFeedback.timeout => '超时',
  };
}

/// 一局游戏有两套时钟：单条指令窗口 + 60 秒总计时，两者互不复用。
class GameSession extends ChangeNotifier {
  GameSession({required this.level, required TickerProvider vsync})
    : _windowClock = AnimationController(vsync: vsync, duration: level.window),
      _totalClock = AnimationController(
        vsync: vsync,
        duration: const Duration(seconds: AppConfig.totalSeconds),
      ) {
    _windowClock.addStatusListener(_onWindowStatus);
    _totalClock.addStatusListener(_onTotalStatus);
    _totalClock.forward();
    _beginRound();
  }

  final GameLevel level;
  final AnimationController _windowClock;
  final AnimationController _totalClock;
  final Random _random = Random();
  Timer? _nextRoundTimer;

  Animation<double> get windowClock => _windowClock;
  Animation<double> get totalClock => _totalClock;
  double get windowProgress => _windowClock.value;

  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int hp = AppConfig.maxHp;
  int round = 0;
  int hits = 0;
  int attackTick = 0;
  List<CommandToken> tokens = const [];
  RoundFeedback? feedback;

  bool _locked = false;
  bool _finished = false;
  bool _paused = false;

  bool get isFinished => _finished;
  bool get isPaused => _paused;
  int get totalRounds => AppConfig.roundsPerLevel;
  bool get isMirrorRound => tokens.any((token) => token.mirrored);

  void answer(Direction input) {
    if (_paused || _locked || _finished) return;
    CommandToken? target;
    for (final token in tokens) {
      if (!token.resolved && token.required == input) {
        target = token;
        break;
      }
    }
    if (target == null) {
      _judge(false);
      return;
    }
    target.resolved = true;
    if (tokens.every((token) => token.resolved)) {
      _judge(true);
    } else {
      notifyListeners();
    }
  }

  void _beginRound() {
    if (_paused || _finished) return;
    if (round >= totalRounds) {
      _finish();
      return;
    }
    round++;
    tokens = _buildTokens();
    feedback = null;
    _locked = false;
    _windowClock.forward(from: 0);
    notifyListeners();
  }

  /// 这里换成你的具体玩法：复合指令两个方向，镜像指令单独出现且要求反着按。
  List<CommandToken> _buildTokens() {
    final mirror = level.mirrorEvery != null && round % level.mirrorEvery! == 0;
    if (mirror) {
      return [CommandToken(direction: _randomDirection(), mirrored: true)];
    }
    if (!level.dualCommand) return [CommandToken(direction: _randomDirection())];
    final first = _randomDirection();
    Direction second;
    do {
      second = _randomDirection();
    } while (second == first);
    return [CommandToken(direction: first), CommandToken(direction: second)];
  }

  Direction _randomDirection() =>
      Direction.values[_random.nextInt(Direction.values.length)];

  void _onWindowStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_locked) {
      _judge(false, timedOut: true);
    }
  }

  void _onTotalStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _finish();
  }

  void _judge(bool correct, {bool timedOut = false}) {
    if (_locked || _finished) return;
    _locked = true;
    _windowClock.stop();
    feedback = timedOut
        ? RoundFeedback.timeout
        : (correct ? RoundFeedback.hit : RoundFeedback.wrong);
    if (correct) {
      combo++;
      maxCombo = max(maxCombo, combo);
      score += AppConfig.baseScore +
          min(combo, AppConfig.comboBonusCap) * AppConfig.comboBonusStep;
      hits++;
    } else {
      combo = 0;
      hp = max(0, hp - AppConfig.hpPerMiss);
      attackTick++;
    }
    notifyListeners();
    _scheduleNextRound();
  }

  /// 判定后的短暂停顿；暂停时会被取消，恢复后重新排期。
  void _scheduleNextRound() {
    _nextRoundTimer?.cancel();
    _nextRoundTimer = Timer(const Duration(milliseconds: AppConfig.feedbackHoldMs), () {
      if (_paused || _finished) return;
      if (hp <= 0) {
        _finish();
      } else {
        _beginRound();
      }
    });
  }

  /// 暂停：两套时钟与下一轮计时器全部停住。
  void pause() {
    if (_paused || _finished) return;
    _paused = true;
    _windowClock.stop();
    _totalClock.stop();
    _nextRoundTimer?.cancel();
    notifyListeners();
  }

  /// 恢复：窗口从当前进度继续，总计时继续走。
  void resume() {
    if (!_paused || _finished) return;
    _paused = false;
    _totalClock.forward();
    if (_locked) {
      _scheduleNextRound();
    } else {
      _windowClock.forward();
    }
    notifyListeners();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _nextRoundTimer?.cancel();
    _windowClock.stop();
    _totalClock.stop();
    notifyListeners();
  }

  GameResult toResult() {
    final ratio = score / level.targetScore;
    return GameResult(
      level: level,
      score: score,
      maxCombo: maxCombo,
      hits: hits,
      rounds: round,
      hp: hp,
      stars: ratio >= 1 ? 3 : (ratio >= 0.6 ? 2 : 1),
    );
  }

  @override
  void dispose() {
    _nextRoundTimer?.cancel();
    _windowClock.removeStatusListener(_onWindowStatus);
    _totalClock.removeStatusListener(_onTotalStatus);
    _windowClock.dispose();
    _totalClock.dispose();
    super.dispose();
  }
}
