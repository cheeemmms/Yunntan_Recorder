# Train Ledger 技术栈清单 (Tech Stack)

## 1. 核心框架 (Core Framework)
- **Flutter (Dart)**:
  - **理由**: 跨平台支持（当前专注于 Android，未来可无缝移植 iOS），拥有极其强大的 Canvas 绘图能力和高性能的列表渲染，非常适合展示长列表记录。
  - **优势**: 在 Windows/Linux 上即可开发，无需 Mac 电脑即可完成 Android 端构建。
- **Android SDK 版本**:
  - minSdkVersion: 21 (Android 5.0 Lollipop)
  - targetSdkVersion: 34 (Android 14)
  - compileSdkVersion: 35 (因 objectbox_flutter_libs 要求)

## 2. 状态管理 (State Management)
- **Riverpod (flutter_riverpod ^3.3.1)**:
  - **理由**: Flutter 生态中最现代、最灵活的状态管理方案。编译时安全、可测试性强、支持异步状态管理。
  - **用法**: 使用 AsyncNotifierProvider 管理数据库状态，确保 UI 自动响应数据变化。

## 3. 数据持久化 (Data Storage)
- **ObjectBox (NoSQL ^5.2.0)**:
  - **理由**: Flutter 生态中高性能的本地 NoSQL 数据库，完全兼容 Dart 3.11+。原生支持 Dart 对象存储，契合 Schema-less 思维，方便后期随时增加"运行图"、"天气"等扩展字段。
  - **特性**: 支持异步操作，查询性能极高，非常适合处理成千上万条记录。自带对象关系支持，无需手写 SQL Schema。
  - **替代背景**: 原计划使用 Isar，但 Isar 3.x 与 Dart 3.11 不兼容，Isar 4.x 尚未发布，因此改用 ObjectBox。

## 4. UI 与交互设计 (UI & Interaction)
- **Material 3 (Material You)**:
  - **定位**: 应用整体严格遵循 Material You 设计规范，包括配色、组件样式、动效等。
  - **Flex Color Scheme ^8.4.0**: 用于快速配置具有"工业感"的专业配色方案（greyLaw）。
  - **dynamic_color ^1.7.0**: Material You 动态取色，从壁纸提取 ColorScheme。有动态色时覆盖 FlexThemeData 的 colorScheme，无动态色时回退 greyLaw。
- **Cupertino Widgets (选择性使用)**:
  - **CupertinoPicker**: 用于所有级联选择器（车型 L1→L2→L3→L4、乘务担当 局→段），以 BottomSheet 形式弹出，提供 iOS 拨轮风格的专业选择体验。
- **flutter_slidable ^4.0.0**:
  - **用途**: 运转记录卡片的左右滑动操作（左滑编辑、右滑删除）。
  - **特性**: BehindMotion 动效，CustomSlidableAction 支持自定义样式（圆角、颜色），SlidableController 支持互斥控制。
- **动画系统 (自研)**:
  - **AnimationController + Overlay**: 自定义分层动画，遵循 MD3 Motion 规范。
  - **4 条独立进度曲线**: bgProgress/floatProgress/fadeProgress (0-300ms) + expandProgress (0-500ms)。
  - **BackdropFilter**: 背景高斯模糊 + 压暗效果。
  - **RenderBox.localToGlobal**: 获取条目精确位置作为动画起点。
- **主要 UI 组件**:
  - **ListView.builder**: 运转记录列表，按时间倒序展示。
  - **Overlay + OverlayEntry**: 全屏详情卡片展开。
  - **IntrinsicHeight**: 成就页仪表盘双卡片等高。
  - **FittedBox**: 大数字自适应缩放。

## 5. 核心逻辑与实用库 (Utilities)
- **数据模型解析**: json_serializable & freezed (用于处理复杂的 train_hierarchy.json 级联结构)。
- **文件操作**: path_provider (访问安卓文件系统)。
- **导出功能**: csv (将 ObjectBox 数据库内容转换为标准 CSV 格式，编码使用 UTF-8 with BOM) — 待引入。
- **图像处理**: cached_network_image 或本地 Image.asset (用于展示车型图库) — 待引入。

## 6. 开发环境与工具 (Environment)
- **IDE**: VS Code 或 Android Studio (配合 Flutter & Dart 插件)。
- **AI 辅助**: Trae IDE / ChatGPT (用于快速生成复杂的级联选择器逻辑和数据模型)。
- **版本控制**: Git。
- **代码生成**: build_runner + objectbox_generator (修改 Trip 实体后必须重新运行 `dart run build_runner build`)。

## 7. 数据交换格式 (Data Exchange)
- **输入**: 本地 train_hierarchy.json (用于存储车型级联) + railway_bureau.json (用于存储 18 局字典，两层结构含 category 过滤)。
- **输出**: .csv (UTF-8 with BOM 编码，确保 Excel 中文不乱码) + .png/jpg (海报分享，MVP 预留入口)。

## 8. 已知技术约束
- **项目路径**: 必须为纯英文路径（Android aapt 不支持非 ASCII 路径）。
- **ObjectBox 代码生成**: 修改 Trip 实体后必须重新运行 build_runner，否则编译失败。
- **compileSdk 35**: objectbox_flutter_libs 要求 SDK 35。
- **DropdownButtonFormField 席位过滤 Bug**: Coach 模式下 items 列表不更新，需换用 Chip 组或强制重建方案。
- **TextStyle 荧光色双下划线**: 所有 TextStyle 必须显式设置 `decoration: TextDecoration.none`，否则 debug 和 release 模式均会出现。
