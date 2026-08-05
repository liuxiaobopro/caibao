# CLAUDE.md / Agent 必加载 Skills

处理本仓库代码时始终应用：

- `caibao-overview` — 菜包业务架构、路由、ApiService、SSE、小应用
- `nylo-overview` — Nylo 7.x 框架模式（路由/Metro/Assets/NyState 等）

图片与静态资源必须使用 Nylo：`LocalAsset` / `getImageAsset` / `getAsset`。

新页面必须通过 Metro CLI 创建。
