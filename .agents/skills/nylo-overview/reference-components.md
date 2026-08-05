# Nylo 7.x — 组件

生成相关组件优先 Metro：`make:navigation_hub`、`make:button`、`make:bottom_sheet_modal`、`make:form` 等。

## 导航中心

底部导航 / Tab 壳：`metro make:navigation_hub`。可配合 Journey widget（`make:journey_widget`）做分步流程。

文档：https://nylo.dev/docs/7.x/navigation-hub

## Future Widget

异步 UI 封装：加载中 / 成功 / 失败状态，减少手写 `FutureBuilder` 样板。

文档：https://nylo.dev/zh/docs/7.x/future-widget

## 集合视图

列表/网格数据展示（含瀑布流相关依赖）。支持刷新类 `StateActions`（如 `.refresh()`）。大数据列表优先用 Nylo Collection 组件而非裸 `ListView.builder` 堆业务。

文档：https://nylo.dev/zh/docs/7.x/collection-view

## 语言切换

`LanguageSwitcher` 组件；与 Localization 的 `changeLanguage` / `NyLocalization` 一致。Typed `StateActions` 可控制切换。

文档：https://nylo.dev/zh/docs/7.x/language-switcher

## Text Tr

翻译文本组件 / `.tr()` 在 Text 中的用法。嵌套键与参数见 Localization。

文档：https://nylo.dev/zh/docs/7.x/text-tr

## Spacing

布局间距 helper / 组件。菜包优先 `caibao_theme` spacing tokens（见 caibao-overview）。

文档：https://nylo.dev/zh/docs/7.x/spacing

## 输入框

`InputField` 及 Nylo 表单字段。可用 typed StateActions：`.clear()`、`.setValue(...)` 等。

文档：https://nylo.dev/zh/docs/7.x/text-field

## 淡入淡出遮罩

加载/过渡遮罩组件（fade overlay），用于异步遮罩层。

文档：https://nylo.dev/zh/docs/7.x/overlay

## Connective

基于 `connectivity_plus` 的网络状态 UI/helper；可与 `network(..., checkConnectivity: true)` 配合。

文档：https://nylo.dev/zh/docs/7.x/connective

## 样式文本

`StyledText` / `StyledText.template`：

```dart
StyledText.template(
  "already_have_account".tr(),  // JSON: "已有账户？{{login:登录}}"
  styles: {"login": TextStyle(fontWeight: FontWeight.bold)},
  onTap: {"login": () => routeTo(LoginPage.path)},
)
```

`{{key:text}}` 用于样式区间；`.tr(arguments:)` 的 `{{key}}` 用于动态替换，勿混用。

文档：https://nylo.dev/zh/docs/7.x/styled-text

## Pullable

下拉刷新（`pull_to_refresh_flutter3`）。列表页优先用 Pullable 而非自接插件。

文档：https://nylo.dev/zh/docs/7.x/pullable

## Modals

底部弹窗：`metro make:bottom_sheet_modal` → `resources/widgets/bottom_sheet_modals/`。本仓库已有 `logout_modal` 等可参考。

文档：https://nylo.dev/zh/docs/7.x/modals

## Button

```dart
Button.primary(text: "Submit")
```

`metro make:button` 生成自定义按钮；表单 `submitButton` 直接传 Nylo Button。本仓库 `resources/widgets/buttons/` 有扩展样式。

文档：https://nylo.dev/zh/docs/7.x/button
