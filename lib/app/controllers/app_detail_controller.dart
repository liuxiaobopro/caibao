import 'package:caibao/app/apps/registry.dart';
import 'package:caibao/app/controllers/controller.dart';
import 'package:flutter/widgets.dart';

class AppDetailController extends Controller {
  String slug = '';
  String name = '';
  String description = '';

  void bootstrap(dynamic arg) {
    if (arg is Map) {
      slug = arg['slug']?.toString() ?? '';
      name = arg['name']?.toString() ?? '';
      description = arg['description']?.toString() ?? '';
    }
    final meta = getAppMeta(slug);
    if (meta != null) {
      name = meta.name;
      description = meta.description;
    }
  }

  WidgetBuilder? get componentBuilder => getAppComponent(slug);
}
