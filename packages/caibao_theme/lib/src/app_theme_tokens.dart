import 'package:flutter/material.dart';

import 'app_shadows.dart';
import 'caibao_palette.dart';

/// ThemeExtension — access via `context.tokens` / `Theme.of(context).extension`.
@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({required this.palette});

  final CaibaoPalette palette;

  List<BoxShadow> get panelShadow => AppShadows.panel(
        palette.background.computeLuminance() < 0.5
            ? Brightness.dark
            : Brightness.light,
      );

  static AppThemeTokens light() =>
      const AppThemeTokens(palette: CaibaoPalette.light);

  static AppThemeTokens dark() =>
      const AppThemeTokens(palette: CaibaoPalette.dark);

  @override
  AppThemeTokens copyWith({CaibaoPalette? palette}) {
    return AppThemeTokens(palette: palette ?? this.palette);
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return t < 0.5 ? this : other;
  }
}
