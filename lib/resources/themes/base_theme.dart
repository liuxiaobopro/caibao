import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caibao/resources/themes/color_styles.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_theme_tokens.dart';
import 'package:caibao/config/design.dart';
import 'default_text_theme.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Base Theme Builder
|--------------------------------------------------------------------------
| Shared theme configuration for light and dark themes.
| Aligned with caibao-nextjs design tokens.
|-------------------------------------------------------------------------- */

ThemeData buildAppTheme(ColorStyles color, {required Brightness brightness}) {
  final bool isDark = brightness == Brightness.dark;
  final palette = color.palette;
  final colorScheme = palette.toColorScheme(brightness);

  TextTheme textTheme = getAppTextTheme(
    DesignConfig.appFont,
    defaultTextTheme.merge(_textTheme(color)),
  );

  final buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.mdAll);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    primaryColor: palette.brand,
    scaffoldBackgroundColor: palette.background,
    canvasColor: palette.background,
    cardColor: palette.card,
    dividerColor: palette.muted,
    focusColor: palette.ring.withValues(alpha: 0.5),
    hintColor: palette.mutedForeground,
    extensions: <ThemeExtension<dynamic>>[
      isDark ? AppThemeTokens.dark() : AppThemeTokens.light(),
    ],
    dividerTheme: DividerThemeData(
      color: palette.muted,
      thickness: 1,
      space: AppSpacing.x4,
    ),
    cardTheme: CardThemeData(
      color: palette.card.withValues(alpha: 0.6),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      margin: EdgeInsets.zero,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.secondary.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(
          color: palette.ring.withValues(alpha: 0.5),
          width: AppSizes.focusRing,
        ),
      ),
      hintStyle: TextStyle(color: palette.mutedForeground),
    ),
    datePickerTheme: isDark
        ? DatePickerThemeData(
            headerForegroundColor: palette.foreground,
            weekdayStyle: TextStyle(color: palette.foreground),
            dayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return palette.brandOn;
                }
                return palette.foreground;
              },
            ),
          )
        : null,
    timePickerTheme: isDark
        ? TimePickerThemeData(
            hourMinuteTextColor: palette.foreground,
            dialTextColor: palette.foreground,
            dayPeriodTextColor: palette.foreground,
            helpTextStyle: TextStyle(color: palette.foreground),
            dayPeriodBorderSide: BorderSide(color: palette.muted),
            dialBackgroundColor: palette.secondary,
          )
        : null,
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: color.appBar.background,
      titleTextStyle:
          textTheme.titleLarge!.copyWith(color: color.appBar.content),
      iconTheme: IconThemeData(color: color.appBar.content),
      elevation: 0,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.brand,
        minimumSize: const Size(0, AppSizes.buttonMd),
        shape: buttonShape,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: palette.brandOn,
        backgroundColor: palette.brand,
        disabledForegroundColor: palette.brandOn.withValues(alpha: 0.6),
        disabledBackgroundColor: palette.brand.withValues(alpha: 0.5),
        minimumSize: const Size(0, AppSizes.buttonMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
        elevation: 0,
        shape: buttonShape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: palette.brandOn,
        backgroundColor: palette.brand,
        minimumSize: const Size(0, AppSizes.buttonMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.foreground,
        minimumSize: const Size(0, AppSizes.buttonMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
        side: BorderSide(color: palette.muted),
        shape: buttonShape,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.brand,
      foregroundColor: palette.brandOn,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: color.bottomTabBar.background,
      unselectedIconTheme:
          IconThemeData(color: color.bottomTabBar.iconUnselected),
      selectedIconTheme: IconThemeData(color: color.bottomTabBar.iconSelected),
      unselectedLabelStyle:
          TextStyle(color: color.bottomTabBar.labelUnselected),
      selectedLabelStyle: TextStyle(color: color.bottomTabBar.labelSelected),
      selectedItemColor: color.bottomTabBar.labelSelected,
      unselectedItemColor: color.bottomTabBar.labelUnselected,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.secondary,
      selectedColor: palette.brandContainer,
      labelStyle: TextStyle(color: palette.foreground, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      side: BorderSide.none,
    ),
    textTheme: textTheme,
  );
}

TextTheme _textTheme(ColorStyles colors) {
  final Color content = colors.palette.foreground;
  final Color muted = colors.palette.mutedForeground;

  return TextTheme(
    displayLarge: TextStyle(color: content),
    displayMedium: TextStyle(color: content),
    displaySmall: TextStyle(color: content),
    headlineLarge: TextStyle(color: content),
    headlineMedium: TextStyle(color: content),
    headlineSmall: TextStyle(color: content),
    titleLarge: TextStyle(color: content),
    titleMedium: TextStyle(color: content),
    titleSmall: TextStyle(color: content),
    bodyLarge: TextStyle(color: content),
    bodyMedium: TextStyle(color: content),
    bodySmall: TextStyle(color: muted),
    labelLarge: TextStyle(color: content),
    labelMedium: TextStyle(color: muted),
    labelSmall: TextStyle(color: muted),
  );
}
