import 'package:caibao/app/apps/adapters/crontab_api_adapter.dart';
import 'package:caibao/app/apps/adapters/hello_api_adapter.dart';
import 'package:caibao/app/apps/adapters/todo_api_adapter.dart';
import 'package:caibao_crontab_app/caibao_crontab_app.dart';
import 'package:caibao_hello_app/caibao_hello_app.dart';
import 'package:caibao_todo_app/caibao_todo_app.dart';
import 'package:flutter/widgets.dart';

enum AppSlug {
  hello('hello'),
  todos('todos'),
  crontab('crontab');

  const AppSlug(this.value);

  final String value;

  static AppSlug? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final item in AppSlug.values) {
      if (item.value == raw) return item;
    }
    return null;
  }
}

class AppMeta {
  const AppMeta({
    required this.slug,
    required this.name,
    required this.description,
  });

  final AppSlug slug;
  final String name;
  final String description;
}

const List<AppMeta> appList = [
  AppMeta(
    slug: AppSlug.hello,
    name: '示例应用',
    description: '用于联调的示例应用',
  ),
  AppMeta(
    slug: AppSlug.todos,
    name: '待办清单',
    description: '管理你的个人待办事项',
  ),
  AppMeta(
    slug: AppSlug.crontab,
    name: '计划任务',
    description: '定时站内通知或邮件提醒',
  ),
];

final Map<AppSlug, WidgetBuilder> appComponents = {
  AppSlug.hello: (_) => HelloApp(api: HelloApiAdapter()),
  AppSlug.todos: (_) => TodoApp(api: TodoApiAdapter()),
  AppSlug.crontab: (_) => CrontabApp(api: CrontabApiAdapter()),
};

AppMeta? getAppMeta(AppSlug slug) {
  for (final app in appList) {
    if (app.slug == slug) return app;
  }
  return null;
}

WidgetBuilder? getAppComponent(AppSlug slug) => appComponents[slug];
