import 'package:flutter/material.dart';
import 'tokens/app_typography.dart';

/* Default text theme — aligned with web Tailwind sizes
|-------------------------------------------------------------------------- */

const TextTheme defaultTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontSize: AppTypography.x4l,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  ),
  displayMedium: TextStyle(
    fontSize: AppTypography.x3l,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.25,
  ),
  displaySmall: TextStyle(
    fontSize: AppTypography.x2l,
    fontWeight: FontWeight.w700,
    height: 1.3,
  ),
  headlineLarge: TextStyle(
    fontSize: AppTypography.x2l,
    fontWeight: FontWeight.w700,
    height: AppTypography.leadingX2l / AppTypography.x2l,
  ),
  headlineMedium: TextStyle(
    fontSize: AppTypography.xl,
    fontWeight: FontWeight.w700,
    height: AppTypography.leadingXl / AppTypography.xl,
  ),
  headlineSmall: TextStyle(
    fontSize: AppTypography.lg,
    fontWeight: FontWeight.w600,
    height: AppTypography.leadingLg / AppTypography.lg,
  ),
  titleLarge: TextStyle(
    fontSize: AppTypography.lg,
    fontWeight: FontWeight.w700,
    height: AppTypography.leadingLg / AppTypography.lg,
  ),
  titleMedium: TextStyle(
    fontSize: AppTypography.base,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: AppTypography.leadingBase / AppTypography.base,
  ),
  titleSmall: TextStyle(
    fontSize: AppTypography.sm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: AppTypography.leadingSm / AppTypography.sm,
  ),
  bodyLarge: TextStyle(
    fontSize: AppTypography.base,
    fontWeight: FontWeight.w500,
    height: AppTypography.leadingLg / AppTypography.base,
  ),
  bodyMedium: TextStyle(
    fontSize: AppTypography.sm,
    fontWeight: FontWeight.w500,
    height: AppTypography.leadingBase / AppTypography.sm,
  ),
  bodySmall: TextStyle(
    fontSize: AppTypography.xs,
    fontWeight: FontWeight.w500,
    height: AppTypography.leadingXs / AppTypography.xs,
  ),
  labelLarge: TextStyle(
    fontSize: AppTypography.sm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: AppTypography.leadingSm / AppTypography.sm,
  ),
  labelMedium: TextStyle(
    fontSize: AppTypography.xs,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: AppTypography.leadingXs / AppTypography.xs,
  ),
  labelSmall: TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  ),
);
