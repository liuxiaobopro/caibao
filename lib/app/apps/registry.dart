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

AppMeta? getAppMeta(String slug) {
  for (final app in appList) {
    if (app.slug == slug) return app;
  }
  return null;
}
