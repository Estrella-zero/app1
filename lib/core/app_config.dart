/// 文案与节奏参数集中在此，调手感只改这一个文件。
class AppConfig {
  const AppConfig._();

  // 文案
  static const appName = '方向匹配';
  static const courseLabel = '移动软件开发 · Flutter 动画实践';
  static const tagline = '看准方向，滑出节奏';
  static const startLabel = '开始游戏';
  static const hint = '竖屏体验 · 支持四向滑动与点击';

  // 玩法节奏
  static const totalSeconds = 60;
  static const roundsPerLevel = 36;
  static const maxHp = 100;
  static const hpPerMiss = 10;
  static const feedbackHoldMs = 650;
  static const baseScore = 100;
  static const comboBonusCap = 10;
  static const comboBonusStep = 10;

  // 动画时长（毫秒）
  static const routeFadeMs = 560;
  static const routeScaleMs = 300;
  static const routeSlideMs = 620;
  static const homeFadeMs = 800;
  static const cardEntryMs = 1200;
  static const breathMs = 3600;
  static const scanMs = 10000;
  static const scoreRollMs = 600;
  static const resultRollMs = 1200;
  static const starPopMs = 1500;
  static const attackMs = 720;
  static const mascotIdleMs = 2600;
}
