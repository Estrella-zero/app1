import 'package:flutter/material.dart';
import 'package:flutter_animation_game/app.dart';
import 'package:flutter_animation_game/core/app_theme.dart';
import 'package:flutter_animation_game/core/tech_palette.dart';
import 'package:flutter_animation_game/models/direction.dart';
import 'package:flutter_animation_game/models/game_level.dart';
import 'package:flutter_animation_game/models/game_result.dart';
import 'package:flutter_animation_game/pages/game_page.dart';
import 'package:flutter_animation_game/pages/result_page.dart';
import 'package:flutter_animation_game/widgets/command_block.dart';
import 'package:flutter_animation_game/widgets/direction_button.dart';
import 'package:flutter_animation_game/widgets/mascot_face.dart';
import 'package:flutter_animation_game/widgets/orbit_layer.dart';
import 'package:flutter_animation_game/widgets/pulse_layer.dart';
import 'package:flutter_animation_game/widgets/starlight_layer.dart';
import 'package:flutter_animation_game/widgets/standing_mic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('首页可进入关卡选择并开始第一关', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnimationGameApp());
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('开始游戏'), findsOneWidget);

    // 切换背景色调，弹层保持打开供连续预览。
    await tester.tap(find.byIcon(Icons.palette_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('背景色调'), findsOneWidget);
    await tester.tap(find.text('墨绿'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(ThemeController.instance.index, 1);
    await tester.tap(find.text('完成'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('开始游戏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('第一关'), findsOneWidget);
    expect(find.byType(OrbitLayer), findsOneWidget);

    await tester.tap(find.text('第一关'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('目标分 2400'), findsOneWidget);
    expect(find.text('100/100'), findsOneWidget);
    expect(find.textContaining('总计时'), findsOneWidget);
    expect(find.byType(PulseLayer), findsOneWidget);

    // 暂停后从弹层返回关卡选择，验证转场与计时器清理。
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('已暂停'), findsOneWidget);

    await tester.tap(find.text('返回关卡选择'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('选择关卡'), findsOneWidget);

    // 卸载页面，释放循环动画与游戏计时器。
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    ThemeController.instance.select(0);
  });

  testWidgets('小屏 360x800 下游戏页不溢出', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      PaletteScope(
        controller: ThemeController.instance,
        child: MaterialApp(
          theme: AppTheme.dark(ThemeController.instance.palette),
          home: GamePage(level: kGameLevels[2]),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('100/100'), findsOneWidget);

    // 立式麦克风不能压到小人，也不能盖住方向键。
    final mic = tester.getRect(find.byType(StandingMic));
    final mascot = tester.getRect(find.byType(MascotFace));
    final padBottom = tester.getRect(find.byType(DirectionButton).last).bottom;
    expect(mic.overlaps(mascot), isFalse);
    expect(mic.top, greaterThanOrEqualTo(padBottom));
    expect(mic.right, lessThanOrEqualTo(360));

    // 点一个与当前指令都不同的方向，验证扣血与攻击触发。
    final tokens = tester.widgetList<CommandBlock>(find.byType(CommandBlock)).toList();
    final required = tokens.map((block) => block.direction).toSet();
    final wrong = Direction.values.firstWhere((direction) => !required.contains(direction));
    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is DirectionButton && widget.direction == wrong,
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('90/100'), findsOneWidget);

    // 暂停后总计时与窗口指示都必须停住，弹层提供三个动作。
    final timerFinder = find.textContaining(RegExp(r'^总计时 \d+s$'));
    final windowFinder = find.textContaining(RegExp(r'^\d\.\ds$'));
    final timerBefore = tester.widget<Text>(timerFinder).data;
    final windowBefore = tester.widget<Text>(windowFinder).data;
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('已暂停'), findsOneWidget);
    expect(find.text('继续游戏'), findsOneWidget);
    expect(find.text('重开本局'), findsOneWidget);
    expect(find.text('返回关卡选择'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(tester.widget<Text>(timerFinder).data, timerBefore);
    expect(tester.widget<Text>(windowFinder).data, windowBefore);

    await tester.tap(find.text('继续游戏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('已暂停'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('结算页在 360x800 下使用星点光柱背景', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      PaletteScope(
        controller: ThemeController.instance,
        child: MaterialApp(
          theme: AppTheme.dark(ThemeController.instance.palette),
          home: ResultPage(
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
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(StarlightLayer), findsOneWidget);
    expect(find.text('表现不错'), findsOneWidget);
    expect(find.text('再来一局'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
