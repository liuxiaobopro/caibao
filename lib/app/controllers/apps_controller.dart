import 'package:caibao/app/apps/registry.dart';
import 'package:caibao/app/controllers/controller.dart';
import 'package:caibao/resources/pages/app_detail_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AppsController extends Controller {
  List<AppMeta> get apps => appList;

  void openApp(AppMeta app) {
    routeTo(
      AppDetailPage.path,
      data: {
        'slug': app.slug,
        'name': app.name,
        'description': app.description,
      },
    );
  }
}
