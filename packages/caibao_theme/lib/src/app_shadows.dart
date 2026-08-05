import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const List<BoxShadow> none = <BoxShadow>[];

  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 15,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> panelLight = <BoxShadow>[
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 36,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> panelDark = <BoxShadow>[
    BoxShadow(
      color: Color(0x59000000),
      blurRadius: 50,
      offset: Offset(0, 18),
    ),
  ];

  static List<BoxShadow> panel(Brightness brightness) =>
      brightness == Brightness.dark ? panelDark : panelLight;
}
