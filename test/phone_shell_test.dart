import 'package:flutter/material.dart';
import 'package:flutter_animation_game/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('宽屏 1024x768 收成 430 手机壳', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnimationGameApp());
    await tester.pump(const Duration(milliseconds: 800));
    final shell = tester.getRect(find.byKey(const ValueKey('phone-shell')));
    expect(shell.width, 430);
    expect(shell.height, 768 - 24);
    expect(shell.left, (1024 - 430) / 2);
    expect(find.text('开始游戏'), findsOneWidget);

    // 转场与页面都留在壳内。
    await tester.tap(find.text('开始游戏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('选择关卡'), findsOneWidget);
    final card = tester.getRect(find.text('第一关'));
    expect(card.left, greaterThan(shell.left));
    expect(card.right, lessThan(shell.right));

    // 调色弹层不能跑出手机画布。
    await tester.tap(find.byIcon(Icons.palette_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final sheetTitle = tester.getRect(find.text('背景色调'));
    expect(sheetTitle.left, greaterThanOrEqualTo(shell.left));
    expect(sheetTitle.right, lessThanOrEqualTo(shell.right));
    await tester.tap(find.text('完成'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('第一关'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
    expect(find.text('100/100'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('390x844 保持全屏，不套手机壳', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnimationGameApp());
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byKey(const ValueKey('phone-shell')), findsNothing);
    expect(tester.getRect(find.byType(Scaffold).first).width, 390);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
