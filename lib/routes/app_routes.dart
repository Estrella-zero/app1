import 'package:flutter/material.dart';

import '../models/game_level.dart';
import '../models/game_result.dart';
import '../pages/game_page.dart';
import '../pages/home_page.dart';
import '../pages/level_select_page.dart';
import '../pages/result_page.dart';
import 'transitions.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const levels = '/levels';
  static const game = '/game';
  static const result = '/result';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case levels:
        return FadeSlideRoute(page: const LevelSelectPage(), settings: settings);
      case game:
        return ScaleThroughRoute(
          page: GamePage(level: settings.arguments as GameLevel),
          settings: settings,
        );
      case result:
        return SlideUpRoute(
          page: ResultPage(result: settings.arguments as GameResult),
          settings: settings,
        );
      case home:
      default:
        return FadeSlideRoute(page: const HomePage(), settings: settings);
    }
  }
}
