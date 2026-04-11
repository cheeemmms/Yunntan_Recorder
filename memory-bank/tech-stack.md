# Train Ledger 技术栈清单 (Tech Stack)

## 1. 核心框架 (Core Framework)
- **Flutter (Dart)**:
  - **理由**: 跨平台支持（当前专注于 Android，未来可无缝移植 iOS），拥有极其强大的 Canvas 绘图能力和高性能的列表渲染，非常适合展示长列表记录。
  - **优势**: 在 Windows/Linux 上即可开发，无需 Mac 电脑即可完成 Android 端构建。
- **Android SDK 版本**:
  - minSdkVersion: 21 (Android 5.0 Lollipop)
  - targetSdkVersion: 34 (Android 14)
  - compileSdkVersion: 34

## 2. 状态管理 (State Management)
- **Riverpod (flutter_riverpod)**:
  - **理由**: Flutter 生态中最现代、最灵活的状态管理方案。编译时安全、可测试性强、支持异步状态管理。
  - **用法**: 使用 AsyncNotifierProvider 管理数据库状态，确保 UI 自动响应数据变化。

## 3. 数据持久化 (Data Storage)
- **Isar Database (NoSQL)**:
  - **理由**: Flutter 生态中最快的本地 NoSQL 数据库。它原生支持 Dart 对象存储，完美契合 Schema-less 思维，方便后期随时增加"运行图"、"天气"等扩展字段。
  - **特性**: 支持异步操作，查询性能极高，非常适合处理成千上万条记录。

## 4. UI 与交互设计 (UI & Interaction)
- **Material 3 (Material You)**:
  - **定位**: 应用整体严格遵循 Material You 设计规范，包括配色、组件样式、动效等。
  - **Flex Color Scheme**: 用于快速配置具有"工业感"的专业配色方案。
- **Cupertino Widgets (选择性使用)**:
  - **CupertinoPicker**: 用于所有级联选择器（车型 L1→L2→L3、乘务担当 局→段），以 BottomSheet 形式弹出，提供 iOS 拨轮风格的专业选择体验。
- **主要 UI 组件**:
  - **CustomScrollView**: 用于实现"仪表盘+下滑列表"的无缝交互。
  - **Modal Bottom Sheet**: 借鉴 Apple Maps，用于展示记录详情和选择器。

## 5. 核心逻辑与实用库 (Utilities)
- **数据模型解析**: json_serializable & freezed (用于处理复杂的 train_hierarchy.json 级联结构)。
- **文件操作**: path_provider (访问安卓文件系统) & permission_handler (权限管理)。
- **导出功能**: csv (将 Isar 数据库内容转换为标准 CSV 格式，编码使用 UTF-8 with BOM)。
- **图像处理**: cached_network_image 或本地 Image.asset (用于展示车型图库)。

## 6. 开发环境与工具 (Environment)
- **IDE**: VS Code 或 Android Studio (配合 Flutter & Dart 插件)。
- **AI 辅助**: Cursor / ChatGPT (用于快速生成复杂的级联选择器逻辑和数据模型)。
- **版本控制**: Git。

## 7. 数据交换格式 (Data Exchange)
- **输入**: 本地 train_hierarchy.json (用于存储车型级联) + railway_bureau.json (用于存储 18 局字典，两层结构含 category 过滤)。
- **输出**: .csv (UTF-8 with BOM 编码，确保 Excel 中文不乱码) + .png/jpg (海报分享，MVP 预留入口)。
