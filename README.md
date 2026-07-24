# lemon_shadcn

Lemon 的 Flutter 组件库，基于 `shadcn_flutter` 构建。

## 当前基线

- 统一导出 `shadcn_flutter`，业务项目只需导入一个 package。
- 提供 `LemonThemes.light` / `LemonThemes.dark` 主题入口。
- `example` 是组件展厅和交互验证应用。
- 最低 Flutter 版本为 3.35.1，与上游要求保持一致。

## 使用

```dart
import 'package:lemon_shadcn/lemon_shadcn.dart';

ShadcnApp(
  theme: LemonThemes.light,
  darkTheme: LemonThemes.dark,
  home: const MyHomePage(),
);
```

## 本地开发

```shell
flutter pub get
flutter analyze
flutter test
cd example
flutter run
```

新增组件应放在 `lib/src/components/`，并从
`lib/lemon_shadcn.dart` 显式导出；相应的交互示例放入 `example`，测试放入
`test`。

详细架构原则与实施阶段见 [`docs/development-plan.md`](docs/development-plan.md)。
