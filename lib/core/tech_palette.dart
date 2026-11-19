import 'package:flutter/material.dart';

/// 每套背景只换底色与主光色，正文与状态色保持统一，保证四套下都可读。
class TechPalette {
  const TechPalette({
    required this.id,
    required this.name,
    required this.bgTop,
    required this.bgBottom,
    required this.primary,
    required this.glow,
  });

  final String id;
  final String name;
  final Color bgTop;
  final Color bgBottom;
  final Color primary;
  final Color glow;
}

const kTechPalettes = <TechPalette>[
  TechPalette(
    id: 'space',
    name: '深空蓝',
    bgTop: Color(0xFF070D1C),
    bgBottom: Color(0xFF122442),
    primary: Color(0xFF5B8CFF),
    glow: Color(0xFF2F5BFF),
  ),
  TechPalette(
    id: 'forest',
    name: '墨绿',
    bgTop: Color(0xFF06120F),
    bgBottom: Color(0xFF0E2E27),
    primary: Color(0xFF2FD3A8),
    glow: Color(0xFF0FA37F),
  ),
  TechPalette(
    id: 'violet',
    name: '紫黑',
    bgTop: Color(0xFF0B0718),
    bgBottom: Color(0xFF21133D),
    primary: Color(0xFFA06BFF),
    glow: Color(0xFF7B3DFF),
  ),
  TechPalette(
    id: 'copper',
    name: '赤铜',
    bgTop: Color(0xFF120C09),
    bgBottom: Color(0xFF2C1811),
    primary: Color(0xFFFF8A5C),
    glow: Color(0xFFE85D2A),
  ),
];

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  int _index = 0;

  int get index => _index;
  TechPalette get palette => kTechPalettes[_index];

  void select(int index) {
    if (index == _index || index < 0 || index >= kTechPalettes.length) return;
    _index = index;
    notifyListeners();
  }
}

class PaletteScope extends InheritedNotifier<ThemeController> {
  const PaletteScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PaletteScope>()!.notifier!;
}

extension PaletteContext on BuildContext {
  TechPalette get palette => PaletteScope.of(this).palette;
  ThemeController get themeController => PaletteScope.of(this);
}
