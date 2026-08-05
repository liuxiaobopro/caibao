import 'package:caibao/app/controllers/controller.dart';
import 'package:caibao/app/events/logout_event.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/app/utils/theme_preference.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProfileController extends Controller {
  User? user;
  String themeMode = themeModeSystem;
  bool loading = true;

  String get themeLabel {
    switch (themeMode) {
      case themeModeLight:
        return '明亮';
      case themeModeDark:
        return '暗黑';
      default:
        return '系统';
    }
  }

  Future<void> bootstrap() async {
    themeMode = await ThemePreference.read();
    await loadUser();
  }

  Future<void> loadUser() async {
    setState(setState: () => loading = true);
    try {
      final me = await api<ApiService>((request) => request.fetchMe());
      setState(setState: () => user = me);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
      final auth = Auth.data();
      if (auth is Map) {
        setState(setState: () => user = User.fromJson(auth));
      }
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => loading = false);
    }
  }

  Future<void> applyTheme(String mode) async {
    final ctx = context;
    if (ctx == null) return;
    await ThemePreference.apply(ctx, mode);
    setState(setState: () => themeMode = mode);
  }

  Future<void> logout() async {
    await event<LogoutEvent>();
  }
}
