import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:nylo_framework/theme/helper/ny_theme.dart';

const String themeModeLight = 'light';
const String themeModeDark = 'dark';
const String themeModeSystem = 'system';

class ThemePreference {
  static const String _storageKey = 'SK_THEME_MODE';

  static Future<String> read() async {
    final value = await NyStorage.read(_storageKey);
    if (value == themeModeLight ||
        value == themeModeDark ||
        value == themeModeSystem) {
      return value;
    }
    return themeModeSystem;
  }

  static Future<void> save(String mode) async {
    await NyStorage.save(_storageKey, mode);
  }

  static Future<void> restore(BuildContext context) async {
    final mode = await read();
    if (!context.mounted) return;
    await apply(context, mode);
  }

  static Future<void> apply(BuildContext context, String mode) async {
    await save(mode);
    if (!context.mounted) return;

    if (mode == themeModeSystem) {
      await NyTheme.setFollowSystem(true);
    } else {
      await NyTheme.setFollowSystem(false);
      if (!context.mounted) return;
      await NyTheme.set(
        context,
        id: mode == themeModeDark ? 'dark_theme' : 'light_theme',
        remember: true,
      );
    }
    syncStatusBar();
  }

  static void syncStatusBar() {
    final isDark = NyTheme.isDark();
    final background = NyTheme.themeData()?.scaffoldBackgroundColor ??
        (isDark ? const Color(0xFF06070A) : const Color(0xFFF3F5F9));

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
}
