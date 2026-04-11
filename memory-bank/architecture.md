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
│   ├── main.dart               # 应用入口：ProviderScope + FlexColorScheme 8.4.0 + Material You
│   ├── models/                 # 数据模型层（Trip, TrainCategory, TrainPlatform 等）
│   ├── providers/              # Riverpod 状态管理层（AsyncNotifierProvider + FutureProvider）
│   ├── pages/                  # 页面层（HomePage, EntryPage, AchievementPage, SettingsPage）
│   ├── widgets/                # 可复用组件层（CupertinoPicker 级联选择器等）
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
| 主题方案 | FlexColorScheme 8.4.0 (greyLaw) | 工业简约风配色，符合铁道专业感。V8 适配最新 Flutter SDK |
| 级联选择器 | CupertinoPicker (iOS 拨轮) | 专业感强，操作效率高，以 BottomSheet 弹出 |
| 数据模型 | freezed + json_serializable | 不可变数据类，自动生成 JSON 序列化代码 |
| Android SDK | minSdk 21 / targetSdk 34 / compileSdk 35 | 覆盖 Android 5.0+，适配 Android 14。compileSdk 35 因 objectbox_flutter_libs 要求 |
| 项目路径 | 必须为纯英文路径 | Android 构建工具（aapt）不支持非 ASCII 路径 |

## 核心依赖清单

### 运行时依赖（当前已引入）
- `flutter_riverpod: ^3.3.1` — 状态管理
- `flex_color_scheme: ^8.4.0` — Material You 主题配置（greyLaw 工业风）
- `json_annotation: ^4.9.0` — JSON 序列化注解
- `freezed_annotation: ^3.1.0` — 不可变数据类注解
- `objectbox: ^5.2.0` — NoSQL 本地数据库
- `objectbox_flutter_libs: ^5.2.0` — ObjectBox Flutter 平台库
- `path_provider: ^2.1.0` — 应用文档目录路径

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

## 开发环境

- Flutter SDK: `D:\Software\Flutter-SDK\flutter\`
- 项目路径: `D:\Personal_file\VibeCoding\Program\Yunntan_Recorder`（纯英文路径）
- Flutter 命令需在外部终端执行（Trae 沙箱不支持）
- GitHub 仓库: https://github.com/cheeemmms/Yunntan_Recorder
- 用户有科学上网工具，网络问题只需提醒切换代理节点
