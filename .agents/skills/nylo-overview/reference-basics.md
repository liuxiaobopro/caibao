# Nylo 7.x — 基础

## 安装

```bash
dart pub global activate nylo_installer
nylo new my_app
cd my_app && nylo init   # 配置 metro 别名
flutter run
```

本仓库已是 Nylo 项目，直接用 Metro / `flutter run`。

## 配置

- 环境变量：根目录 `.env` → `metro make:env` 生成 `bootstrap/env.g.dart`
- 常用键：`API_BASE_URL`、`DEFAULT_LOCALE`、`ASSET_PATH`、`DEBUG_TRANSLATIONS`
- 读取：`getEnv('KEY', defaultValue: '...')`
- 应用配置：`lib/config/app.dart`、`design.dart`、`localization.dart`、`storage_keys.dart`

## 目录结构

见 SKILL.md「目录约定」。要点：

| 路径 | 用途 |
|------|------|
| `app/controllers/` | 页面业务逻辑 |
| `app/networking/` | `NyApiService` + Dio interceptors |
| `app/forms/` | `NyFormWidget` |
| `bootstrap/decoders.dart` | 模型解码器注册 |
| `resources/pages/` | `NyPage` 屏幕 |
| `routes/router.dart` | 路由表 |
| `assets/images/` | 图片（配合 LocalAsset） |
| `assets/app_icon/` | 启动图标源图 |
| `lang/` | 翻译 JSON |

## 路由器

```dart
appRouter() => nyRoutes((router) {
  router.add(LoginPage.path).initialRoute();
  router.add(HomePage.path).authenticatedRoute();
  router.add(NotFoundPage.path).unknownRoute();
  router.add(ProfilePage.path);
});
```

| API | 用途 |
|-----|------|
| `routeTo(path)` | 导航 |
| `routeTo(path, data: {...})` | 传参 |
| `routeToInitial()` | 回初始路由并清栈 |
| `routeToAuthenticatedRoute()` | 去认证路由 |
| `.initialRoute(when:)` | 未登录首页（可条件） |
| `.authenticatedRoute()` | 已登录首页 |
| `.previewRoute()` | 开发预览（发版前移除） |

页面用 `NyStatefulWidget` + `static RouteView path`；取参用 widget 的 data API。

文档：https://nylo.dev/zh/docs/7.x/router

## 网络请求

服务放 `lib/app/networking/`，继承 `NyApiService`：

```dart
class ApiService extends NyApiService {
  ApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl => getEnv('API_BASE_URL');

  Future<User?> fetchUser(int id) => get<User>("/users/$id");
  Future<User?> createUser(Map data) => post<User>("/users", data: data);
}
```

| 方式 | 返回 | 场景 |
|------|------|------|
| `get`/`post`/`put`/`patch`/`delete` | `T?` | 简单 CRUD |
| `network()` | `T?` | 缓存、重试、自定义头 |
| `networkResponse()` | `NyResponse<T>` | 需要状态码/错误详情 |

页面调用：

```dart
User? user = await api<ApiService>((request) => request.fetchUser(1));
```

在 `bootstrap/decoders.dart` 注册 `modelDecoders`。底层 Dio；拦截器放 `networking/dio/interceptors/`。

文档：https://nylo.dev/zh/docs/7.x/networking

## Metro

```bash
metro make:page settings_page
metro make:controller settings_controller
metro make:api_service user_api_service
metro make:form LoginForm
metro make:model User
metro make:provider cache_provider
metro make:event LogoutEvent
metro make:route_guard auth_route_guard
metro make:interceptor auth_interceptor
metro make:env
metro make:navigation_hub
metro make:button
metro make:bottom_sheet_modal
```

优先用 Metro 生成，避免手写漏注册路由/解码器。

文档：https://nylo.dev/zh/docs/7.x/metro

## Localization

- 文件：`lang/en.json` 等，`pubspec.yaml` 注册 `lang/`
- 配置：`lib/config/localization.dart`
- 用法：`"welcome".tr()` / `trans("welcome")`；嵌套 `"nav.home".tr()`
- 参数：`"greeting".tr(arguments: {"name": "A"})`（JSON 里 `{{name}}`）
- 切换：`changeLanguage('zh')`（NyPage）或 `NyLocalization.instance.setLanguage(...)`
- `.env`：`DEFAULT_LOCALE`、`LOCALE_TYPE=device|asDefined`

文档：https://nylo.dev/zh/docs/7.x/localization

## Storage

持久化用 `NyStorage`（flutter_secure_storage）：

```dart
await NyStorage.save("coins", 100, inBackpack: true);
int? coins = await NyStorage.read<int>('coins');
await NyStorage.delete('coins', andFromBackpack: true);
await NyStorage.saveWithExpiry('token', 'x', ttl: Duration(hours: 1));
```

键集中在 `lib/config/storage_keys.dart`：

```dart
await StorageKeysConfig.coins.save(100, inBackpack: true);
int? c = await StorageKeysConfig.coins.read<int>();
int? sync = StorageKeysConfig.coins.fromBackpack<int>();
```

集合：`addToCollection` / `readCollection`；Model 可 `user.save()`。

文档：https://nylo.dev/docs/7.x/storage

## Controllers

- 路径：`lib/app/controllers/`
- 继承 `NyController`；页面通过 Nylo 绑定访问
- 可调用 `changeLanguage`、导航、toast 等 helper
- 生成：`metro make:controller home_controller`

## 应用图标

1. 1024x1024 PNG → `assets/app_icon/icon.png`（无透明、扁平）
2. `pubspec.yaml` 配置 `flutter_launcher_icons.image_path`
3. `dart run flutter_launcher_icons`
4. 角标：`await setBadgeNumber(5)` / `await clearBadgeNumber()`

文档：https://nylo.dev/docs/7.x/app-icons

## 验证

表单字段用 `FormValidator.*`（email、password、规则组合）。自定义规则见验证文档。与 `NyFormWidget` 配合。

文档：https://nylo.dev/zh/docs/7.x/validation

## 身份验证

```dart
await Auth.authenticate(data: user);          // 或 Map
bool ok = await Auth.isAuthenticated();
dynamic token = Auth.data(field: 'token');    // 经 Backpack 同步读
await Auth.set((data) { data['token'] = 'new'; return data; });
await Auth.logout();
String deviceId = await Auth.deviceId();
```

命名会话：`session: 'device'` / `Auth.logoutAll(sessions: [...])`。

启动同步：`await Auth.syncToBackpack()`。

路由配合：`.initialRoute()`（未登录）+ `.authenticatedRoute()`（已登录）。

Helper：`authAuthenticate`、`authData`、`authLogout`、`authIsAuthenticated` 等。

文档：https://nylo.dev/zh/docs/7.x/authentication

## Logging

使用 Nylo 日志 helper（文档 Logging 页）。开发期可开 `DEBUG_TRANSLATIONS` 等开关。

文档：https://nylo.dev/zh/docs/7.x/logging

## 表单

```dart
class LoginForm extends NyFormWidget {
  LoginForm({super.key, super.submitButton, super.onSubmit, super.onFailure});

  @override
  fields() => [
    Field.email("Email", validator: FormValidator.email()),
    Field.password("Password", validator: FormValidator.password()),
  ];

  static NyFormActions get actions => const NyFormActions('LoginForm');
}

LoginForm(
  submitButton: Button.primary(text: "Login"),
  onSubmit: (data) { /* Map */ },
)
```

生成：`metro make:form LoginForm` → `lib/app/forms/`。

文档：https://nylo.dev/zh/docs/7.x/forms

## Cache

网络请求 `network(..., cacheKey:, cacheDuration:, cachePolicy:)`；本地也可用 Storage/Backpack 缓存。

文档：https://nylo.dev/zh/docs/7.x/cache

## 主题与样式

- 主题：`lib/resources/themes/light|dark/`
- 启动主题：`bootstrap/theme.dart`、`config/design.dart`
- 文本样式扩展（如 `.bodyMedium()`）、主题切换组件

菜包业务 token 见 caibao-overview（`caibao_theme`）。

文档：https://nylo.dev/zh/docs/7.x/themes-and-styling

## Assets

```dart
LocalAsset.image("nylo_logo.png")
Image.asset(getImageAsset("nylo_logo.png"))
getAsset("videos/welcome.mp4")
```

- `.env`：`ASSET_PATH="assets"`（默认），helper 自动加前缀
- 改路径后：`metro make:env`
- `pubspec.yaml` 注册 `assets/images/` 等目录

**禁止** `Image.asset('assets/images/...')` 硬编码。

文档：https://nylo.dev/zh/docs/7.x/assets

## NyState

- `init`：首次加载
- `view(context)`：构建 UI
- `stateActions`：命名动作；外部 `stateAction("name", state: X.state, data: ...)`
- 页面需 `stateManaged => true` 才订阅
- 详见高级「状态管理」

文档：https://nylo.dev/zh/docs/7.x/ny-state

## Alerts

Toast / 对话框用 Nylo alerts：

```dart
showToastSuccess(description: "...");
showToastDanger(description: "...");
```

样式可配 `config/toast_notification.dart`。

文档：https://nylo.dev/zh/docs/7.x/alerts

## Helpers

常用全局函数：`routeTo`、`api`、`getEnv`、`getAsset`/`getImageAsset`、`storageSave`/`storageRead`、`backpackRead`/`backpackSave`、`event`、`stateAction`、`trans`/`.tr()`。优先用这些，少造平行封装。

文档：https://nylo.dev/zh/docs/7.x/helpers
