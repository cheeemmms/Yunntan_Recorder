# 项目进度跟踪

## 规则
- 每完成 implementation-plan.md 中的一个步骤，必须更新本文档并提交 Git。

## 当前进度

| 阶段 | 步骤 | 状态 |
|------|------|------|
| 第一阶段：项目地基与静态字典 | 第 1 步：Flutter 环境初始化 | ✅ 已完成 |
| | 第 2 步：构建铁路字典 (JSON) | ✅ 已完成 |
| 第二阶段：核心记录表单 | 第 3 步：级联选择器 UI | 🔶 基本完成（有已知Bug） |
| | 第 4 步：全字段表单布局 | 🔶 基本完成（与第3步合并） |
| 第三阶段：本地存储引擎 | 第 5 步：ObjectBox 数据库集成 | ✅ 已完成 |
| | 第 6 步：数据存取流程闭环 | ✅ 已完成 |
| 第四阶段：首页总结与列表 | 第 7 步：全屏仪表盘 Dashboard | ✅ 已完成（移至成就页） |
| | 第 8 步：历史记录流与筛选 | 🔶 部分完成（列表+卡片+滑动操作，筛选待开发） |
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
- `flutter_riverpod: ^3.3.1` — 状态管理
- `flex_color_scheme: ^8.4.0` — Material You 主题（greyLaw 工业风）
- `json_annotation: ^4.9.0` — JSON 序列化注解
- `freezed_annotation: ^3.1.0` — 不可变数据类注解
- `objectbox: ^5.2.0` — NoSQL 本地数据库
- `objectbox_flutter_libs: ^5.2.0` — ObjectBox Flutter 平台库
- `path_provider: ^2.1.0` — 应用文档目录路径
- `flutter_slidable: ^4.0.0` — 滑动操作（左滑编辑、右滑删除）
- `dynamic_color: ^1.7.0` — Material You 动态取色（壁纸色适配）

**开发依赖：**
- `freezed: ^3.2.5` — 不可变数据类代码生成
- `json_serializable: ^6.8.0` — JSON 序列化代码生成
- `build_runner: ^2.4.0` — 代码生成工具
- `objectbox_generator: ^5.2.0` — ObjectBox 代码生成

**暂未引入（后续步骤需要时再添加）：**
- `csv` — 第 11 步 CSV 导出时引入

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
| objectbox_flutter_libs 要求 compileSdk 35 | `build.gradle.kts` 中 compileSdk 从 34 升级到 35 |
| objectbox.g.dart import 路径错误 | 生成文件在 `lib/` 下，import 路径修正为 `../objectbox.g.dart` |
| trip_provider 引用 main.dart 全局变量导致循环依赖 | 重构：ObjectBox 初始化合并到 trip_provider.dart，使用 FutureProvider 管理 |

### 注意事项
- **用户有科学上网工具**：遇到 Gradle/Maven/Pub 网络问题（SSL 握手失败、下载超时等），只需提醒用户切换代理节点即可，无需配置国内镜像
- Flutter 命令需在外部终端执行（设置 PATH 后）
- `build.gradle.kts` 中的 `minSdk = flutter.minSdkVersion` 会被 `flutter` 命令重置，无需反复手动改为 21（新版 Flutter 默认就是 21）
- Isar 3.x 与当前 Dart SDK 不兼容，已改用 ObjectBox 替代
- 项目已迁移至纯英文路径 `D:\Personal_file\VibeCoding\Program\Yunntan_Recorder`
- **ObjectBox 代码生成**：修改 Trip 实体后必须重新运行 `dart run build_runner build`，否则编译会失败
- **compileSdk 已升级到 35**：objectbox_flutter_libs 要求 SDK 35，`build.gradle.kts` 中 compileSdk = 35

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

### 2026-04-12 (第十三次更新) — 到达时间 + 成就页改造

**数据模型变更：Trip 新增 arrivalTime 字段**
- `lib/models/trip.dart`：新增 `DateTime? arrivalTime` 字段（ObjectBox @Property(type: PropertyType.date)）
- 需重新运行 `dart run build_runner build` 生成 ObjectBox 代码

**录入页新增到达时间选择器**
- `lib/pages/entry_page.dart`：在出发时间下方新增到达时间选择器
- 支持日期+时间选择，可清除（设为 null），编辑模式预填充
- 到达时间为可选字段，未填写时显示"未填写"

**首页条目排版调整**
- `lib/widgets/trip_card.dart`：_buildCompact 方法改造
- 左侧时间区域：日期 → 出发时间 → Icon(Icons.south) → 到达时间
- 跨天处理：到达时间前显示小字"+1"（浅色，紧贴时间，水平对齐）
- 无到达时间时不显示箭头和到达时间

**详情卡片排版调整**
- `_TicketContent._buildHeader`：时间显示从 `12:56` 改为 `12:56→13:00`
- 箭头上方小字显示自动计算的时长（如"4分钟"、"2小时30分钟"）
- 跨天处理：到达时间前显示小字"+N"
- 未填到达时间时仅显示出发时间（保持原样）
- 动画系统未改动

**成就页改造**
- `lib/pages/achievement_page.dart`：完全重写
- 2×2 网格布局：总运转次数 / 总花费金额 / 总运转时长 / 成就系统
- 总运转时长：自动计算所有有到达时间的运转记录的时长总和
- 成就系统卡片：点击进入二级页面（_AchievementDetailPage）
- 二级页面包含收集者（车型覆盖率）和领航者（运转次数勋章）入口
- 领航者页面：3列网格展示 1/10/50/100/200/500/1000/5000 次勋章
- 收集者页面：占位，显示已收集车型数量

### 2026-04-12 (第十二次更新) — UI 重设计 + 动画系统 + 数据闭环

**重大架构变更：首页与成就页重新分工**

原设计：首页 = 仪表盘 + 历史列表；成就页 = 成就系统
新设计：首页 = 纯运转记录列表（卡片式）；成就页 = 仪表盘统计 + 成就系统

**第 6 步：数据存取流程闭环 ✅**
- 编辑功能：点击历史记录卡片 → 进入 EntryPage 预填充已有数据 → 保存时更新
- 删除功能：右滑卡片显示删除按钮 → 确认弹窗 → 删除记录
- EntryPage 支持接收 Trip 参数，编辑模式下预填充所有字段（含车型选择器、担当选择器）
- 保存逻辑：有 id 则 updateTrip，无 id 则 addTrip

**第 7 步：仪表盘 Dashboard ✅（移至成就页）**
- 统计指标：总运转次数、总花费金额（横向双卡片布局）
- 使用 IntrinsicHeight 确保双卡片等高
- primaryContainer / secondaryContainer 配色区分两张卡片
- FittedBox + scaleDown 确保大数字不溢出

**第 8 步：历史记录流 🔶（部分完成）**
- ✅ ListView.builder 展示运转记录卡片（按时间倒序）
- ✅ TripCard 紧凑布局：日期时间 | 车次+类型标签 | 区间 | 车底标签
- ✅ Slidable 滑动操作：左滑编辑、右滑删除（BehindMotion，圆角12）
- ✅ Slidable 互斥：同一时间只能滑开一张卡片
- ✅ 点击卡片展开详情（Overlay 火车票样式）
- ⬜ 筛选功能（年份/车次等级/局段）待开发

**TripCard 动画系统（核心实现）**

动画架构：AnimationController 500ms + 4 条独立进度曲线

| 进度函数 | 时长 | 曲线 | 控制对象 |
|----------|------|------|----------|
| `_bgProgress` | 0-300ms | easeOut | 背景压暗 + 高斯模糊 |
| `_floatProgress` | 0-300ms | easeOutCubic | 卡片上浮 10dp |
| `_fadeProgress` | 0-300ms | easeOut | 文字渐显 |
| `_expandProgress` | 0-500ms | easeOutCubic | 卡片宽度/圆角/阴影展开 |

动画分层设计（遵循 MD3 Motion 规范）：
1. **0-300ms**：背景压暗+模糊、卡片上浮、文字渐显 三者同步完成
2. **0-500ms**：卡片容器从条目位置平滑展开到目标宽度 88% 屏幕
3. **展开方向**：以条目顶部为锚点向下展开，同时略微上浮 10dp
4. **内容揭示**：容器 clipBehavior: Clip.antiAlias 裁剪，内容始终渲染，整体 Opacity 渐显
5. **反向动画**：沿原路径返回，动画对称流畅

Overlay 实现：
- 使用 RenderBox.localToGlobal 获取条目在屏幕中的精确位置
- OverlayEntry 插入全屏层，Stack 布局：底层 BackdropFilter + 上层 Positioned 卡片
- 避让状态栏：`minTop = statusBarTop + 16`
- 点击背景关闭：GestureDetector.onTap → reverse 动画 → 移除 OverlayEntry

**Material You 动态取色**
- 引入 `dynamic_color: ^1.7.0`
- DynamicColorBuilder 包裹 MaterialApp，从壁纸提取 ColorScheme
- 有动态色时覆盖 FlexThemeData 的 colorScheme，无动态色时回退 greyLaw

**已修复的问题**

| 问题 | 解决方案 |
|------|----------|
| 主题不跟随壁纸色 | 引入 dynamic_color 包，DynamicColorBuilder 提取壁纸色覆盖 colorScheme |
| SlidableController 构造函数需要 TickerProvider | 从 GlobalKey\<SlidableState\> 改为 SlidableController(this) |
| 多个 AnimationController 导致 ticker 冲突 | SingleTickerProviderStateMixin → TickerProviderStateMixin |
| HomePage 无法访问 _TripCardState 私有类 | 实现 RegisterCloseCallback typedef，避免直接访问私有 State |
| Slidable 不互斥（多张卡片可同时滑开） | 回调注册模式：新卡片滑开时先关闭上一张 |
| 左滑后大幅右滑直接跳到删除按钮 | Slidable v4 默认行为，符合预期（先回到初始状态需用户自行控制滑动幅度） |
| 荧光色双下划线（debug 和 release 均出现） | 所有 TextStyle 显式设置 `decoration: TextDecoration.none` |
| 第一条条目滑动抽动 | 移除 initState 中过早的 registerClose 调用，仅在 slider 实际打开时注册 |
| 卡片展开侵入状态栏 | 计算 statusBarTop，设置 minTop = statusBarTop + 16 |
| 卡片从无限远放大 | 使用 RenderBox 获取条目精确位置作为动画起点 |
| 卡片向上移动后向下展开 | 改为以条目顶部为锚点向下展开 + 上浮 10dp |
| 成就页卡片高度不一致 | IntrinsicHeight 包裹 Row |
| 编辑模式不预填车型和担当 | EntryPage 接收 Trip 参数时解析 trainModel/bureau 并设置初始值 |

**新增/修改文件清单**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/widgets/trip_card.dart` | 新增 | TripCard 组件 + _TicketOverlay + _TicketContent，含完整动画系统 |
| `lib/pages/achievement_page.dart` | 重写 | 仪表盘统计（总运转次数+总花费金额）+ 成就系统占位 |
| `lib/main.dart` | 重写 | DynamicColorBuilder + HomePage 纯列表 + Slidable 互斥 + MainShell 导航 |
| `lib/pages/entry_page.dart` | 修改 | 编辑模式预填充逻辑（车型选择器、担当选择器初始值） |
| `pubspec.yaml` | 修改 | 新增 flutter_slidable ^4.0.0、dynamic_color ^1.7.0 |

### 2026-04-11 (第十一次更新)
- 第 5 步 ObjectBox 数据库集成完成，验证通过
- 新增文件：
  - `lib/models/trip.dart` — Trip 实体（@Entity + @Id + PropertyType.date，18 个字段）
  - `lib/providers/trip_provider.dart` — ObjectBoxInstance 单例 + FutureProvider + TripListNotifier（CRUD）
  - `lib/objectbox.g.dart` — ObjectBox 代码生成（build_runner 自动生成）
  - `lib/objectbox-model.json` — ObjectBox 模型定义
- 修改文件：
  - `pubspec.yaml` — 新增 objectbox ^5.2.0、objectbox_flutter_libs ^5.2.0、path_provider ^2.1.0、objectbox_generator ^5.2.0；riverpod 升级到 ^3.3.1、freezed_annotation 升级到 ^3.1.0、freezed 升级到 ^3.2.5
  - `android/app/build.gradle.kts` — compileSdk 从 34 升级到 35
  - `lib/main.dart` — 移除 ObjectBox 手动初始化（改为 FutureProvider 管理），HomePage 显示已保存记录数
  - `lib/pages/entry_page.dart` — 保存按钮连接数据库写入，车次必填校验
- 删除文件：
  - `lib/data/objectbox.dart` — 逻辑合并到 trip_provider.dart
- design-document.md 升级至 v1.3：仪表盘指标改为年运转次数/总花费金额/已运转车底数量（预留扩展），成就系统领航者改为运转次数勋章
- implementation-plan.md、handover-notes.md 同步更新

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
