# 项目进度跟踪

## 规则
- 每完成 implementation-plan.md 中的一个步骤，必须更新本文档并提交 Git。

## 当前进度

| 阶段 | 步骤 | 状态 |
|------|------|------|
| 第一阶段：项目地基与静态字典 | 第 1 步：Flutter 环境初始化 | ✅ 已完成 |
| | 第 2 步：构建铁路字典 (JSON) | ✅ 已完成 |
| 第二阶段：核心记录表单 | 第 3 步：三级级联选择器 UI | ⬜ 未开始 |
| | 第 4 步：全字段表单布局 | ⬜ 未开始 |
| 第三阶段：本地存储引擎 | 第 5 步：ObjectBox 数据库集成 | ⬜ 未开始 |
| | 第 6 步：数据存取流程闭环 | ⬜ 未开始 |
| 第四阶段：首页总结与列表 | 第 7 步：全屏仪表盘 Dashboard | ⬜ 未开始 |
| | 第 8 步：历史记录流与筛选 | ⬜ 未开始 |
| 第五阶段：成就感与图库 | 第 9 步：车型照片映射系统 | ⬜ 未开始 |
| | 第 10 步：成就统计页面 | ⬜ 未开始 |
| 第六阶段：数据导出与分享 | 第 11 步：CSV 导出功能 | ⬜ 未开始 |
| | 第 12 步：海报分享功能（预留） | ⬜ 未开始 |

---

## 第 1 步详细状态：Flutter 环境初始化

### 已完成
- [x] Flutter SDK 已安装并迁移至 `D:\Software\Flutter-SDK\flutter\`（已解决路径空格问题）
- [x] GitHub CLI 已安装，已登录账号 cheeemmms
- [x] Flutter 项目已创建：`flutter create . --project-name train_ledger --org com.yunntan --platforms android`
- [x] Android SDK 版本已配置：compileSdk = 34, targetSdk = 34（minSdk 使用 flutter.minSdkVersion，新版 Flutter 默认为 21）
- [x] 核心依赖已添加到 `pubspec.yaml`（见下方依赖清单）
- [x] 项目目录结构已建立：lib/models, lib/providers, lib/pages, lib/widgets, lib/utils, lib/data, assets/data
- [x] `lib/main.dart` 已替换为 Riverpod + FlexColorScheme 8.4.0 (greyLaw 工业风) + Material You 应用
- [x] 测试文件已更新为 Hello Ledger smoke test
- [x] `android/gradle.properties` 已添加 `android.overridePathCheck=true`
- [x] APK 构建成功（`flutter build` 通过）

### 待完成（按顺序）
1. [x] **在真机上验证运行**：执行 `flutter clean && flutter pub get && flutter run`，确认在真机上显示 "Hello Ledger" 页面
2. [x] 验证通过后，更新 progress.md 第 1 步状态为 ✅
3. [ ] 提交 Git 并推送

### 当前 pubspec.yaml 依赖清单

**运行时依赖：**
- `flutter_riverpod: ^2.5.0` — 状态管理
- `flex_color_scheme: ^8.4.0` — Material You 主题（greyLaw 工业风）
- `json_annotation: ^4.9.0` — JSON 序列化注解
- `freezed_annotation: ^2.4.0` — 不可变数据类注解

**开发依赖：**
- `freezed: ^2.5.0` — 不可变数据类代码生成
- `json_serializable: ^6.8.0` — JSON 序列化代码生成
- `build_runner: ^2.4.0` — 代码生成工具

**暂未引入（后续步骤需要时再添加）：**
- `objectbox / objectbox_flutter_libs` — 第 5 步 ObjectBox 数据库集成时引入
- `path_provider` — 第 5 步数据库路径 / 第 11 步 CSV 导出时引入

### 已解决的问题

| 问题 | 解决方案 |
|------|----------|
| Trae 沙箱无法执行 Flutter 命令 | 分工模式：用户在外部终端执行 Flutter 命令，Trae 负责代码编写 |
| Flutter SDK 路径含空格 (`Flutter SDK`) | 迁移至 `D:\Software\Flutter-SDK\flutter\` |
| 系统 PATH 未包含 Flutter | 外部终端手动设置 `$env:PATH` |
| Gradle kotlin-dsl 5.2.0 插件找不到 | 网络问题，切换科学上网代理节点解决 |
| Gradle SSL 握手失败 / 下载超时 | 切换科学上网代理节点解决 |
| 项目路径含非 ASCII 字符导致 Gradle 报错 | 添加 `android.overridePathCheck=true` 到 gradle.properties |
| flex_color_scheme 7.3.1 与 Dart 3.11 不兼容 | 升级到 flex_color_scheme 8.4.0，适配 V8 API 变更 |
| Isar 3.x 与 Dart 3.11 不兼容 | 改用 ObjectBox 替代 Isar，ObjectBox 完全兼容 Dart 3.11+ |
| 项目路径中文导致 aapt 报 "Illegal byte sequence" | 已将路径从 `D:\个人文件\...` 迁移为 `D:\Personal_file\...`（纯英文路径） |

### 注意事项
- **用户有科学上网工具**：遇到 Gradle/Maven/Pub 网络问题（SSL 握手失败、下载超时等），只需提醒用户切换代理节点即可，无需配置国内镜像
- Flutter 命令需在外部终端执行（设置 PATH 后）
- `build.gradle.kts` 中的 `minSdk = flutter.minSdkVersion` 会被 `flutter` 命令重置，无需反复手动改为 21（新版 Flutter 默认就是 21）
- Isar 3.x 与当前 Dart SDK 不兼容，已改用 ObjectBox 替代
- 项目已迁移至纯英文路径 `D:\Personal_file\VibeCoding\Program\Yunntan_Recorder`

### 外部终端执行 Flutter 命令的模板

```powershell
# 设置 PATH 并进入项目目录
$env:PATH = "D:\Software\Flutter-SDK\flutter\bin;" + $env:PATH; cd "D:\Personal_file\VibeCoding\Program\Yunntan_Recorder"

# 常用命令
flutter pub get          # 拉取依赖
flutter run              # 运行到设备
flutter clean            # 清理构建缓存
flutter build apk        # 构建 APK
```

---

## 第 2 步详细状态：构建铁路字典 (JSON)

### 已完成
- [x] 车型级联数据结构确认为 4 级（L1→L2→L3→L4），L3 可选即止，L4 为可选变体
- [x] CR（复兴号系列）数据已录入：CR450、CR400、CR300、CR220J、CR200J(1.0/2.0/3.0)
- [x] CRH（和谐号系列）数据已录入：CRH380、CRH1、CRH2、CRH3、CRH5、CRH6
- [x] Coach（普速客车车底）数据已录入：25G、25K、25T、25B（单层级，选 L2 即为最终型号）
- [x] HXD/SS/DF_HXN（本务机车）已预留占位，标记 `developing: true`，前端点击时 toast 提示"功能开发中"
- [x] `assets/data/train_hierarchy.json` 已更新（含 CR + CRH + Coach + 机车占位）
- [x] `assets/data/railway_bureau.json` 已创建（18 局 + 客运段数据）
- [x] `pubspec.yaml` 已添加 `assets/data/` 声明
- [x] design-document.md 已更新：新增 3.5 设置页字典编辑功能（完整 CRUD，JSON 种子→数据库策略）
- [x] 数据模型已创建：`lib/models/train_hierarchy.dart`、`lib/models/railway_bureau.dart`
- [x] 数据加载服务已创建：`lib/data/train_data_loader.dart`
- [x] Riverpod Provider 已创建：`lib/providers/train_data_provider.dart`
- [x] `lib/main.dart` 已更新：首页显示字典加载统计信息

### 待完成
1. [x] 验证测试：在外部终端运行 `flutter run`，确认首页显示字典加载统计信息
2. [x] 深层验证：CR→CR400→AF→Z 级联走通，CR200J(1.0) series 正确，Coach platforms 正确，HXD developing=true，京局客运段过滤正确

---

## 变更日志

### 2026-04-11 (第十次更新)
- 第 3 步级联选择器 UI 基本完成，但存在已知 Bug
- train_model_picker.dart: 4级级联（L1类别→L2平台→L3系列→L4变体），L4含"无"选项
- bureau_picker.dart: 2级级联（局→客运段）
- entry_page.dart: 录入表单，含车型选择、担当选择、席位选择
- **已知 Bug（席位过滤）**：车底选为 EMU 时席位过滤正常（不显示硬座/软座/硬卧/软卧），但选为 Coach（普速）时坐席和卧席仍显示 EMU 类别（二等座/一等座/商务座/二等卧/一等卧/高级软卧未隐藏）
  - 已尝试：`_filteredSeatTypes()` 逻辑正确、`ValueKey` 强制重建 `DropdownButtonFormField`、`onConfirm` 回调中重置 `_seatType`
  - 根因推测：`DropdownButtonFormField` 在 `setState` 后未完全重建 items 列表，可能需要换用其他控件（如自定义 Chip 组）来替代
  - 优先级：中（功能可用但不完整，后续迭代修复）

### 2026-04-11 (第九次更新)
- 第 2 步验证通过：深层级联数据解析正确
  - CR→CR400→AF: selectable=true, variants=11个
  - CR200J(1.0): series=[1-A, 2-A, 3-A]
  - Coach: platforms=[25G, 25K, 25T, 25B]
  - HXD: developing=true
  - 京局: 3段, 客运3段
- 清理验证代码，main.dart 恢复简洁首页
- 第 2 步标记为 ✅ 已完成

### 2026-04-11 (第八次更新)
- 数据加载与解析代码完成
- lib/models/train_hierarchy.dart: TrainCategory/TrainPlatform/TrainSeries/TrainHierarchy 4级模型
- lib/models/railway_bureau.dart: BureauSection/RailwayBureau/RailwayBureauData 模型
- lib/data/train_data_loader.dart: JSON 加载服务（rootBundle + jsonDecode）
- lib/providers/train_data_provider.dart: Riverpod AsyncNotifierProvider
- lib/main.dart 更新：首页显示字典加载统计（大类数/可用数/局数）
- 清理 .gitkeep 文件（data/models/providers 已有实际代码）

### 2026-04-11 (第七次更新)
- railway_bureau.json 创建完成：18 局 + 客运段数据，所有段标记 category: "客运"
- design-document.md 升级至 v1.2：新增 3.5 设置页字典编辑功能
  - 用户可在设置页对车型字典和客运段字典进行完整 CRUD
  - 数据存储策略：JSON 种子文件首次启动加载到 ObjectBox，后续纯数据库操作
  - 车型选择器从 3 级联动更新为 4 级联动（L1→L2→L3→L4）
  - HXD/SS/DF_HXN 标记 developing，点击 toast 提示
  - CR200J 版本号特殊处理规则

### 2026-04-11 (第六次更新)
- Coach（普速客车车底）数据录入：25G、25K、25T、25B（单层级结构）
- HXD/SS/DF_HXN（本务机车）暂时搁置，JSON 中预留占位并标记 `developing: true`
- 前端选择器中机车入口保留，点击时 toast 提示"功能开发中"
- `train_hierarchy.json` 更新为完整版（CR + CRH + Coach + 机车占位）

### 2026-04-11 (第五次更新)
- 开始第 2 步：构建铁路字典
- 车型级联数据结构从原计划 3 级调整为 4 级（L1→L2→L3→L4），L3 可选即止，L4 为可选变体
- CR（复兴号系列）数据录入完成：CR450、CR400、CR300、CR220J、CR200J(1.0/2.0/3.0)
- CRH（和谐号系列）数据录入完成：CRH380、CRH1、CRH2、CRH3、CRH5、CRH6
- `assets/data/train_hierarchy.json` 已创建（暂含 CR + CRH）
- `pubspec.yaml` 已添加 `assets/data/` 声明
- HXD/SS/DF-HXN/Coach 及 railway_bureau.json 待后续补充

### 2026-04-11 (第四次更新)
- 项目路径已从 `D:\个人文件\VibeCoding\Program\Yunntan_Recorder` 迁移为 `D:\Personal_file\VibeCoding\Program\Yunntan_Recorder`（纯英文路径，解决 aapt 报错问题）
- 数据库方案从 Isar 改为 ObjectBox（Isar 3.x 与 Dart 3.11 不兼容，ObjectBox 完全兼容）
- 同步更新 tech-stack.md、architecture.md、progress.md 中的相关内容

### 2026-04-11 (第三次更新)
- 发现项目路径中文导致 `aapt` 工具报 "Illegal byte sequence"，APK 无法安装到设备
- 需要将项目从 `D:\个人文件\VibeCoding\Program\Yunntan_Recorder` 迁移到 `D:\Projects\Yunntan_Recorder`
- 升级 flex_color_scheme 从 7.3.1 到 8.4.0，适配 V8 API（移除 appBarStyle、blendOnColors、visualDensity；显式设置 interactionEffects 和 tintedDisabledControls）
- 移除 Isar 相关依赖（isar、isar_flutter_libs、isar_generator、path_provider），因与 Dart 3.11 不兼容
- 移除 assets/data/ 声明（避免空目录资源打包警告）
- 添加 `android.overridePathCheck=true` 到 gradle.properties
- APK 构建成功，但安装失败（路径中文问题）

### 2026-04-11 (第二次更新)
- Flutter SDK 迁移至 `D:\Software\Flutter-SDK\flutter\`（解决路径空格问题）
- Flutter 项目创建成功
- Android SDK 版本配置完成（minSdk 21 / targetSdk 34 / compileSdk 34）
- 核心依赖添加到 pubspec.yaml
- 项目目录结构建立（lib/models, providers, pages, widgets, utils, data, assets/data）
- main.dart 替换为 Riverpod + FlexColorScheme (greyLaw) + Material You Hello Ledger 页面
- 测试文件更新

### 2026-04-11 (初始)
- 项目初始化：创建 memory-bank 文档（design-document.md, tech-stack.md, implementation-plan.md）
- Git 仓库初始化，首次提交
- GitHub 私有仓库创建并推送：https://github.com/cheeemmms/Yunntan_Recorder
- 开始第 1 步 Flutter 环境初始化，卡在沙箱环境无法执行 flutter 命令
