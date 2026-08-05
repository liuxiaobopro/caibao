import 'package:caibao/app/apps/adapters/hello_api_adapter.dart';
import 'package:caibao/app/apps/adapters/todo_api_adapter.dart';
import 'package:caibao_hello_app/caibao_hello_app.dart';
import 'package:caibao_todo_app/caibao_todo_app.dart';
import 'package:flutter/widgets.dart';

class AppMeta {
  const AppMeta({
    required this.slug,
    required this.name,
    required this.description,
  });

  final String slug;
  final String name;
  final String description;
}

const List<AppMeta> appList = [
  AppMeta(
    slug: 'hello',
    name: '示例应用',
    description: '用于联调的示例应用',
  ),
  AppMeta(
    slug: 'todos',
    name: '待办清单',
    description: '管理你的个人待办事项',
  ),
];

final Map<String, WidgetBuilder> appComponents = {
  'hello': (_) => HelloApp(api: HelloApiAdapter()),
  'todos': (_) => TodoApp(api: TodoApiAdapter()),
};

AppMeta? getAppMeta(String slug) {
  for (final app in appList) {
    if (app.slug == slug) return app;
  }
  return null;
}

WidgetBuilder? getAppComponent(String slug) => appComponents[slug];
