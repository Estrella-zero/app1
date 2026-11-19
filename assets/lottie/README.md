# Lottie 资源位

把导出的 JSON 动画放在本目录，例如 `feedback.json`，然后在 `lib/widgets/lottie_slot.dart`
里把原生占位替换为 `Lottie.asset(...)`，并在 `pubspec.yaml` 解开 `lottie` 依赖。

当前骨架不依赖该文件，删除也不会影响运行。
