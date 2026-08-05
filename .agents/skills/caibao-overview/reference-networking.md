# 菜包 — 网络与流式

## ApiService 约定

文件：`lib/app/networking/api_service.dart`

| 项 | 约定 |
|----|------|
| 基类 | `NyApiService`，`decoders: modelDecoders` |
| Base URL | `getEnv('API_BASE_URL')` |
| 鉴权 | `Auth.data(field: 'token')` → Bearer |
| 拦截器 | `BearerAuthInterceptor`（401 → logout + 回登录） |
| 信封 | 响应 `{code, data, msg}`；业务成功 `code == 0` |
| 失败 | 抛 `ApiException`（`lib/app/networking/api_exception.dart`） |
| 调用 | `await api<ApiService>((r) => r.method())` |

登录免鉴权示例：`login` 内部 `_data(..., auth: false)`。

分页响应形态：

```dart
({List<T> items, int total})
// JSON: page_num, page_size, items, total
```

JSON 字段 snake_case（如 `avatar_url`）；Dart 模型用 camelCase + `fromJson`。

## 登录流

`LoginController.submit`：

1. `api.login` → 取 `token`
2. `Auth.authenticate(data: {'token': token})`
3. `api.fetchMe` → 合并用户字段再 `Auth.authenticate`
4. `routeTo(ChatPage.path, pushAndForgetAll)`
5. Analytics track（如有）

已登录进登录页：`redirectIfAuthenticated()` → Chat。

## SSE 流式

| 文件 | 职责 |
|------|------|
| `chat_stream_client.dart` | POST + SSE 解析 → `ChatSSEEvent` 流 |
| `chat_stream_handler.dart` | 把事件落到消息列表（delta 追加正文等） |
| `chat_controller.dart` / `agent_chat_controller.dart` | 编排 REST 会话 + 流式发送 |

注意：流式**不**走 `ApiService.network()`，用独立 Dio 以保持长连接与事件解析。Headers 仍需带 Bearer token。

事件类型（典型）：`delta`、`done`、`error`。

## 错误 UX

```dart
try {
  await api<ApiService>((r) => r.xxx());
} on ApiException catch (e) {
  showToastSorry(description: e.message);
} catch (_) {
  showToastSorry(description: '网络异常');
}
```

优先中文用户可见文案。
