# 菜包 — 小应用

## 模式

宿主壳 + 独立 package UI + Adapter 注入 API。

```
packages/todo_app          # TodoApp(api: TodoApi) + TodoApi 抽象
lib/app/apps/adapters/     # TodoApiAdapter implements TodoApi → ApiService
lib/app/apps/registry.dart # AppSlug → meta + WidgetBuilder
AppDetailPage              # 按 slug 渲染 getAppComponent(slug)
```

## 注册

`lib/app/apps/registry.dart`：

```dart
enum AppSlug { hello('hello'), todos('todos'); /* … */ }

const List<AppMeta> appList = [
  AppMeta(slug: AppSlug.hello, name: '示例应用', description: '...'),
  AppMeta(slug: AppSlug.todos, name: '待办清单', description: '...'),
];

final Map<AppSlug, WidgetBuilder> appComponents = {
  AppSlug.hello: (_) => HelloApp(api: HelloApiAdapter()),
  AppSlug.todos: (_) => TodoApp(api: TodoApiAdapter()),
};
```

`AppsPage` 列 `appList`；进详情带 `data: {slug: app.slug.value, name, ...}`。

## 新增小应用步骤

1. `packages/xxx_app`：导出 `XxxApp` + `XxxApi` 接口（勿依赖 `package:caibao`）
2. `pubspec.yaml` workspace + 主工程依赖
3. `lib/app/apps/adapters/xxx_api_adapter.dart` 实现接口
4. 更新 `registry.dart`：`AppSlug` + `appList` / `appComponents`
5. 需要的 model 解码器写入 `bootstrap/decoders.dart`
6. **主题强制** `package:caibao_theme/caibao_theme.dart`：`context.palette` / `AppSpacing` / `AppRadius` / `AppTypography` / `AppSizes` / `AppShadows`；禁止边距/圆角/字号/颜色魔法数字（见 caibao-overview「主题」）

## 注意

- 正式入口：`/apps` → `/apps/detail`（按 `AppSlug` 渲染）
- Adapter 内继续用 `api<ApiService>`，保持鉴权与信封一致
