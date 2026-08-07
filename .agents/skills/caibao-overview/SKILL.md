---
name: caibao-overview
description: 菜包（caibao）Flutter 应用架构与约定 — 登录/聊天/Agent/云盘/小应用、ApiService 信封、SSE 流式对话、Auth 守卫、caibao_theme、mini-app registry。处理本仓库业务代码、页面、控制器、网络或 packages 时使用；Nylo 框架通用模式见 nylo-overview。
---

# 菜包（caibao）Overview

AI 聊天应用（UI 仿豆包）。Flutter + Nylo 7。后端 Go，Swagger：`http://81.70.229.173:18082/swagger/index.html`。

Nylo 通用能力见 [nylo-overview](../nylo-overview/SKILL.md)。

## 硬约束

1. **新页面必须 Metro**：`metro make:page xxx_page`，禁止手写脚手架（见 README）
2. **图片/资源用 Nylo**：`LocalAsset.image` / `getImageAsset` / `getAsset`，禁止 `Image.asset('assets/...')`
3. **禁止主题硬编码**（主应用 `lib/resources/**` + `packages/*_app/**` 一律适用，见下方「主题」）
4. **业务 API 走 `ApiService`**：`api<ApiService>((r) => r.xxx())`；信封 `{code, data, msg}`，`code != 0` → `ApiException`
5. **需登录路由挂 `AuthRouteGuard`**；主会话页用 `.authenticatedRoute()`
6. **import 用 `package:caibao/...`**；workspace 包：`caibao_theme` / `caibao_hello_app` / `caibao_todo_app`

## 目录

```
lib/
├── app/
│   ├── controllers/     # 页面逻辑（继承 Controller → NyController）
│   ├── models/          # fromJson 模型
│   ├── networking/      # ApiService、ChatStreamClient、interceptors
│   ├── services/        # ChatStreamHandler 等
│   ├── apps/            # registry + adapters（小应用宿主）
│   ├── providers/ events/ forms/ analytics/ utils/
├── bootstrap/           # boot、decoders、providers、events、theme
├── config/              # app、storage_keys、localization、design
├── resources/pages|widgets|themes/
└── routes/              # router.dart、guards/
packages/
├── caibao_theme/        # 设计 token 源
├── hello_app/           # 示例小应用
└── todo_app/            # 待办小应用
```

## 路由

[`lib/routes/router.dart`](../../../lib/routes/router.dart)

| Path | 页面 | 说明 |
|------|------|------|
| `/login` | LoginPage | `initialRoute` |
| `/chat` | ChatPage | `authenticatedRoute` + AuthRouteGuard |
| `/agents` `/agents/chat` | Agents / AgentChat | 守卫 |
| `/drive` | DrivePage | 云盘 |
| `/apps` `/apps/detail` | Apps / AppDetail | 小应用壳 |
| `/profile` | ProfilePage | 个人中心 |
| `/storage-configs` | StorageConfigsPage | 存储配置 |
| `/llm-models` | LlmModelsPage | 模型列表 |
| `/home` | HomePage | Nylo 模板页（非主流程） |
| `/not-found` | NotFoundPage | `unknownRoute` |

未登录 → `/login`；登录成功 → `/chat`（`pushAndForgetAll`）。

## 页面 / 控制器

```dart
class XxxPage extends NyStatefulWidget<XxxController> {
  static RouteView path = ('/xxx', (_) => XxxPage());
  XxxPage({super.key}) : super(child: () => _XxxPageState());
}

class _XxxPageState extends NyPage<XxxPage> {
  @override
  get init => () { /* load */ };

  @override
  Widget view(BuildContext context) { /* UI */ }
}
```

- 新 controller → 注册 [`bootstrap/decoders.dart`](../../../lib/bootstrap/decoders.dart) 的 `controllers`
- 新 model → 注册同文件 `modelDecoders`
- UI 文案目前多为中文硬编码；`lang/` 存在但未全面接入

## 网络

### REST（ApiService）

[`lib/app/networking/api_service.dart`](../../../lib/app/networking/api_service.dart)

- `baseUrl`：`getEnv('API_BASE_URL')`
- Token：`Auth.data(field: 'token')` → `BearerAuthInterceptor` + `setAuthHeaders`
- 401：logout + `routeToInitial()`
- 分页字段：`page_num` / `page_size` / `items` / `total`（snake_case JSON）

```dart
final me = await api<ApiService>((r) => r.fetchMe());
```

### SSE 流式聊天

- Client：[`chat_stream_client.dart`](../../../lib/app/networking/chat_stream_client.dart)（独立 Dio，`Accept: text/event-stream`）
- Handler：[`chat_stream_handler.dart`](../../../lib/app/services/chat_stream_handler.dart)
- 端点：`/conversations/{id}/chat`、`/agents/{id}/chat`
- 事件：`delta` / `done` / `error` → 更新 `ChatMessage` 列表

详情见 [reference-networking.md](reference-networking.md)。

## 认证

```dart
await Auth.authenticate(data: {'token': token, 'id': ..., 'username': ...});
await routeTo(ChatPage.path, navigationType: NavigationType.pushAndForgetAll);
await Auth.logout();
```

- StorageKey：`StorageKeysConfig.auth = 'SK_USER'`
- 守卫：[`auth_route_guard.dart`](../../../lib/routes/guards/auth_route_guard.dart)

## 主题

源：`packages/caibao_theme`。主应用经 `lib/resources/themes/tokens/` re-export；小应用 `import 'package:caibao_theme/caibao_theme.dart'`。

```dart
final palette = context.palette;
final tokens = context.tokens;

padding: EdgeInsets.all(AppSpacing.x4)
borderRadius: AppRadius.x2lAll
fontSize: AppTypography.sm
size: AppSizes.iconLg
color: palette.foreground // / brand / mutedForeground / userBubble …
boxShadow: tokens.panelShadow // 或 AppShadows.*
```

### 禁止（硬编码）

| 类型 | 禁止写法 | 必须用 |
|------|----------|--------|
| 间距 | `EdgeInsets.all(16)` / `symmetric(horizontal: 12)` / `SizedBox(height: 8)` | `AppSpacing.*` |
| 圆角 | `BorderRadius.circular(14)` / `Radius.circular(16)` | `AppRadius.*` / `*All` |
| 字号 | `fontSize: 15` / `17` / `TextStyle(fontSize: 13)` | `AppTypography.*` |
| 尺寸 | icon/avatar/button 字面量宽高 | `AppSizes.*` |
| 颜色 | `Colors.grey` / `Colors.blue` / `Color(0xFF…)` / `Colors.black26` | `context.palette` / `CaibaoPalette` |
| 阴影 | 自拼 `BoxShadow` / `Colors.black26` elevation | `AppShadows.*` / `tokens.panelShadow` |

**例外（仅这些可保留字面量）：**

- `Colors.transparent`（AppBar `surfaceTintColor` 等）
- `Divider(height: 1)` / 1px 分割与微间距
- 动画 `Duration` / 曲线
- 布局约束里与 token 无关的媒体查询计算（仍优先用 spacing 参与运算）
- `lib/resources/themes/**` 与 `packages/caibao_theme/**` 内的 token **定义本身**
- Nylo 模板页 `home_page.dart`（非主流程，可不改）

缺 token 时：**先补 `packages/caibao_theme`**，再在业务里引用；禁止为图省事写魔法数字。

映射就近：`11→xs(12)`、`13→sm(14)`、`15→base(16)`、`17→lg(18)`；圆角 `12→lg(10)或xl(14)`、`16→xl`、`18→x2l`、`20→x3l`。

## 小应用（Mini-app）

1. `packages/xxx_app`：UI + `XxxApi` 接口
2. `lib/app/apps/adapters/xxx_api_adapter.dart`：实现接口，调 `ApiService`
3. [`registry.dart`](../../../lib/app/apps/registry.dart)：`appList` + `appComponents[slug]`
4. `AppDetailPage` 按 route `data.slug` 解析组件

详见 [reference-apps.md](reference-apps.md)。

## 新功能清单

- [ ] `metro make:page` / `make:controller`（如需）
- [ ] `router.dart` 加路由 + 守卫
- [ ] `decoders.dart` 注册 controller / model
- [ ] API 写在 `ApiService`（或 SSE client）
- [ ] UI：**禁止主题硬编码**；用 `context.palette` / `AppSpacing` / `AppRadius` / `AppTypography` / `AppSizes`；图片用 LocalAsset
- [ ] 小应用同步遵守 caibao_theme，缺 token 先补 `packages/caibao_theme`
- [ ] 错误：`showToastSorry` + `ApiException` 中文文案

## Additional resources

- [reference-networking.md](reference-networking.md)
- [reference-apps.md](reference-apps.md)
- [nylo-overview](../nylo-overview/SKILL.md)
