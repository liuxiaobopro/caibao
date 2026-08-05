import 'dart:io';

import 'package:caibao/app/analytics/analytics.dart';
import 'package:caibao/config/storage_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:getuiflut/getuiflut.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PushNotificationsProvider implements NyProvider {
  final Getuiflut _getui = Getuiflut();

  @override
  setup(Nylo nylo) async {
    nylo.useLocalNotifications();
    return nylo;
  }

  @override
  boot(Nylo nylo) async {
    final enabled = getEnv('GETUI_ENABLED', defaultValue: false) == true;
    if (!enabled) {
      return;
    }

    _registerEventHandlers();

    if (Platform.isIOS) {
      final appId = getEnv('GETUI_APP_ID', defaultValue: '')?.toString() ?? '';
      final appKey = getEnv('GETUI_APP_KEY', defaultValue: '')?.toString() ?? '';
      final appSecret =
          getEnv('GETUI_APP_SECRET', defaultValue: '')?.toString() ?? '';
      if (appId.isEmpty || appKey.isEmpty || appSecret.isEmpty) {
        NyLogger.info('Getui skipped: missing iOS credentials');
        return;
      }
      _getui.startSdk(appId: appId, appKey: appKey, appSecret: appSecret);
    } else if (Platform.isAndroid) {
      _getui.initGetuiSdk;
    }
  }

  void _registerEventHandlers() {
    _getui.addEventHandler(
      onReceiveClientId: (String message) async {
        NyLogger.info('Getui CID: $message');
        await NyStorage.save(StorageKeysConfig.getuiClientId, message);
        Analytics.instance.track(
          'getui_cid',
          props: {'cid': message},
        );
      },
      onReceiveOnlineState: (String online) async {
        if (kDebugMode) {
          NyLogger.info('Getui online: $online');
        }
      },
      onReceivePayload: (Map<String, dynamic> message) async {
        NyLogger.info('Getui payload: $message');
      },
      onSetTagResult: (Map<String, dynamic> message) async {},
      onAliasResult: (Map<String, dynamic> message) async {},
      onQueryTagResult: (Map<String, dynamic> message) async {},
      onRegisterDeviceToken: (String message) async {
        if (kDebugMode) {
          NyLogger.info('Getui deviceToken: $message');
        }
      },
      onNotificationMessageArrived: (Map<String, dynamic> msg) async {
        NyLogger.info('Getui notification arrived: $msg');
      },
      onNotificationMessageClicked: (Map<String, dynamic> msg) async {
        NyLogger.info('Getui notification clicked: $msg');
      },
      onTransmitUserMessageReceive: (Map<String, dynamic> msg) async {
        NyLogger.info('Getui transmit: $msg');
      },
      onReceiveNotificationResponse: (Map<String, dynamic> message) async {
        NyLogger.info('Getui notification response: $message');
      },
      onAppLinkPayload: (String message) async {},
      onPushModeResult: (Map<String, dynamic> message) async {},
      onWillPresentNotification: (Map<String, dynamic> message) async {},
      onOpenSettingsForNotification: (Map<String, dynamic> message) async {},
      onGrantAuthorization: (String granted) async {
        if (kDebugMode) {
          NyLogger.info('Getui auth: $granted');
        }
      },
      onLiveActivityResult: (Map<String, dynamic> message) async {},
      onRegisterPushToStartTokenResult: (Map<String, dynamic> message) async {},
    );
  }
}
