import 'package:flutter/material.dart';
import 'package:caibao/resources/themes/base_theme.dart';
import 'package:caibao/resources/themes/color_styles.dart';

/* Dark Theme
|--------------------------------------------------------------------------
| Theme Config - config/theme.dart
|-------------------------------------------------------------------------- */

ThemeData darkTheme(ColorStyles color) =>
    buildAppTheme(color, brightness: Brightness.dark);
