import 'package:flutter/material.dart';
import '/resources/themes/color_styles.dart';
import '/resources/themes/tokens/app_theme_tokens.dart';
import '/resources/themes/tokens/caibao_palette.dart';
import '/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// [Text] Extensions
extension NyText on Text {
  Text setColor(
      BuildContext context, Color Function(ColorStyles color) newColor,
      {String? themeId}) {
    return copyWith(
        style: TextStyle(
            color:
                newColor(ThemeColorResolver.get(context, themeId: themeId))));
  }
}

/// [BuildContext] Extensions
extension NyApp on BuildContext {
  /// Nylo color styles (general / appBar / bottomTabBar / palette).
  ColorStyles get color => ThemeColorResolver.get(this);

  /// Web-aligned semantic palette.
  CaibaoPalette get palette => color.palette;

  /// Theme tokens extension.
  AppThemeTokens get tokens =>
      Theme.of(this).extension<AppThemeTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppThemeTokens.dark()
          : AppThemeTokens.light());
}

/// [TextStyle] Extensions
extension NyTextStyle on TextStyle {
  TextStyle? setColor(
      BuildContext context, Color Function(ColorStyles color) newColor,
      {String? themeId}) {
    return copyWith(
        color: newColor(ThemeColorResolver.get(context, themeId: themeId)));
  }
}
