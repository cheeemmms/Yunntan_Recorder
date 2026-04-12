# 产品需求文档 (PRD)：铁道运转记录程序 (Train Ledger)
版本：1.4 (MVP)
定位：一款面向硬核铁道迷的本地化、专业级运转记录账本。
设计哲学：极简、专业、数据驱动、去社交化（本地优先）。

## 1. 项目概述
- 目标：提供比 Excel 更专业、比普通记事本更具仪式感的火车运转记录工具。
- 核心受众：追求极致数据记录的铁道迷、车迷。
- 技术栈：Flutter + Riverpod (Android 优先，支持后期移植 iOS)。
- 存储：Local-first (ObjectBox NoSQL 数据库)，不依赖云端服务器。
- Android SDK：minSdkVersion 21 / targetSdkVersion 34 / compileSdkVersion 35。

## 2. 视觉与交互规范
- UI 风格：工业简约风，应用整体严格遵循 Material You (Material 3) 设计规范。
- 动态取色：使用 dynamic_color 包从壁纸提取 ColorScheme，无动态色时回退 greyLaw 工业风。
- 级联选择器：使用 CupertinoPicker（iOS 拨轮风格），以 BottomSheet 形式弹出，兼顾专业感与操作效率。
- 动画规范：严格遵循 MD3 Motion 规范，容器变换 500ms，元素渐显 300ms，使用标准 Easing 曲线。
- 主要交互：
  - 首页：纯运转记录列表，卡片式布局，左右滑动操作，点击展开详情。
  - Dock 栏：
    1. 首页（运转记录列表）
    2. 成就系统（含仪表盘统计）
    3. 设置
  - 录入页：级联选择器 + 列表式表单。

## 3. 功能模块详细说明

### 3.1 首页 (运转记录列表)

**设计变更（v1.4）**：原"仪表盘+历史列表"改为纯列表，仪表盘移至成就页。

- 运转记录列表：按时间倒序展示所有运转记录。
- 卡片布局（紧凑模式）：
  - 左侧：日期（MM-DD）+ 时间（HH:MM）
  - 中间：车次（加粗）+ 类型标签（primaryContainer 胶囊）+ 区间
  - 右侧：车底型号标签（tertiaryContainer 胶囊）+ 箭头图标
- 滑动操作（flutter_slidable）：
  - 左滑：显示编辑按钮（primary 色，圆角 12）
  - 右滑：显示删除按钮（error 色，圆角 12）
  - 互斥：同一时间只能滑开一张卡片
- 点击展开详情（Overlay 火车票样式）：
  - 动画分层（MD3 Motion 规范）：
    - 0-300ms：背景压暗+高斯模糊、卡片上浮 10dp、文字渐显（三者同步完成）
    - 0-500ms：卡片容器从条目位置展开到 88% 屏幕宽度
  - 展开方向：以条目顶部为锚点向下展开
  - 避让状态栏：最小 top = statusBarTop + 16
  - 内容揭示：clipBehavior: Clip.antiAlias 裁剪 + Opacity 渐显
  - 反向动画：沿原路径返回，动画对称流畅
- 详情卡片内容（火车票样式）：
  - Header：车次 + 类型标签 | 日期 + 时间
  - 锯齿分割线
  - 路线：出发站 → 到达站（带火车/定位图标）
  - 锯齿分割线
  - 信息网格（2列）：票价 / 全程 / 席位 / 担当
  - [可选] 锯齿分割线 + 备注
- 空状态：火车图标 + "暂无运转记录" + "点击 + 开始录入运转"
- 筛选功能（待开发）：年份 / 车次等级 / 局段

### 3.2 成就页 (仪表盘 + 成就系统)

**设计变更（v1.4）**：从原"纯成就系统"改为"仪表盘统计 + 成就系统"。

- 仪表盘统计（横向双卡片布局）：
  - 总运转次数（primaryContainer 卡片，headlineLarge 加粗数字）
  - 总花费金额（secondaryContainer 卡片，headlineLarge 加粗数字，¥ 前缀）
  - 使用 IntrinsicHeight 确保双卡片等高
  - FittedBox + scaleDown 确保大数字不溢出
- 成就系统（待开发）：
  - 收集者：车底型号覆盖率 + 进度条
  - 领航者：运转次数勋章（1/10/50/100/200/500/1000/5000 次）

### 3.3 运转录入 (Professional Entry)
坚持专业性，包含以下 12+ 核心字段：
- 车次：手动输入（如 G1）。
- 运转区间：乘车站 -> 到达站（手动输入，乘客实际上下车站）。
- 始发终到站：该次列车的全程起止点（手动输入，全程起点站 -> 全程终点站）。
- 运转时间：精确到分钟的出发时间（DateTime Picker）。
- 票价：货币金额（数字输入）。
- 乘务担当：CupertinoPicker 二级联动（局→段），默认过滤只显示客运段，选择器末尾提供"其他"选项允许手动录入。
- 车次类型：自动识别（根据车次首字母识别：高、动、城、特、直、快等）。
- 席位选择（一级下拉选类别，二级下拉自动过滤）：
  - 坐席：无座、硬座、软座、二等座、一等座、商务座。
  - 卧席：硬卧、软卧、二等卧、一等卧、高级软卧。
- 车底型号（CupertinoPicker 四级联动）：
  - L1: 大类（CR、CRH、HXD、SS、DF/HXN、Coach），每个 L1 带 type 标识（EMU/Loco/Coach）。HXD/SS/DF_HXN 标记为 developing，点击时 toast 提示"功能开发中"。
  - L2: 平台（如 CR400, CRH3, 25T 等）。
  - L3: 系列（如 CR400AF, CRH380A 等），L3 可选即止作为最终型号。
  - L4: 变体（如 Z, AZ 等），可选级别，为空则不显示第四轮。
  - CR200J 特殊处理：选择时显示版本号（如 CR200J(1.0)），记录展示时忽略版本号（如 CR200J1-C）。
- 备注：自由文本输入框。
- 编辑模式：接收 Trip 参数，预填充所有字段（含车型选择器、担当选择器初始值），保存时更新而非新建。

### 3.4 成就系统 (Milestones)
- 收集者 (Collector)：统计车底型号的覆盖率。展示已解锁车型的图标。有照片显示照片，无照片显示通用剪影。展示收集率进度条（已解锁型号 / 总型号）。
- 领航者 (Navigator)：统计运转次数勋章，等级如下（不设置等级名称，仅显示次数）：
  - 1 次 / 10 次 / 50 次 / 100 次 / 200 次 / 500 次 / 1,000 次 / 5,000 次
- 预留扩展：后续引入里程字段后，可新增里程勋章（100 km / 500 km / 1,000 km / 5,000 km / 10,000 km / 50,000 km / 100,000 km），与运转次数勋章并列展示。

### 3.5 数据管理与导出
- 本地图库：内置可维护的车型图片映射库。
- 导出功能：生成标准格式的 CSV 文件（UTF-8 with BOM 编码），直接保存至安卓文件系统。
- 海报生成：MVP 阶段预留入口和开发空间，点击提示"功能开发中"，择机开发升级。

### 3.6 设置页字典编辑
用户可在设置页中对车型字典和客运段字典进行完整的增删改查（CRUD）操作：
- **车型字典管理**：修改 train_hierarchy 中的 L1/L2/L3/L4 数据（增删改车型、平台、系列、变体）。
- **客运段字典管理**：修改 railway_bureau 中的局和段数据（增删改局、段）。
- **数据存储策略**：首次启动时从 JSON 种子文件加载到 ObjectBox 数据库，之后所有操作（读取和编辑）均在数据库上进行，JSON 文件仅作为初始种子数据，不再修改。
- **选择器联动**：字典编辑后，录入页的 CupertinoPicker 选项实时更新。

## 4. 动画设计规范（MD3 Motion）

### 容器变换动画（Container Transform）
- **总时长**：500ms
- **Easing**：easeOutCubic（展开），对称曲线（收起）
- **分层设计**：
  - 第一层（0-300ms）：背景效果 + 位置偏移 + 内容渐显
    - 背景压暗：`Colors.black.withOpacity(0.15 * bgProgress)`
    - 高斯模糊：`ImageFilter.blur(sigmaX: 8 * bgProgress, sigmaY: 8 * bgProgress)`
    - 卡片上浮：`lerpDouble(0, 10, floatProgress)`
    - 文字渐显：`Opacity(opacity: fadeProgress)`
  - 第二层（0-500ms）：容器几何变换
    - 宽度：条目宽度 → 88% 屏幕宽度
    - 左偏移：条目 left → 居中 left
    - 圆角：16 → 24
    - 阴影：0 → blurRadius 20, offset (0, 6)
- **展开方向**：以条目顶部为锚点向下展开
- **内容揭示**：clipBehavior: Clip.antiAlias 裁剪，内容始终渲染，整体 Opacity 渐显
- **反向动画**：沿原路径返回，动画对称流畅

### 进度曲线映射
```
t = controller.value (0.0 → 1.0, 500ms)

bgProgress:    easeOut((t * 500/300).clamp(0, 1))     → 0-300ms
floatProgress: easeOutCubic((t * 500/300).clamp(0, 1)) → 0-300ms
fadeProgress:  easeOut((t * 500/300).clamp(0, 1))      → 0-300ms
expandProgress:easeOutCubic(t)                          → 0-500ms
```

## 5. 数据架构 (Schema-less Thinking)
使用 JSONB 逻辑存储 Trip 对象：
```json
{
  "id": "uuid",
  "train_no": "G1",
  "route": {"from": "SHA", "to": "BPN"},
  "origin_destination": {"origin": "SHH", "destination": "BJS"},
  "time": "2023-10-27 09:00",
  "price": 553.0,
  "operator": {"bureau": "京局", "section": "京段"},
  "seat": {"category": "坐席", "type": "二等座"},
  "train_model": {
    "category": "CR",
    "platform": "CR400",
    "version": "AF-Z",
    "type": "EMU"
  },
  "remarks": "首发体验",
  "extra_fields": {}
}
```

## 6. 项目路线图 (Roadmap)
- Phase 1: 搭建 Flutter 基础框架，完成本地数据库 (ObjectBox) 配置，引入 Riverpod 状态管理。 ✅
- Phase 2: 开发 CupertinoPicker 级联选择器与专业录入表单。 ✅（有已知 Bug）
- Phase 3: 实现运转记录列表、卡片交互、滑动操作、详情展开动画。 ✅（筛选待开发）
- Phase 4: 仪表盘统计 + 成就系统 UI 开发。 🔶（仪表盘已完成，成就待开发）
- Phase 5: 车型图库集成。 ⬜
- Phase 6: CSV 导出（UTF-8 with BOM）与海报分享入口预留。 ⬜
