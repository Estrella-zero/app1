import 'game_level.dart';

class GameResult {
  const GameResult({
    required this.level,
    required this.score,
    required this.maxCombo,
    required this.hits,
    required this.rounds,
    required this.hp,
    required this.stars,
  });

  final GameLevel level;
  final int score;
  final int maxCombo;
  final int hits;
  final int rounds;
  final int hp;
  final int stars;

  double get accuracy => rounds == 0 ? 0 : hits / rounds;

  String get rating => switch (stars) {
    3 => '完美节奏',
    2 => '表现不错',
    _ => '再来一局',
  };
}
