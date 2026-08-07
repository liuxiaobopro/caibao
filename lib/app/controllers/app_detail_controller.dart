import 'package:caibao/app/apps/registry.dart';
import 'package:caibao/app/controllers/controller.dart';
import 'package:flutter/widgets.dart';

class AppDetailController extends Controller {
  AppSlug? slug;
  String name = '';
  String description = '';

  void bootstrap(dynamic arg) {
    if (arg is Map) {
      final raw = arg['slug'];
      slug = raw is AppSlug ? raw : AppSlug.tryParse(raw?.toString());
      name = arg['name']?.toString() ?? '';
      description = arg['description']?.toString() ?? '';
    }
    final meta = slug == null ? null : getAppMeta(slug!);
    if (meta != null) {
      name = meta.name;
      description = meta.description;
    }
  }

  WidgetBuilder? get componentBuilder =>
      slug == null ? null : getAppComponent(slug!);
}
