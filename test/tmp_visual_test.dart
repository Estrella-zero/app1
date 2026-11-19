import 'package:flutter/material.dart';
import 'package:flutter_animation_game/core/app_theme.dart';
import 'package:flutter_animation_game/core/tech_palette.dart';
import 'package:flutter_animation_game/models/game_level.dart';
import 'package:flutter_animation_game/models/game_result.dart';
import 'package:flutter_animation_game/pages/game_page.dart';
import 'package:flutter_animation_game/pages/home_page.dart';
import 'package:flutter_animation_game/pages/level_select_page.dart';
import 'package:flutter_animation_game/pages/result_page.dart';
import 'package:flutter_animation_game/widgets/tech_backdrop.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _frame(Widget page) {
  return PaletteScope(
    controller: ThemeController.instance,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(ThemeController.instance.palette),
      builder: (context, child) => Stack(
        children: [
          const Positioned.fill(child: TechBackdrop()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      home: page,
    ),
  );
}

void _size(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('home 390', (tester) async {
    _size(tester, const Size(390, 844));
    await tester.pumpWidget(_frame(const HomePage()));
    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/home_390.png'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('home 360', (tester) async {
    _size(tester, const Size(360, 800));
    await tester.pumpWidget(_frame(const HomePage()));
    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/home_360.png'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('levels 390', (tester) async {
    _size(tester, const Size(390, 844));
    await tester.pumpWidget(_frame(const LevelSelectPage()));
    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/levels_390.png'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('game 390', (tester) async {
    _size(tester, const Size(390, 844));
    await tester.pumpWidget(_frame(GamePage(level: kGameLevels[0])));
    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/game_390.png'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('game 360', (tester) async {
    _size(tester, const Size(360, 800));
    await tester.pumpWidget(_frame(GamePage(level: kGameLevels[2])));
    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/game_360.png'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('result 390', (tester) async {
    _size(tester, const Size(390, 844));
    await tester.pumpWidget(
      _frame(
        ResultPage(
          result: GameResult(
            level: kGameLevels[0],
            score: 1800,
            maxCombo: 12,
            hits: 28,
            rounds: 36,
            hp: 80,
            stars: 2,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/result_390.png'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('levels violet', (tester) async {
    _size(tester, const Size(390, 844));
    ThemeController.instance.select(2);
    await tester.pumpWidget(_frame(const LevelSelectPage()));
    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/levels_violet.png'));
    await tester.pumpWidget(const SizedBox.shrink());
    ThemeController.instance.select(0);
  });

  testWidgets('result copper', (tester) async {
    _size(tester, const Size(390, 844));
    ThemeController.instance.select(3);
    await tester.pumpWidget(
      _frame(
        ResultPage(
          result: GameResult(
            level: kGameLevels[0],
            score: 1800,
            maxCombo: 12,
            hits: 28,
            rounds: 36,
            hp: 80,
            stars: 2,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/result_copper.png'));
    await tester.pumpWidget(const SizedBox.shrink());
    ThemeController.instance.select(0);
  });
}
