# 项目架构文档

## 项目目录结构

```
Yunntan_Recorder/
├── android/                    # Android 原生配置
│   ├── app/
│   │   └── build.gradle.kts    # Android SDK 版本配置 (targetSdk 34, compileSdk 35)
│   └── gradle.properties       # 含 android.overridePathCheck=true（跳过非 ASCII 路径检查）
├── assets/
│   └── data/                   # 静态 JSON 字典数据（train_hierarchy.json, railway_bureau.json）
├── lib/
│   ├── main.dart               # 应用入口：DynamicColorBuilder + FlexThemeData + MainShell + HomePage
│   ├── models/                 # 数据模型层（Trip, TrainCategory, TrainPlatform 等）
│   ├── providers/              # Riverpod 状态管理层（AsyncNotifierProvider + FutureProvider）
│   ├── pages/                  # 页面层
│   │   ├── entry_page.dart     # 运转录入页（新建/编辑模式，12+ 字段）
│   │   └── achievement_page.dart # 成就页（仪表盘统计 + 成就系统占位）
│   ├── widgets/                # 可复用组件层
│   │   ├── trip_card.dart      # TripCard（紧凑卡片 + Slidable + Overlay 动画详情）
│   │   ├── train_model_picker.dart # 4级级联车型选择器（CupertinoPicker）
│   │   └── bureau_picker.dart  # 2级级联担当选择器（CupertinoPicker）
│   ├── utils/                  # 工具函数层（CSV 导出、数据解析等）
│   ├── data/                   # 数据加载层（JSON 字典读取与解析）
│   ├── objectbox.g.dart        # ObjectBox 代码生成（build_runner 自动生成）
│   └── objectbox-model.json    # ObjectBox 模型定义
├── memory-bank/                # 项目记忆库（设计文档、进度跟踪等）
├── test/                       # 测试目录
├── pubspec.yaml                # 依赖与项目配置
└── .gitignore
```

## 架构决策

| 决策项 | 结论 | 理由 |
|--------|------|------|
| 状态管理 | Riverpod (flutter_riverpod) | 编译时安全、可测试性强、支持异步状态管理 |
| 数据库 | ObjectBox NoSQL | Flutter 生态高性能本地 NoSQL 数据库，完全兼容 Dart 3.11+，Schema-less 适合扩展字段。替代 Isar（3.x 与 Dart 3.11 不兼容） |
| UI 风格 | Material You (Material 3) | 现代设计规范，动态配色 |
| 主题方案 | FlexColorScheme 8.4.0 (greyLaw) + dynamic_color | 工业简约风配色 + 壁纸动态取色。有动态色时覆盖 colorScheme，无动态色时回退 greyLaw |
| 级联选择器 | CupertinoPicker (iOS 拨轮) | 专业感强，操作效率高，以 BottomSheet 弹出 |
| 滑动操作 | flutter_slidable ^4.0.0 | 成熟的滑动组件，BehindMotion 动效，支持互斥控制 |
| 动画系统 | AnimationController + Overlay | 自定义分层动画，遵循 MD3 Motion 规范，500ms 总时长 |
| 数据模型 | freezed + json_serializable | 不可变数据类，自动生成 JSON 序列化代码 |
| Android SDK | minSdk 21 / targetSdk 34 / compileSdk 35 | 覆盖 Android 5.0+，适配 Android 14。compileSdk 35 因 objectbox_flutter_libs 要求 |
| 项目路径 | 必须为纯英文路径 | Android 构建工具（aapt）不支持非 ASCII 路径 |

## UI 架构

### 页面结构

```
MaterialApp
  └─ DynamicColorBuilder (壁纸动态取色)
       └─ MainShell (Scaffold)
            ├─ NavigationBar (首页 / 成就 / 设置)
            ├─ FloatingActionButton (仅首页显示，跳转 EntryPage)
            └─ Page Views:
                 ├─ HomePage (运转记录列表)
                 ├─ AchievementPage (仪表盘 + 成就)
                 └─ SettingsPage (待开发)
```

### HomePage 架构

```
HomePage (ConsumerStatefulWidget)
  └─ Scaffold
       ├─ AppBar ("运转记录")
       └─ ListView.builder (按时间倒序)
            └─ TripCard × N
                 ├─ Slidable (左滑编辑 / 右滑删除)
                 │    ├─ startActionPane: 编辑按钮 (primary)
                 │    └─ endActionPane: 删除按钮 (error)
                 └─ Card (紧凑布局)
                      └─ InkWell → _openTicket()
                           └─ Row: 日期时间 | 车次+标签 | 区间 | 车底标签 | 箭头
```

### TripCard 动画架构

```
TripCard (StatefulWidget + TickerProviderStateMixin)
  ├─ SlidableController (管理滑动状态)
  ├─ AnimationController (500ms, 管理展开/关闭动画)
  └─ OverlayEntry (点击卡片时插入)
       └─ _TicketOverlay (StatelessWidget)
            └─ AnimatedBuilder
                 └─ Stack
                      ├─ BackdropFilter (bgProgress: 0-300ms)
                      └─ Positioned (expandProgress: 0-500ms)
                           └─ Container (clipBehavior: antiAlias)
                                └─ _TicketContent
                                     └─ Opacity (fadeProgress: 0-300ms)
                                          └─ Column (Header / Divider / Route / InfoGrid / Remarks)
```

### Slidable 互斥机制

```
HomePage._closeCurrentSlidable: VoidCallback?

TripCard.registerClose: RegisterCloseCallback
  → 当卡片 A 的 Slidable 打开时：
     1. 调用 registerClose(closeCallback)
     2. HomePage 先调用 _closeCurrentSlidable() 关闭上一张
     3. 然后将 closeCallback 存入 _closeCurrentSlidable
  → 当卡片 B 的 Slidable 打开时：
     1. 同上流程，自动关闭卡片 A
```

## 核心依赖清单

### 运行时依赖（当前已引入）
- `flutter_riverpod: ^3.3.1` — 状态管理
- `flex_color_scheme: ^8.4.0` — Material You 主题配置（greyLaw 工业风）
- `dynamic_color: ^1.7.0` — Material You 动态取色（壁纸色适配）
- `json_annotation: ^4.9.0` — JSON 序列化注解
- `freezed_annotation: ^3.1.0` — 不可变数据类注解
- `objectbox: ^5.2.0` — NoSQL 本地数据库
- `objectbox_flutter_libs: ^5.2.0` — ObjectBox Flutter 平台库
- `path_provider: ^2.1.0` — 应用文档目录路径
- `flutter_slidable: ^4.0.0` — 滑动操作（左滑编辑、右滑删除）

### 开发依赖（当前已引入）
- `freezed: ^3.2.5` — 不可变数据类代码生成
- `json_serializable: ^6.8.0` — JSON 序列化代码生成
- `build_runner: ^2.4.0` — 代码生成工具
- `objectbox_generator: ^5.2.0` — ObjectBox 代码生成

### 待引入（后续步骤需要时添加）
- `csv` — 第 11 步 CSV 导出时引入

## 数据流架构

```
UI (pages/widgets)
  ↕ Riverpod Provider
State Management (providers/)
  ↕ CRUD
Database (ObjectBox)
  ↕
Local Storage
```

### Provider 依赖关系

```
tripListProvider (FutureProvider) → ObjectBoxInstance 单例
  ↓ watch
HomePage / AchievementPage
  ↓ read(.notifier)
TripListNotifier.addTrip / updateTrip / deleteTrip
```

## 开发环境

- Flutter SDK: `D:\Software\Flutter-SDK\flutter\`
- 项目路径: `D:\Personal_file\VibeCoding\Program\Yunntan_Recorder`（纯英文路径）
- Flutter 命令需在外部终端执行（Trae 沙箱不支持）
- GitHub 仓库: https://github.com/cheeemmms/Yunntan_Recorder
- 用户有科学上网工具，网络问题只需提醒切换代理节点
