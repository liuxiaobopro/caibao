import 'package:flutter/material.dart';

import 'app_theme_tokens.dart';
import 'caibao_palette.dart';

/// Mini-apps: `import 'package:caibao_theme/caibao_theme.dart'` then `context.palette`.
extension CaibaoThemeContext on BuildContext {
  AppThemeTokens get tokens {
    final ext = Theme.of(this).extension<AppThemeTokens>();
    if (ext != null) return ext;
    return Theme.of(this).brightness == Brightness.dark
        ? AppThemeTokens.dark()
        : AppThemeTokens.light();
  }

  CaibaoPalette get palette => tokens.palette;
}
