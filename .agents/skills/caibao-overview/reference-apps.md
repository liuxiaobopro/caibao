# 菜包 — 小应用

## 模式

宿主壳 + 独立 package UI + Adapter 注入 API。

```
packages/todo_app          # TodoApp(api: TodoApi) + TodoApi 抽象
lib/app/apps/adapters/     # TodoApiAdapter implements TodoApi → ApiService
lib/app/apps/registry.dart # slug → meta + WidgetBuilder
AppDetailPage              # 按 slug 渲染 getAppComponent(slug)
```

## 注册

`lib/app/apps/registry.dart`：

```dart
const List<AppMeta> appList = [
  AppMeta(slug: 'hello', name: '示例应用', description: '...'),
  AppMeta(slug: 'todos', name: '待办清单', description: '...'),
];

final Map<String, WidgetBuilder> appComponents = {
  'hello': (_) => HelloApp(api: HelloApiAdapter()),
  'todos': (_) => TodoApp(api: TodoApiAdapter()),
};
```

`AppsPage` 列 `appList`；进详情带 `data: {slug, name, ...}`。

## 新增小应用步骤

1. `packages/xxx_app`：导出 `XxxApp` + `XxxApi` 接口（勿依赖 `package:caibao`）
2. `pubspec.yaml` workspace + 主工程依赖
3. `lib/app/apps/adapters/xxx_api_adapter.dart` 实现接口
4. 更新 `registry.dart` 的 `appList` / `appComponents`
5. 需要的 model 解码器写入 `bootstrap/decoders.dart`
6. 主题用 `package:caibao_theme/caibao_theme.dart`

## 注意

- `/apps/todos`（`todos_app_page.dart`）为遗留独立路由，**未**挂在 `router.dart`；正式入口是 `/apps` → `/apps/detail`
- Adapter 内继续用 `api<ApiService>`，保持鉴权与信封一致
