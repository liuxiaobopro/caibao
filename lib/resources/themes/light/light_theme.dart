import 'package:flutter/material.dart';
import 'package:caibao/resources/themes/base_theme.dart';
import 'package:caibao/resources/themes/color_styles.dart';

/* Light Theme
|--------------------------------------------------------------------------
| Theme Config - config/theme.dart
|-------------------------------------------------------------------------- */

ThemeData lightTheme(ColorStyles color) =>
    buildAppTheme(color, brightness: Brightness.light);
