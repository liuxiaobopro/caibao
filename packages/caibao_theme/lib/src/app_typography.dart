import 'package:flutter/material.dart';

/// Font sizes / line heights aligned with Tailwind + chat font tokens.
abstract final class AppTypography {
  static const double xs = 12;
  static const double sm = 14;
  static const double base = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double x2l = 24;
  static const double x3l = 30;
  static const double x4l = 36;

  static const double leadingXs = 16;
  static const double leadingSm = 20;
  static const double leadingBase = 24;
  static const double leadingLg = 28;
  static const double leadingXl = 28;
  static const double leadingX2l = 32;

  /// Chat bubble: sm / md / lg (`lib/chat-font-size.ts`).
  static const TextStyle chatSm = TextStyle(
    fontSize: sm,
    fontWeight: FontWeight.w500,
    height: leadingBase / sm,
  );
  static const TextStyle chatMd = TextStyle(
    fontSize: base,
    fontWeight: FontWeight.w500,
    height: leadingLg / base,
  );
  static const TextStyle chatLg = TextStyle(
    fontSize: lg,
    fontWeight: FontWeight.w500,
    height: leadingX2l / lg,
  );
}
