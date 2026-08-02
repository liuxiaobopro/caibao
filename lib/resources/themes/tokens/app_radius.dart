import 'package:flutter/material.dart';

/// Border radius aligned with web `--radius: 0.625rem` (10px).
abstract final class AppRadius {
  static const double base = 10;

  static const double sm = base * 0.6; // 6
  static const double md = base * 0.8; // 8
  static const double lg = base; // 10
  static const double xl = base * 1.4; // 14
  static const double x2l = base * 1.8; // 18
  static const double x3l = base * 2.2; // 22
  static const double x4l = base * 2.6; // 26
  static const double full = 999;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get x2lAll => BorderRadius.circular(x2l);
  static BorderRadius get x3lAll => BorderRadius.circular(x3l);
  static BorderRadius get x4lAll => BorderRadius.circular(x4l);
  static BorderRadius get fullAll => BorderRadius.circular(full);
}
