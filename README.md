# 菜包

AI 聊天应用，UI/交互仿 [豆包](https://www.doubao.com/)。

## 技术栈

- Flutter
- [Nylo](https://nylo.dev/zh/docs/7.x/what-is-nylo) v7 微框架（路由、网络、状态、本地化、主题、存储、表单、Metro CLI）

## 接口文档

[Swagger](http://81.70.229.173:18082/swagger/index.html)

## 开发约定

所有页面必须通过 [Metro CLI](https://nylo.dev/zh/docs/7.x/installation) 创建，禁止手写脚手架。

查询可用命令：

```bash
metro -h
```

## Agent Skills

### 必加载（本仓库）

| Skill | 用途 |
|-------|------|
| caibao-overview | 菜包业务架构、ApiService、SSE、小应用 |
| nylo-overview | Nylo 7.x 框架模式与 Assets 规则 |

### 项目级（`.agents/skills/`，来源 [flutter/skills](https://skills.sh/flutter/skills)）

| Skill | 用途 |
|-------|------|
| flutter-apply-architecture-best-practices | 分层架构 |
| flutter-build-responsive-layout | 响应式布局 |
| flutter-fix-layout-issues | 布局溢出修复 |
| flutter-setup-declarative-routing | 声明式路由 |
| flutter-setup-localization | 国际化 |
| flutter-use-http-package | HTTP 请求 |
| flutter-implement-json-serialization | JSON 序列化 |
| flutter-add-widget-preview | Widget Preview |
| dart-run-static-analysis | 静态分析 |
| dart-fix-runtime-errors | 运行时错误修复 |
| dart-use-pattern-matching | Pattern matching |
| dart-resolve-package-conflicts | 依赖冲突 |

### 全局（App UI 设计）

| Skill | 来源 |
|-------|------|
| mobile-app-ui-design | ceorkm/mobile-app-ui-design |
| mobile-android-design | wshobson/agents |
| mobile-ios-design | wshobson/agents |
| high-end-visual-design | leonxlnx/taste-skill |
| design-taste-frontend | leonxlnx/taste-skill |
| frontend-design | anthropics/skills |
