import 'dart:io';

import 'package:caibao/config/app.dart';
import 'package:caibao/resources/widgets/splash_screen.dart';
import 'package:caibao/bootstrap/providers.dart';
import 'package:caibao/resources/widgets/main_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Boot
|--------------------------------------------------------------------------
| The boot class is used to initialize your application.
| Providers are booted in the order they are defined.
|-------------------------------------------------------------------------- */

class Boot {
  /// Returns a [BootConfig] containing the setup and boot functions.
  static BootConfig nylo() => BootConfig(
        setup: () async {
          if (AppConfig.showSplashScreen) {
            runApp(SplashScreen.app());
          }

          await _init();
          return await setupApplication(providers);
        },
        boot: (Nylo nylo) async {
          await bootFinished(nylo, providers);

          runApp(Main(nylo));
        },
      );
}

/* Init
|--------------------------------------------------------------------------
| You can use _init to initialize classes, variables, etc.
| It's run before your app providers are booted.
|-------------------------------------------------------------------------- */

Future<void> _init() async {
  await _initBugly();
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
