import 'package:caibao/app/analytics/analytics.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LogoutEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic data) async {
    Analytics.instance.track('logout', page: '/profile');
    await Analytics.instance.flush();
    Analytics.instance.clear();
    await Auth.logout();

    routeToInitial();
  }
}
