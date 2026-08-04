import 'dart:io';

import 'package:caibao/bootstrap/env.g.dart';
import 'package:flutter/foundation.dart';
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
    await _initBugly();
  });
}

Future<void> _initBugly() async {
  if (getEnv('BUGLY_ENABLED', defaultValue: false) != true) {
    return;
  }

  final androidAppId =
      getEnv('BUGLY_ANDROID_APP_ID', defaultValue: '')?.toString() ?? '';
  final iOSAppId =
      getEnv('BUGLY_IOS_APP_ID', defaultValue: '')?.toString() ?? '';

  if (Platform.isAndroid && androidAppId.isEmpty) {
    return;
  }
  if (Platform.isIOS && iOSAppId.isEmpty) {
    return;
  }

  await FlutterBugly.init(
    androidAppId: androidAppId.isEmpty ? null : androidAppId,
    iOSAppId: iOSAppId.isEmpty ? null : iOSAppId,
    debugMode: kDebugMode,
  );
}
