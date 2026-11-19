import 'package:flutter/material.dart';
import 'package:flutter_animation_game/core/app_theme.dart';
import 'package:flutter_animation_game/core/tech_palette.dart';
import 'package:flutter_animation_game/models/game_level.dart';
import 'package:flutter_animation_game/models/game_result.dart';
import 'package:flutter_animation_game/pages/game_page.dart';
import 'package:flutter_animation_game/pages/home_page.dart';
import 'package:flutter_animation_game/pages/level_select_page.dart';
import 'package:flutter_animation_game/pages/result_page.dart';
import 'package:flutter_animation_game/widgets/direction_button.dart';
import 'package:flutter_animation_game/widgets/mascot_face.dart';
import 'package:flutter_animation_game/widgets/standing_mic.dart';
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

const _sizes = <String, Size>{
  '320x568': Size(320, 568),
  '360x800': Size(360, 800),
  '390x844': Size(390, 844),
  '412x915': Size(412, 915),
  '430x932': Size(430, 932),
};

void main() {
  for (final entry in _sizes.entries) {
    testWidgets('响应式 ${entry.key}', (tester) async {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_frame(const HomePage()));
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull, reason: '${entry.key} 首页');
      expect(find.text('开始游戏'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());

      await tester.pumpWidget(_frame(const LevelSelectPage()));
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull, reason: '${entry.key} 关卡页');
      expect(find.text('选择关卡'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());

      for (final level in [kGameLevels[0], kGameLevels[2]]) {
        await tester.pumpWidget(_frame(GamePage(level: level)));
        await tester.pump(const Duration(milliseconds: 900));
        expect(tester.takeException(), isNull, reason: '${entry.key} 游戏页 ${level.name}');

        final mic = tester.getRect(find.byType(StandingMic));
        final mascot = tester.getRect(find.byType(MascotFace));
        final padBottom = tester.getRect(find.byType(DirectionButton).last).bottom;
        expect(mic.overlaps(mascot), isFalse, reason: '${entry.key} 立麦压到小人');
        expect(mic.top, greaterThanOrEqualTo(padBottom - 1), reason: '${entry.key} 立麦压到方向键');
        expect(mic.right, lessThanOrEqualTo(entry.value.width));
        expect(mascot.left, greaterThanOrEqualTo(0));
        expect(padBottom, lessThanOrEqualTo(entry.value.height));
        await tester.pumpWidget(const SizedBox.shrink());
      }

      await tester.pumpWidget(
        _frame(
          ResultPage(
            result: GameResult(
              level: kGameLevels[1],
              score: 2800,
              maxCombo: 14,
              hits: 30,
              rounds: 36,
              hp: 70,
              stars: 2,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull, reason: '${entry.key} 结算页');
      expect(find.text('再来一局'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('390x844 安全区 + 1.5 倍字体', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: _frame(GamePage(level: kGameLevels[2])),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.takeException(), isNull, reason: '390x844 安全区/字体放大');
    expect(find.text('100/100'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
