# Nylo 7.x — 高级

## 状态管理

三种模式，共用 `stateAction`：

| 场景 | 基类 | 生成 | 触发 key |
|------|------|------|----------|
| 整页 | `NyPage`（`stateManaged: true`） | `metro make:page` | `MyPage.path` |
| 单实例组件 | `NyState` | `metro make:stateful_widget` | `MyWidget.state` |
| 多实例隔离 | `NyStateManaged` | `metro make:state_managed_widget` | `Cart.action(..., id:)` |

```dart
@override
Map<String, Function> get stateActions => {
  "reload": () async { /* setState */ },
  "apply": (code) async { /* data payload */ },
};

stateAction("reload", state: Cart.state);
stateAction("apply", state: Cart.state, data: "PROMO");
Cart.action("reload", id: "header"); // NyStateManaged
```

Handler 自行 `setState`。内置组件（InputField、CollectionView、NyForm*）有 typed StateActions。

文档：https://nylo.dev/docs/7.x/state-management

## 本地通知

基于 `flutter_local_notifications`。在 Provider 中初始化；与角标 `setBadgeNumber` 可联动。本仓库见 `app/providers/push_notifications_provider.dart`。

文档：https://nylo.dev/zh/docs/7.x/local-notifications

## Deep Links

路由层配置 deep link；与 `router.add` / 路径参数配合。处理外链进入时落到对应 `path`。

文档：https://nylo.dev/zh/docs/7.x/deep-linking

## Providers

启动时引导：`lib/app/providers/`，注册于 `bootstrap/providers.dart`。

```dart
class AppProvider extends NyProvider {
  @override
  Future<Nylo?> setup(Nylo nylo) async {
    // 初始化本地化等，必须 return nylo 或 null
    return nylo;
  }

  @override
  Future<void> boot(Nylo nylo) async {
    // 所有 provider setup 完成后
  }
}
```

`main.dart`：`Nylo.init(setup: Boot.nylo, setupFinished: Boot.finished)`。完成后 Nylo 实例进 Backpack。

生成：`metro make:provider xxx_provider`。

文档：https://nylo.dev/docs/7.x/providers

## Decoders

`bootstrap/decoders.dart` 的 `modelDecoders`：把 API JSON morph 成 Model。新增模型后必须注册，否则 `get<User>` 无法解码。

文档：https://nylo.dev/zh/docs/7.x/decoders

## 事件

```bash
metro make:event LogoutEvent
```

```dart
class LogoutEvent implements NyEvent {
  final listeners = {DefaultListener: DefaultListener()};
}

event<LogoutEvent>(data: {...});
event<LogoutEvent>(data: {...}, broadcast: true);

// NyPage/NyState 内自动取消订阅
listen<LogoutEvent>((data) { ... });

// 全局需手动 cancel
NyEventSubscription sub = listenOn<LogoutEvent>((data) { ... });
sub.cancel();
```

全局广播：`nylo.broadcastEvents()`（在 AppProvider）。监听器可多个（通知、分析等）。

文档：https://nylo.dev/docs/7.x/events

## App Usage

应用使用统计 / 会话相关 API（见官方 App Usage 页）。按需接入，勿与业务 analytics 重复造轮。

文档：https://nylo.dev/zh/docs/7.x/app-usage

## 调度器

定时/延迟任务调度。适合轮询、提醒；重逻辑仍放 service/controller。

文档：https://nylo.dev/zh/docs/7.x/scheduler

## Testing

按 Nylo Testing 文档写 widget/unit 测试。本地化可用 `NyLocalization.instance.setValuesForTesting(...)`。

文档：https://nylo.dev/zh/docs/7.x/testing

## 路由守卫

```bash
metro make:route_guard auth_route_guard
```

守卫类放 `routes/guards/`，在 `router.add(...).addGuard(...)`（或文档所示 API）挂到需保护的路由。未通过则重定向登录页。

文档：https://nylo.dev/zh/docs/7.x/route-guards

## 背包（Backpack）

进程内同步 KV，**不持久化**（关应用清空）。框架用其存 Nylo、EventBus、Auth 热数据。

```dart
Backpack.instance.save("theme", "dark");
String? theme = Backpack.instance.read("theme");
backpackSave("locale", "zh");
String? locale = backpackRead<String>("locale");
Backpack.instance.deleteAll(); // 保留框架保留键

await NyStorage.save("auth_token", "x", inBackpack: true);
String? token = backpackRead("auth_token"); // 拦截器里同步用
```

Session 分组：`session('checkout').add(...).get(...)`；可 `syncToStorage`。

文档：https://nylo.dev/docs/7.x/backpack

## Commands

自定义 Metro 命令：`metro make:command` → `app/commands/`。本仓库已有 `motivational_quote`、`download_fonts` 等可参考。

文档：https://nylo.dev/zh/docs/7.x/commands
