# 产品需求文档 (PRD)：铁道运转记录程序 (Train Ledger)
版本：1.1 (MVP)
定位：一款面向硬核铁道迷的本地化、专业级运转记录账本。
设计哲学：极简、专业、数据驱动、去社交化（本地优先）。

## 1. 项目概述
- 目标：提供比 Excel 更专业、比普通记事本更具仪式感的火车运转记录工具。
- 核心受众：追求极致数据记录的铁道迷、车迷。
- 技术栈：Flutter + Riverpod (Android 优先，支持后期移植 iOS)。
- 存储：Local-first (Isar NoSQL 数据库)，不依赖云端服务器。
- Android SDK：minSdkVersion 21 / targetSdkVersion 34 / compileSdkVersion 34。

## 2. 视觉与交互规范
- UI 风格：工业简约风，应用整体严格遵循 Material You (Material 3) 设计规范。
- 级联选择器：使用 CupertinoPicker（iOS 拨轮风格），以 BottomSheet 形式弹出，兼顾专业感与操作效率。
- 主要交互：
  - 首页：全屏"仪表盘"展示统计数据，下滑展示历史记录列表。
  - Dock 栏：
    1. 首页(仪表盘+列表)
    2. 成就系统
    3. 设置
  - 录入页：级联选择器 + 列表式表单。

## 3. 功能模块详细说明
### 3.1 首页 (Dashboard & History)
- 全屏仪表盘：开屏即见，展示核心统计维度：
  - 总运转里程（km）
  - 总运转次数
  - 已运转车底数量（去重统计不同车底型号的数量）
- 历史记录列表：仪表盘下滑触发，展示历史票单。
- 筛选功能：提供下拉菜单，支持以下筛选维度（可组合使用）：
  - 年份
  - 车次等级（G/D/C/Z/T/K 等）
  - 局段
- 卡片内容：车次、日期、区间、车型、席位。
- 编辑功能：点击历史记录卡片可进入编辑页，预填充已有数据，保存时更新而非新建。

### 3.2 运转录入 (Professional Entry)
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
- 车底型号（CupertinoPicker 三级联动）：
  - L1: 大类（CR、CRH、HXD、SS、DF/HXN、Coach），每个 L1 带 type 标识（EMU/Loco/Coach）。
  - L2: 平台（如 CR400, CRH3, 25T 等）。
  - L3: 细分型号（如 CR400AF-Z, CRH380AL 等）。
- 备注：自由文本输入框。

### 3.3 成就系统 (Milestones)
- 收集者 (Collector)：统计车底型号的覆盖率。展示已解锁车型的图标。有照片显示照片，无照片显示通用剪影。展示收集率进度条（已解锁型号 / 总型号）。
- 领航者 (Navigator)：统计里程勋章，等级如下（不设置等级名称，仅显示公里数）：
  - 100 km / 500 km / 1,000 km / 2,000 km / 5,000 km / 10,000 km / 50,000 km / 100,000 km

### 3.4 数据管理与导出
- 本地图库：内置可维护的车型图片映射库。
- 导出功能：生成标准格式的 CSV 文件（UTF-8 with BOM 编码），直接保存至安卓文件系统。
- 海报生成：MVP 阶段预留入口和开发空间，点击提示"功能开发中"，择机开发升级。

## 4. 数据架构 (Schema-less Thinking)
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

## 5. 项目路线图 (Roadmap)
- Phase 1: 搭建 Flutter 基础框架，完成本地数据库 (Isar) 配置，引入 Riverpod 状态管理。
- Phase 2: 开发 CupertinoPicker 级联选择器与专业录入表单。
- Phase 3: 实现全屏仪表盘统计逻辑与历史列表（含编辑功能与组合筛选）。
- Phase 4: 车型图库集成与成就系统 UI 开发。
- Phase 5: CSV 导出（UTF-8 with BOM）与海报分享入口预留。
