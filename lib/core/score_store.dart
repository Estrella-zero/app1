import 'package:flutter/foundation.dart';

/// 最高分存储：当前为内存态，换成 shared_preferences 或本地文件时只改这里。
class ScoreStore {
  const ScoreStore._();

  static final ValueNotifier<int> best = ValueNotifier<int>(0);

  static void submit(int score) {
    if (score > best.value) best.value = score;
  }
}
