# 方向匹配 · Flutter 动画小游戏设计说明

移动软件开发课程作业。竖屏方向匹配节奏小游戏，四页导航、完整判定循环、自绘背景与动画反馈均可运行。零第三方依赖。

## 1. 项目概况

- **课程背景**：移动软件开发 · Flutter 动画实践。目标是跑通一套完整的移动端小游戏骨架，并把 Flutter 动画体系（控制器、曲线、隐式动画、共享元素、自定义转场、自绘）落到真实页面里。
- **主题**：屏幕给出方向指令，玩家用滑动或方向键在限定窗口内匹配；失误扣血，60 秒内尽可能拿高分。
- **技术栈**：Flutter 3.47.4 / Dart 3.13.3，Material 3，竖屏锁定，Web（CanvasKit）与 Android 共用一套代码。
- **零第三方依赖的取舍**：`pubspec.yaml` 未引入任何运行时包。麦克风、小人、轨道环、脉冲、星点等全部用 `CustomPainter`/渐变自绘；Lottie 只保留资源位与接入说明。好处是环境搭建成本低、无版本冲突、动画原理全部可见；代价是复杂插画需自己绘制。

### 设计灵感

玩法灵感来源于《节奏大师》，除此之外无其他参考作品。

## 2. 整体设计

### 2.1 页面与导航

导航为四级：**首页 → 关卡选择 → 游戏 → 结算**。外层 `PhoneShell` 统一承载：宽度 ≤480dp 时全屏铺满，适合真机与手机视口；宽于 480dp 时收成 430dp 宽、垂直居中的手机框，两侧用当前配色的柔和渐变与光晕衬托，形似手机屏幕。路由转场、Hero、页面背景、底部弹层与暂停层都在壳内渲染，不会跑到框外。页面自身保持透明，背景由全局层叠加各页专属层提供。

| 页面 | 路由 | 职责 | 进入转场 |
| --- | --- | --- | --- |
| 首页 | `/` | 封面（标题 + 立式麦克风 + 分层音符）、课程标签、最高分、背景色调入口、开始游戏 | `FadeSlideRoute`：淡入 + 上移 5% |
| 关卡选择 | `/levels` | 三关卡片（窗口时长、指令数、目标分）、错峰入场、Hero 徽章、调色入口 | 淡入 + 上移 |
| 游戏 | `/game` | HUD、窗口指示、指令块、四向输入、小人舞台、暂停弹层 | `ScaleThroughRoute`：0.94→1 缩放淡入，Hero 徽章飞入 |
| 结算 | `/result` | 星级、评级、分数滚动、最高连击/命中率/剩余血量、再来一局与返回 | `SlideUpRoute`：自底部滑入 |

返回时三套转场以 360–380ms 反向播放；游戏结束用 `pushReplacementNamed` 进入结算，重开本局同样替换当前路由，避免堆栈堆积。

### 2.2 四页背景的处理

全局 `TechBackdrop` 是底色层：渐变底色、斜向主光、三团径向光晕、循环扫描光带、底部压暗与四角暗角；切换配色时用 700ms `AnimatedContainer` 过渡。**不使用网格**。

各页在全局层之上叠加自己的背景语言，互不重复：

- **封面**：不加专属背景层，靠标题与立麦的构图和留白；音符分远近两层上浮。
- **关卡选择**（`orbit_layer.dart`）：右上、左下两组倾斜轨道环，光点沿椭圆运行，26s 循环。
- **游戏**（`pulse_layer.dart`）：从底部舞台向外扩散的脉冲波纹与底部冷光，6s 循环，透明度上限 0.18，避开箭头与 HUD。
- **结算**（`starlight_layer.dart`）：确定性星点闪烁 + 底部三道光柱，8s 循环。

所有背景层均为 `IgnorePointer` + `CustomPainter`，不参与布局与命中测试。

### 2.3 四套配色

深空蓝 / 墨绿 / 紫黑 / 赤铜，全部为深色低饱和渐变。`core/tech_palette.dart` 用 `ThemeController`（`ChangeNotifier`）+ `PaletteScope`（`InheritedNotifier`）广播当前配色；`MaterialApp` 的 `ThemeData` 随之重建，但路由栈不重置。

切换入口在首页右上角、关卡页 AppBar、结算页右上角。弹层内点选即时预览，可连续切换，点「完成」关闭。正文、血量、窗口数值使用统一的高对比前景色，四套配色下都可读。

### 2.4 版式约定

- 已在 320×568、360×800、390×844、412×915、430×932 五档验证不溢出、不遮挡；矮屏（高度 <700dp）进入紧凑模式，见下一节。
- 游戏页从上到下：暂停键 / 关卡信息 + 总计时 → 血量条 → 得分与连击 → 「本指令窗口」独立面板 → 箭头区（`Expanded` 自适应）→ 方向键盘 → 小人舞台。
- 小人舞台左侧是恢复最早版配色的大耳吉祥物（深色身体、白脸盘、粉腮红），右侧为立式麦克风；保留待机呼吸、受击抖动/闪烁，音符从立麦飞向小人。
- 方向键与舞台互不重叠；窗口指示与箭头视觉分离。

## 4. 手机响应式

- **弹性布局**：页面用 `Column + Expanded/Flexible` 占满可用高度，不做整页硬编码尺寸；内容最大宽度 430dp 居中，最小验证宽度 320dp。
- **按比例取尺寸**：箭头块按可用高度比例计算并 clamp；立麦随舞台高度收缩（矮屏 78dp 舞台时同步缩到 59dp）；音符、轨道环、脉冲与光柱均按画布尺寸绘制。
- **矮屏紧凑模式**：游戏页在高度 <700dp 时收紧各段间距、方向键盘用 `FittedBox` 等比缩小、分数与舞台高度下调，保证箭头区仍有足够空间。
- **安全区与方向**：`main.dart` 锁定 `portraitUp`，状态栏透明；四个页面均使用 `SafeArea`，刘海与底部手势条不遮挡内容。
- **字体缩放**：文本不使用固定高度容器，结果页可滚动；已覆盖 1.5 倍字体 + 上下安全区，未溢出。更大倍率（≥1.8）未验证，游戏 HUD 可能会变挤。
- **已验证清单**：320×568、360×800、390×844、412×915、430×932（四页 + 单/复合关卡无溢出、立麦不压小人与方向键）；390×844 + 44/34 安全区 + 1.5 倍字体。

## 3. 玩法规则

### 3.1 判定流程

1. 每轮由 `GameSession._buildTokens()` 生成 1–2 条指令，窗口时钟从头开始。
2. 输入来源：四向滑动（位移 ≥48px 且主轴占比 ≥60%）或点击方向键，统一进入 `answer()`。
3. `answer()` 先检查暂停 / 已判定 / 本局结束；然后在未完成指令中找 `required == 输入方向` 的指令：
   - 命中：标记该指令完成；复合指令需全部完成才判定本轮回合命中，否则继续等待。
   - 错误方向：立即判定失误并中断本轮。
4. 窗口时钟走完仍未完成：判定超时（同样算失误）。
5. 判定后窗口时钟停止，反馈文字播放约 650ms，再进入下一轮；该停顿计时器在暂停时会被取消并在恢复时重排。

镜像指令显示一个方向，但 `CommandToken.required` 返回其相反方向，因此必须反着按。

### 3.2 数值与关卡

| 关卡 | 窗口时长 | 指令构成 | 目标分 |
| --- | --- | --- | --- |
| 第一关 | 1800ms | 单指令 | 2400 |
| 第二关 | 1700ms | 复合：同屏两个不同方向，顺序不限 | 3200 |
| 第三关 | 1500ms | 复合 + 每 6 条插入 1 条镜像指令 | 4000 |

- 每局固定 **36 条**指令。
- 初始血量 **100**，每次失误（按错或超时）**-10**。
- 命中得分 = `100 + min(连击, 10) × 10`；失误后连击清零，并触发麦克风音符攻击与小人受击抖动。
- **两套计时互不复用**：单条窗口每轮重置，只控制本轮输入；60 秒总计时贯穿整局，持续消耗，两者都停才算暂停。
- 结束条件（任一满足即结算）：36 条全部完成、血量归零、60 秒总计时耗尽。
- 评级按 `得分 / 目标分`：≥1 为 3 星「完美节奏」，≥0.6 为 2 星「表现不错」，否则 1 星「再来一局」；命中率 = 命中轮次 / 已完成轮次。
- **暂停**：左上角暂停键同时停住窗口时钟、总计时与下一轮排期计时器，弹层提供「继续游戏 / 重开本局 / 返回关卡选择」。继续时总计时从暂停点续走，窗口从当前进度续走；重开与返回都会清理计时器与监听。

## 5. Flutter 动画与 UI 组件清单

| 组件 / 能力 | 使用位置 | 职责 |
| --- | --- | --- |
| `AnimationController` + `addStatusListener` | `state/game_session.dart` | 两套时钟：单条窗口到点触发超时、总计时到点触发结算 |
| `AnimationController.repeat` / `repeat(reverse:)` | `mic_cover.dart`、`scan_band.dart`、`mascot_scene.dart`、`lottie_slot.dart`、三个背景层 | 封面音符上浮、扫描光带、小人待机呼吸、Lottie 占位脉冲、轨道/脉冲/星点循环 |
| `CurvedAnimation` / `Curves` | 全局 | `easeOutCubic`、`easeOutQuart/Quint`、`easeOutBack`、`elasticOut` 等控制入场与回弹手感 |
| `AnimatedBuilder` | 窗口条、总计时、指令块、封面、舞台、三个背景层 | 只重建读取动画值的子树 |
| `AnimatedContainer` | `health_bar.dart`、`tech_backdrop.dart` | 血量条宽度过渡、切换配色时背景渐变 700ms 过渡 |
| `AnimatedScale` | `direction_button.dart`、`press_scale.dart`、`level_card.dart` | 方向键/主按钮/关卡卡的按压缩放回弹 |
| `AnimatedOpacity` | `command_block.dart` | 已判定指令块变淡 |
| `AnimatedSwitcher` | 判定文字、连击提示、结算评级、暂停弹层 | 内容替换时的缩放/淡入淡出 |
| `TweenAnimationBuilder` | `score_counter.dart`、结算分数、结算星级、暂停面板、首页入场 | 数字滚动、星级弹出、面板缩放入场 |
| `Tween` / `Color.lerp` | `command_block.dart`、路由转场 | 指令块入场缩放、临近超时的颜色插值 |
| `Hero` | `level_badge.dart` | 关卡卡片徽章与游戏页徽章共享同一 tag |
| `PageRouteBuilder` 自定义转场 | `routes/transitions.dart` | 三套路由转场：淡入上移、缩放穿过、底部滑入 |
| `GestureDetector` / `Listener` | 游戏箭头区、方向键、`press_scale.dart`、关卡卡 | 四向滑动判定、点位输入、按压反馈；均有 `onTapCancel` 兜底 |
| `CustomPainter` | `standing_mic.dart`、`mascot_face.dart`、三个背景层 | 立式麦克风、小人、轨道环、脉冲波纹、星点光柱 |
| `InheritedNotifier` + `ChangeNotifier` | `core/tech_palette.dart` | 四套配色的全局状态与依赖重建 |
| `ValueNotifier` + `ValueListenableBuilder` | `core/score_store.dart`、首页 | 最高分（当前为内存态） |
| `LayoutBuilder` / `Expanded` / `SafeArea` | 各页 | 竖屏弹性布局、矮屏紧凑模式与安全区，五档视口不溢出 |

## 6. 目录结构与关键文件

```
outputs/
├─ lib/
│  ├─ main.dart                 # 竖屏锁定、状态栏样式、启动
│  ├─ app.dart                  # PaletteScope + MaterialApp + PhoneShell 手机框
│  ├─ core/
│  │  ├─ app_config.dart        # 文案、节奏、动画时长等可调参数
│  │  ├─ app_theme.dart         # 深色主题、按钮/文字样式
│  │  ├─ tech_palette.dart      # 四套配色、ThemeController、PaletteScope
│  │  └─ score_store.dart       # 最高分（内存态）
│  ├─ models/                   # Direction、GameLevel、CommandToken、GameResult
│  ├─ state/game_session.dart   # 判定循环、双时钟、血量/连击/得分、暂停恢复
│  ├─ pages/                    # home / level_select / game / result
│  ├─ routes/                   # 路由表与三套转场
│  └─ widgets/                  # 麦克风、小人、指令块、窗口条、血量条、
│                               # 方向键、调色弹层、按压组件、背景层等
├─ assets/lottie/               # Lottie 资源位（当前为原生占位）
├─ test/
│  ├─ smoke_test.dart           # 交互与版式断言（含 360×800 不溢出/暂停冻结）
│  ├─ tmp_visual_test.dart      # 页面视觉快照用例
│  └─ shots/                    # 快照基准图（390×844 / 360×800 / 配色变体）
├─ android/  web/               # 平台工程
└─ pubspec.yaml                 # 零第三方依赖
```

关键扩展点：`GameSession._buildTokens()`（生成指令）、`_judge()`（判分）、`CommandBlock`（箭头视觉）、`ScoreStore`（持久化）、`LottieSlot`（接入 Lottie）。

## 7. 运行方式

**Web**

```powershell
cd outputs
flutter pub get
flutter run -d chrome
```

浏览器视口按 390×844 查看；发布包用 `flutter build web --release`，再以静态服务器打开 `build/web`。

**Web 竖屏效果**

- 想按手机比例看：在浏览器开发者工具里切到 390×844（或 360×800）响应式视口；宽度 ≤480dp 时页面全屏铺满，与真机一致。
- 直接宽屏打开：应用自动收成 430dp 宽的手机框并水平居中，两侧是与当前配色一致的柔和背景；所有页面、转场与弹层都限制在框内。

**Android**

```powershell
flutter doctor -v          # 确认 Android toolchain / SDK / JDK
flutter devices            # 确认设备或模拟器
flutter run -d <设备>
flutter build apk --release
```

产物为通用包（arm64 + arm + x64），约 43.8MB；V2 签名使用 Android Debug 证书，可直接侧载安装，上架应用商店需换成正式签名。已提供 `outputs/apk/app-release.apk`（applicationId `com.example.flutter_animation_game`，versionName 0.1.0，minSdk 24 / targetSdk 36）。

> Windows 中文路径下 `flutter build apk --release` 的 AOT 快照器可能因编码问题失败；把工程复制到纯 ASCII 路径（如 `C:\temp\fxgame-apk`）再构建即可，本 APK 即按此方式产出。

## 8. 性能与已知限制

- 动画以 `CustomPainter` 与轻量隐式动画为主，背景层独立循环；实机体验建议用 `flutter run --profile -d chrome` 或 release 包验证。debug 模式（JIT、断言、CanvasKit 首次着色器编译）出现卡顿属正常现象，不代表 release 表现。
- 关卡选择→游戏的转场由 600ms 缩至 300ms；游戏页首帧先只渲染玩法内容，脉冲背景层在首帧后挂载并包 `RepaintBoundary`。
- 实测（debug widget test，仅统计构建+布局+绘制记录，不含 GPU 光栅化）：游戏页首帧约 21.5ms（优化前）→ 22–25ms（优化后，属测量波动，无显著差异）；延迟主体是转场时长，缩短后少 300ms。
- 最高分仅内存保存，重启即清零；关卡解锁、星级回传首页、Lottie 实装均未做。
- 游戏页为 Canvas 渲染，Web 端自动化测试只能验证版式与状态，交互由 widget test 覆盖。
- 未在 Android 真机/模拟器运行过；`flutter test` 19 项通过（3 项交互/版式断言 + 8 张视觉快照 + 6 项响应式视口/字体测试 + 2 项手机框宽屏/全屏测试），`dart analyze lib test` 无问题，`flutter build web --release` 构建成功，release APK 构建成功（Android SDK 37 / build-tools 37 / JDK 25，Android SDK 位于 `C:\Users\0928\AppData\Local\Android\sdk`）。
