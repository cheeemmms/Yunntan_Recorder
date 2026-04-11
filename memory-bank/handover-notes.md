# 工作交接笔记

> 最后更新：2026-04-11
> 用途：记录当前开发状态、已知问题、调试思路，方便会话切换时快速恢复上下文

---

## 当前整体进度

| 步骤 | 状态 | 备注 |
|------|------|------|
| 第 1 步：Flutter 环境初始化 | ✅ | |
| 第 2 步：构建铁路字典 | ✅ | |
| 第 3 步：级联选择器 UI | 🔶 基本完成 | 有已知 Bug |
| 第 4 步：全字段表单布局 | 🔶 基本完成 | 与第 3 步合并实现 |
| 第 5 步：ObjectBox 数据库集成 | ⬜ | 下一步 |
| 第 6-12 步 | ⬜ | |

---

## 已实现文件清单

### 数据层
| 文件 | 说明 |
|------|------|
| `assets/data/train_hierarchy.json` | 车型级联数据（CR/CRH/Coach + 机车占位） |
| `assets/data/railway_bureau.json` | 18局客运段数据 |
| `lib/models/train_hierarchy.dart` | TrainCategory/TrainPlatform/TrainSeries/TrainHierarchy |
| `lib/models/railway_bureau.dart` | BureauSection/RailwayBureau/RailwayBureauData |
| `lib/data/train_data_loader.dart` | JSON 加载服务（rootBundle + jsonDecode） |
| `lib/providers/train_data_provider.dart` | Riverpod AsyncNotifierProvider |

### UI 层
| 文件 | 说明 |
|------|------|
| `lib/main.dart` | 入口：BottomNav + FAB → EntryPage |
| `lib/pages/entry_page.dart` | 录入表单（12+ 字段） |
| `lib/widgets/train_model_picker.dart` | 4级级联车型选择器（CupertinoPicker） |
| `lib/widgets/bureau_picker.dart` | 2级级联担当选择器（CupertinoPicker） |

---

## 🔴 已知 Bug：席位过滤不生效（Coach 时仍显示 EMU 席位）

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

### 当前代码逻辑（entry_page.dart）

```dart
bool get _isCoach => _trainModel?.category.type == 'Coach';
bool get _isEMU => _trainModel?.category.type == 'EMU';

List<String> _filteredSeatTypes(String category) {
  final all = _allSeatTypes[category]!;
  if (_trainModel == null || _isCoach) return all;
  if (_isEMU) return all.where((t) => !{'硬座', '软座', '硬卧', '软卧'}.contains(t)).toList();
  return all;
}
```

**逻辑本身是正确的**：`_isCoach` 为 true 时返回全部列表。问题出在 Flutter 的 `DropdownButtonFormField` 控件行为上。

### 已尝试的修复方案（均未解决）

1. **在 `build()` 中修正 `_seatType`**：当 `_seatType` 不在过滤后列表中时自动选第一个
   - 结果：无效，`build()` 中修改 state 不可靠

2. **给 `DropdownButtonFormField` 加 `ValueKey`**：`ValueKey('seat_${_trainModel?.category.type ?? 'none'}')`，车型切换时 key 变化强制重建
   - 结果：无效，key 变化后 widget 确实重建了，但 items 列表似乎没有正确更新

3. **在 `onConfirm` 回调中重置 `_seatType`**：
   ```dart
   onConfirm: (r) => setState(() {
     _trainModel = r;
     final valid = _filteredSeatTypes(_seatCategory);
     if (!valid.contains(_seatType)) {
       _seatType = valid.first;
     }
   }),
   ```
   - 结果：`_seatType` 确实被重置了，但 `DropdownButtonFormField` 的 items 列表没有更新

### 根因分析

`DropdownButtonFormField` 在 `setState` 触发 rebuild 时，如果 `value` 在新 `items` 中存在，控件可能不会重新渲染 items 列表。这是 Flutter 框架层面的优化行为——当 value 不变时，控件认为不需要更新下拉选项。

**关键线索**：从 EMU 切换到 Coach 时，`_seatType`（如"二等座"）在 Coach 的完整列表中也存在，所以 `DropdownButtonFormField` 认为 value 没变、items 也不需要变，导致仍然显示 EMU 过滤后的短列表。

### 建议的修复方向

1. **方案 A：替换为自定义 Chip 组**
   - 用 `Wrap` + `ChoiceChip` 替代 `DropdownButtonFormField`
   - 每个 seat type 渲染为一个 Chip，点击选中
   - 优点：完全控制渲染，不受 DropdownButtonFormField 缓存影响
   - 缺点：UI 风格变化

2. **方案 B：使用 StatefulBuilder 包裹**
   - 在 `_buildDropdown` 内部使用 `StatefulBuilder`，手动管理 items 状态
   - 当车型变化时，通过 builder 的 setState 强制刷新

3. **方案 C：强制销毁重建整个 Row**
   - 给席位区域的 `Row` 加 `ValueKey(_trainModel?.category.type ?? 'none')`
   - 这样整个 Row 在车型变化时会被销毁重建
   - 最简单粗暴，但可能有动画闪烁

4. **方案 D：调试 DropdownButtonFormField 内部状态**
   - 在 `_buildDropdown` 中打印 items 和 value，确认传入参数是否正确
   - 如果参数正确但 UI 不更新，说明是框架 bug，需要用 GlobalKey 或其他方式绕过

---

## 🟢 已验证正常的功能

### 车型选择器 (train_model_picker.dart)
- 4级级联联动正常：L1(类别) → L2(平台) → L3(系列) → L4(变体)
- L4 "无"选项正常：选"无"时 variant 为 null，displayLabel 只显示系列名
- L1 切换时 L2/L3/L4 正确重置
- developing 类别（HXD/SS/DF_HXN）点击确认时 toast 提示"功能开发中"
- 初始值回显正常

### 担当选择器 (bureau_picker.dart)
- 2级级联联动正常：局 → 客运段
- L1 切换时 L2 正确重置
- 空列表显示占位文字

### 表单布局 (entry_page.dart)
- 12+ 字段全部布局完成
- 车次自动识别类型（G→高速动车等）
- 出发时间 DatePicker + TimePicker
- EMU 席位过滤正常

---

## 下一步计划：第 5 步 ObjectBox 数据库集成

### 需要做的事情
1. 添加 ObjectBox 依赖到 pubspec.yaml
2. 创建 Trip 实体模型（字段与表单一一对应）
3. 运行 `flutter pub run build_runner build` 生成 ObjectBox 代码
4. 初始化 ObjectBox Store（单例模式）
5. 创建 Repository 层封装 CRUD
6. 连接 EntryPage 的保存按钮到数据库写入
7. 验证：保存 → 重启 → 数据仍在

### Trip 模型字段规划
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | ObjectBox 自增主键 |
| trainNo | String | 车次 |
| boardStation | String | 乘车站 |
| alightStation | String | 到达站 |
| originStation | String | 始发站 |
| destStation | String | 终到站 |
| departureTime | DateTime | 出发时间 |
| price | double | 票价 |
| trainCategoryKey | String | 车型 L1 key |
| trainPlatformKey | String? | 车型 L2 key |
| trainSeriesKey | String? | 车型 L3 key |
| trainVariant | String? | 车型 L4 变体 |
| bureauKey | String? | 担当局 |
| sectionName | String? | 担当段 |
| seatCategory | String | 席位类别（坐席/卧席） |
| seatType | String | 席位类型 |
| remarks | String | 备注 |

---

## 环境信息

- Flutter SDK: `D:\Software\Flutter-SDK\flutter\`
- 项目路径: `D:\Personal_file\VibeCoding\Program\Yunntan_Recorder`
- GitHub: https://github.com/cheeemmms/Yunntan_Recorder
- 用户有科学上网工具，网络问题切换代理节点即可
- Flutter 命令需在外部终端执行（设置 PATH 后）
