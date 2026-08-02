import '/resources/themes/color_styles.dart';
import '/resources/themes/tokens/caibao_palette.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Light Theme Colors
|-------------------------------------------------------------------------- */

class LightThemeColors extends ColorStyles {
  static const CaibaoPalette _p = CaibaoPalette.light;

  @override
  CaibaoPalette get palette => _p;

  @override
  GeneralColors get general => GeneralColors(
        background: _p.background,
        content: _p.foreground,
        primaryAccent: _p.brand,
        surface: _p.card,
        surfaceContent: _p.cardForeground,
      );

  @override
  AppBarColors get appBar => AppBarColors(
        background: _p.card,
        content: _p.foreground,
      );

  @override
  BottomTabBarColors get bottomTabBar => BottomTabBarColors(
        background: _p.card,
        iconSelected: _p.brand,
        iconUnselected: _p.mutedForeground,
        labelSelected: _p.brand,
        labelUnselected: _p.mutedForeground,
      );
}
