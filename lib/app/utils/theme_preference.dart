import 'package:flutter/material.dart';
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

  static Future<void> apply(BuildContext context, String mode) async {
    await save(mode);
    if (mode == themeModeSystem) {
      await NyTheme.setFollowSystem(true);
      return;
    }
    await NyTheme.setFollowSystem(false);
    if (!context.mounted) return;
    await NyTheme.set(
      context,
      id: mode == themeModeDark ? 'dark_theme' : 'light_theme',
      remember: true,
    );
  }
}
