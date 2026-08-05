import 'package:flutter/material.dart';
import 'package:caibao/resources/themes/color_styles.dart';
import 'package:caibao/resources/themes/tokens/app_theme_tokens.dart';
import 'package:caibao/resources/themes/tokens/caibao_palette.dart';
import 'package:caibao/bootstrap/helpers.dart';
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

  /// Theme tokens extension（订阅 Theme.of，切主题自动 rebuild）。
  AppThemeTokens get tokens =>
      Theme.of(this).extension<AppThemeTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppThemeTokens.dark()
          : AppThemeTokens.light());

  /// Web-aligned semantic palette.
  CaibaoPalette get palette => tokens.palette;
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
