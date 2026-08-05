import 'package:caibao/bootstrap/env.g.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:nylo_framework/nylo_framework.dart';

import 'bootstrap/boot.dart';

/// Nylo - Framework for Flutter Developers
/// Docs: https://nylo.dev/docs/7.x

void main() {
  FlutterBugly.postCatchedException(() async {
    await Nylo.init(
      env: Env.get,
      setup: Boot.nylo(),
      appLifecycle: {
        // Uncomment the code below to enable app lifecycle events
        // AppLifecycleState.resumed: () {
        //   print("App resumed");
        // },
        // AppLifecycleState.paused: () {
        //   print("App paused");
        // },
      },
    );
  });
}
