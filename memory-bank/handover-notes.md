# 工作交接笔记

> 最后更新：2026-04-12
> 用途：记录当前开发状态、已知问题、调试思路，方便会话切换时快速恢复上下文

---

## 当前整体进度

| 步骤 | 状态 | 备注 |
|------|------|------|
| 第 1 步：Flutter 环境初始化 | ✅ | |
| 第 2 步：构建铁路字典 | ✅ | |
| 第 3 步：级联选择器 UI | 🔶 基本完成 | 有已知 Bug（席位过滤） |
| 第 4 步：全字段表单布局 | 🔶 基本完成 | 与第 3 步合并实现，新增到达时间字段 |
| 第 5 步：ObjectBox 数据库集成 | ✅ | Trip 模型新增 arrivalTime 字段，需重新 build_runner |
| 第 6 步：数据存取流程闭环 | ✅ | 编辑/删除/预填充 |
| 第 7 步：全屏仪表盘 Dashboard | ✅ | 已移至成就页 |
| 第 8 步：历史记录流与筛选 | ✅ | 列表+卡片+滑动+动画+到达时间+筛选+回到顶部 |
| 第 9 步：车型照片映射系统 | ⬜ | |
| 第 10 步：成就统计页面 | 🔶 部分完成 | 2×2网格+总运转时长+领航者+收集者进度条已完成 |
| 第 11 步：CSV 导出功能 | ⬜ | |
| 第 12 步：海报分享功能 | ⬜ | |

---

## 已实现文件清单

### 数据层
| 文件 | 说明 |
|------|------|
| `assets/data/train_hierarchy.json` | 车型级联数据（CR/CRH/Coach + 机车占位） |
| `assets/data/railway_bureau.json` | 18局客运段数据 |
| `lib/models/train_hierarchy.dart` | TrainCategory/TrainPlatform/TrainSeries/TrainHierarchy |
| `lib/models/railway_bureau.dart` | BureauSection/RailwayBureau/RailwayBureauData |
| `lib/models/trip.dart` | Trip 实体（ObjectBox @Entity，18 个字段） |
| `lib/data/train_data_loader.dart` | JSON 加载服务（rootBundle + jsonDecode） |
| `lib/providers/train_data_provider.dart` | Riverpod AsyncNotifierProvider（字典数据） |
| `lib/providers/trip_provider.dart` | ObjectBoxInstance + FutureProvider + TripListNotifier（CRUD） |
| `lib/objectbox.g.dart` | ObjectBox 代码生成（build_runner 自动生成） |
| `lib/objectbox-model.json` | ObjectBox 模型定义 |

### UI 层
| 文件 | 说明 |
|------|------|
| `lib/main.dart` | 应用入口：DynamicColorBuilder + FlexThemeData + MainShell（BottomNav + FAB含回到顶部）+ HomePage（列表 + Slidable互斥 + 筛选面板 + BottomSheet多选） |
| `lib/pages/entry_page.dart` | 录入表单（12+ 字段），支持新建/编辑模式，编辑时预填充车型和担当 |
| `lib/pages/achievement_page.dart` | 成就页：仪表盘统计（总运转次数 + 总花费金额）+ 成就系统占位 |
| `lib/widgets/trip_card.dart` | TripCard 组件：紧凑列表卡片 + Slidable 滑动 + Overlay 详情展开动画 |
| `lib/widgets/train_model_picker.dart` | 4级级联车型选择器（CupertinoPicker） |
| `lib/widgets/bureau_picker.dart` | 2级级联担当选择器（CupertinoPicker） |

---

## 核心实现：TripCard 动画系统

### 架构概览

TripCard 是本项目最复杂的 UI 组件，包含三层交互：

1. **Slidable 层**：左右滑动显示编辑/删除按钮
2. **Card 层**：紧凑列表卡片，显示核心信息
3. **Overlay 层**：点击卡片后全屏展开详情（火车票样式）

### 动画分层（MD3 Motion 规范）

AnimationController 总时长 500ms，4 条独立进度曲线：

```
时间轴: 0ms ─────────── 300ms ────────────── 500ms
bgProgress:    ████████████████░░░░░░░░░░░░░  (easeOut)
floatProgress: ████████████████░░░░░░░░░░░░░  (easeOutCubic)
fadeProgress:  ████████████████░░░░░░░░░░░░░  (easeOut)
expandProgress:████████████████████████████████ (easeOutCubic)
```

- **0-300ms 同步完成**：背景压暗+模糊、卡片上浮 10dp、文字渐显
- **0-500ms 持续展开**：卡片宽度从条目宽度→88%屏幕宽、圆角 16→24、阴影渐增

### 关键技术点

| 技术点 | 实现方式 |
|--------|----------|
| 获取条目位置 | `RenderBox.localToGlobal(Offset.zero)` 获取 sourceRect |
| 全屏覆盖 | `Overlay.of(context).insert(OverlayEntry(...))` |
| 背景模糊 | `BackdropFilter(filter: ImageFilter.blur(...))` |
| 避让状态栏 | `minTop = MediaQuery.padding.top + 16` |
| 内容裁剪揭示 | `clipBehavior: Clip.antiAlias` + 不设固定高度 |
| 文字渐显 | 整体 `Opacity(opacity: fadeProgress)` 包裹 |
| 反向动画 | `_animController.reverse().then(() => _removeOverlay())` |
| Slidable 互斥 | `RegisterCloseCallback` 回调注册模式 |

### _TicketOverlay 构建流程

```
AnimatedBuilder
  └─ Stack
       ├─ GestureDetector (点击关闭)
       │    └─ BackdropFilter (bgProgress 控制模糊度)
       │         └─ Container (bgProgress 控制压暗度)
       └─ Positioned (left/top/width 自适应)
            └─ Container (surfaceContainerHigh + 圆角 + 阴影)
                 └─ Clip.antiAlias
                      └─ _TicketContent (fadeProgress 控制整体透明度)
```

### _TicketContent 布局

```
Padding(20)
  └─ Opacity(fadeProgress)
       └─ Column(mainAxisSize: min)
            ├─ Header: 车次 + 类型标签 | 日期 + 时间
            ├─ Divider (锯齿线)
            ├─ Route: 出发站 → 到达站
            ├─ Divider
            ├─ InfoGrid: 票价/全程/席位/担当 (2列布局)
            ├─ [Divider + 备注] (可选)
            └─ SizedBox(4)
```

---

## 🔴 已知 Bug

### 1. 席位过滤已修复（2026-04-13）

### 问题描述
- 选 EMU 车型时：席位过滤**正常**，不显示硬座/软座/硬卧/软卧 ✅
- 选 Coach 车型时：坐席和卧席**仍显示 EMU 类别**（二等座/一等座/商务座/二等卧/一等卧/高级软卧未隐藏）❌
- 未选车型时：显示全部席位 ✅

### 期望行为
| 车型 | 坐席 | 卧席 |
|------|------|------|
| 未选 | 全部 | 全部 |
| EMU | 无座, 二等座, 一等座, 商务座 | 二等卧, 一等卧, 高级软卧 |
| Coach | 无座, 硬座, 软座, 二等座, 一等座, 商务座 | 硬卧, 软卧, 二等卧, 一等卧, 高级软卧 |

### 根因分析

`DropdownButtonFormField` 在 `setState` 触发 rebuild 时，如果 `value` 在新 `items` 中存在，控件可能不会重新渲染 items 列表。从 EMU 切换到 Coach 时，`_seatType`（如"二等座"）在 Coach 的完整列表中也存在，所以控件认为 value 没变、items 也不需要变。

### 建议的修复方向

1. **方案 A：替换为自定义 Chip 组** — `Wrap` + `ChoiceChip`，完全控制渲染
2. **方案 B：StatefulBuilder 包裹** — 手动管理 items 状态
3. **方案 C：强制销毁重建** — 给席位区域加 `ValueKey`，车型变化时销毁重建（✅ 已采用，含车型类型+类别+列表长度）

---

## 🟡 待优化项

### TripCard 动画
- 当前卡片高度不固定（使用 `mainAxisSize: MainAxisSize.min`），展开过程中高度由内容决定
- 如果未来需要更精确的高度动画，可考虑在 Overlay 中测量内容高度后做 lerpDouble 插值
- 文字渐显目前是整体 Opacity，如需更精细可改为分段渐显（header 先显，info 后显）

### 筛选功能（第 8 步 — 已完成）
- 4 维度筛选：年份（多选）、车底型号（级联多选）、席位类型（多选）、局段（多选）
- 筛选面板通过 AppBar 图标按钮展开/收起
- 每个维度点击 InputChip 打开 BottomSheet（CheckboxListTile 多选）
- 车底型号 BottomSheet 支持级联：勾选一级后立即展开二级
- 重置按钮一键清除所有筛选
- 内存过滤逻辑，不改动 ObjectBox 查询

---

## 🟢 已验证正常的功能

### 车型选择器 (train_model_picker.dart)
- 4级级联联动正常：L1(类别) → L2(平台) → L3(系列) → L4(变体)
- L4 "无"选项正常
- developing 类别点击确认时 toast 提示
- 初始值回显正常

### 担当选择器 (bureau_picker.dart)
- 2级级联联动正常：局 → 客运段
- L1 切换时 L2 正确重置

### 表单布局 (entry_page.dart)
- 12+ 字段全部布局完成
- 车次自动识别类型
- 编辑模式预填充正常（车型、担当、席位等）
- 保存逻辑：有 id 更新，无 id 新建

### 数据库 (trip_provider.dart)
- ObjectBox 初始化正常
- CRUD 全部正常
- 数据持久化正常

### TripCard 交互 (trip_card.dart)
- 紧凑卡片布局正常
- Slidable 左滑编辑、右滑删除正常
- Slidable 互斥正常（同时只能滑开一张）
- 点击展开详情动画正常（顶部锚点 + 上浮 + 背景模糊 + 文字渐显）
- 反向关闭动画正常
- 避让状态栏正常
- 荧光色双下划线已修复

### 成就页 (achievement_page.dart)
- 2×2 网格统计卡片正常（总运转次数 + 总花费金额 + 总运转时长 + 成就系统入口）
- 成就系统卡片点击进入二级页面
- 二级页面包含收集者和领航者入口
- 领航者页面：3列网格勋章展示（1/10/50/100/200/500/1000/5000 次）
- 收集者页面：占位，显示已收集车型数量

### 收集者页面 (achievement_page.dart)
- 进度卡片：已收集类型 / 全部类型 + 百分比进度条
- 全车型网格：已收集高亮（primaryContainer 实心图标），未收集灰色（surfaceContainerLow 空心图标）
- 从 train_hierarchy 遍历全部车型（CR/CRH 按系列计数，Coach 按平台计数）

### 筛选功能 (main.dart)
- AppBar 筛选图标展开/收起筛选面板（AnimatedSize 动画）
- 4 维度 InputChip：年份、车底型号、席位类型、局段
- 点击 InputChip 打开 BottomSheet（CheckboxListTile 多选）
- 车底型号 BottomSheet 支持级联：勾选一级后立即展开二级
- 重置按钮一键清除所有筛选
- 回到顶部按钮：滚动超过 200px 显示，FAB 位于 MainShell

### 动态取色 (main.dart)
- DynamicColorBuilder 正常提取壁纸色
- 无动态色时回退 greyLaw

---

## 下一步计划

### 优先级 1：重新运行 build_runner
- Trip 模型新增了 `arrivalTime` 字段，必须重新运行 `dart run build_runner build`
- 否则编译会失败

### 优先级 2：第 11 步 CSV 导出
- 将数据库所有 Trip 对象导出为 CSV 文件（UTF-8 with BOM）

### 优先级 3：第 9 步车型照片映射系统
- 车型图标展示实际照片，无照片时显示通用剪影

---

## 环境信息

- Flutter SDK: `D:\Software\Flutter-SDK\flutter\`
- 项目路径: `D:\Personal_file\VibeCoding\Program\Yunntan_Recorder`
- GitHub: https://github.com/cheeemmms/Yunntan_Recorder
- 用户有科学上网工具，网络问题切换代理节点即可
- Flutter 命令需在外部终端执行（设置 PATH 后）

### 外部终端执行 Flutter 命令的模板

```powershell
$env:PATH = "D:\Software\Flutter-SDK\flutter\bin;" + $env:PATH; cd "D:\Personal_file\VibeCoding\Program\Yunntan_Recorder"

flutter pub get          # 拉取依赖
flutter run              # 运行到设备
flutter run --release    # Release 模式运行
flutter clean            # 清理构建缓存
flutter build apk        # 构建 APK
dart run build_runner build  # ObjectBox 代码生成
```
