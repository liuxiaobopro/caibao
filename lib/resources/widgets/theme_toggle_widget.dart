import 'package:caibao/bootstrap/extensions.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:nylo_framework/theme/helper/ny_theme.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    bool isThemeDark = context.isThemeDark;
    final palette = context.palette;

    if (context.isDeviceInDarkMode) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: AppSpacing.x2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Dark Mode", textAlign: TextAlign.center).fontWeightBold(),
            Text(
                "Your device is in Dark Mode, turn off Dark Mode from your device settings to change the theme",
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        Switch(
            trackOutlineColor: WidgetStateProperty.all(
              isThemeDark ? palette.brandContainer : palette.mutedForeground,
            ),
            value: isThemeDark,
            onChanged: (bool value) {
              NyTheme.set(
                context,
                id: value ? 'dark_theme' : 'light_theme',
              );
            }),
        Text("${isThemeDark ? "Dark" : "Light"} Mode"),
      ],
    );
  }
}
