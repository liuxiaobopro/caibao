---
name: nylo-overview
description: Nylo 7.x 微框架模式 — 路由、NyApiService、NyState/stateAction、Metro、Auth、NyStorage/Backpack、表单、LocalAsset/Assets、App Icons。编写或审查 Nylo 脚手架、框架 API、Metro 生成物时使用。菜包业务约定见 caibao-overview。
---

# Nylo 7.x Overview

官方：[什么是 Nylo？](https://nylo.dev/zh/docs/7.x/what-is-nylo)

菜包业务架构 → [caibao-overview](../caibao-overview/SKILL.md)。

## 强制：图片与资源

```dart
// 正确
LocalAsset.image("logo.png", height: 50, width: 50)
Image.asset(getImageAsset("logo.png"))
getAsset("videos/intro.mp4")

// 错误
Image.asset('assets/images/logo.png')
```

- 图：`assets/images/`；通用：`getAsset(...)`
- 应用图标：`assets/app_icon/` 1024 PNG → `dart run flutter_launcher_icons`
- 角标：`setBadgeNumber` / `clearBadgeNumber`
- 本仓组件：`lib/resources/widgets/local_asset_widget.dart`

## 能力速查

| 能力 | API |
|------|-----|
| 路由 | `nyRoutes` / `routeTo` / guards / deep links |
| 网络 | `NyApiService` + Dio + decoders |
| 状态 | `NyPage` / `NyState` / `stateAction` |
| i18n | `lang/*.json` + `.tr()` |
| 存储 | `NyStorage` + `Backpack` + `StorageKey` |
| 认证 | `Auth.*` / `.authenticatedRoute()` |
| 表单 | `NyFormWidget` + `Field.*` |
| 生成 | `metro make:*` |

## 目录（Nylo 模板）

```
lib/app/          # controllers forms models networking providers events
lib/bootstrap/    # boot decoders events providers theme helpers
lib/config/       # app localization storage_keys design
lib/resources/    # pages themes widgets
lib/routes/       # router.dart guards/
assets/ images|app_icon|fonts/   lang/
```

## Metro 工作流

1. 页面：`metro make:page xxx_page`
2. API：`metro make:api_service` → 注册 decoders
3. 控制器：`metro make:controller`
4. 表单：`metro make:form`
5. 改 `.env`：`metro make:env`

## 最小片段

```dart
appRouter() => nyRoutes((router) {
  router.add(LoginPage.path).initialRoute();
  router.add(HomePage.path).authenticatedRoute();
});

routeTo(DetailPage.path, data: {"id": 1});

User? u = await api<ApiService>((r) => r.fetchUser(1));

stateAction("reload", state: MyPage.path);

await Auth.authenticate(data: user);
await NyStorage.save("k", v, inBackpack: true);
```

## 文档索引

### 快速开始 / 基础

| 主题 | Docs | Ref |
|------|------|-----|
| 安装 | [installation](https://nylo.dev/zh/docs/7.x/installation) | [basics#安装](reference-basics.md#安装) |
| 配置 | [configuration](https://nylo.dev/zh/docs/7.x/configuration) | [basics#配置](reference-basics.md#配置) |
| 目录 | [directory-structure](https://nylo.dev/zh/docs/7.x/directory-structure) | [basics#目录结构](reference-basics.md#目录结构) |
| 路由 | [router](https://nylo.dev/zh/docs/7.x/router) | [basics#路由器](reference-basics.md#路由器) |
| 网络 | [networking](https://nylo.dev/zh/docs/7.x/networking) | [basics#网络请求](reference-basics.md#网络请求) |
| Metro | [metro](https://nylo.dev/zh/docs/7.x/metro) | [basics#metro](reference-basics.md#metro) |
| i18n | [localization](https://nylo.dev/zh/docs/7.x/localization) | [basics#localization](reference-basics.md#localization) |
| Storage | [storage](https://nylo.dev/docs/7.x/storage) | [basics#storage](reference-basics.md#storage) |
| Controllers | [controllers](https://nylo.dev/zh/docs/7.x/controllers) | [basics#controllers](reference-basics.md#controllers) |
| 应用图标 | [app-icons](https://nylo.dev/docs/7.x/app-icons) | [basics#应用图标](reference-basics.md#应用图标) |
| 验证 | [validation](https://nylo.dev/zh/docs/7.x/validation) | [basics#验证](reference-basics.md#验证) |
| 认证 | [authentication](https://nylo.dev/zh/docs/7.x/authentication) | [basics#身份验证](reference-basics.md#身份验证) |
| 表单 | [forms](https://nylo.dev/zh/docs/7.x/forms) | [basics#表单](reference-basics.md#表单) |
| Assets | [assets](https://nylo.dev/zh/docs/7.x/assets) | [basics#assets](reference-basics.md#assets) |
| NyState | [ny-state](https://nylo.dev/zh/docs/7.x/ny-state) | [basics#nystate](reference-basics.md#nystate) |
| Alerts / Helpers / Cache / Logging / 主题 | 见 docs 侧栏 | [basics](reference-basics.md) |

### 组件 / 高级

- [reference-components.md](reference-components.md) — NavigationHub、CollectionView、StyledText、Button、Modals…
- [reference-advanced.md](reference-advanced.md) — stateAction、Providers、Events、Backpack、Route Guards…
