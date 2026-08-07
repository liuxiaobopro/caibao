import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/widgets/buttons/abstract/app_button.dart';
import 'package:flutter/material.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';

class GradientButton extends StatefulAppButton {
  final List<Color>? gradientColors;
  final Color? contentColor;
  final Alignment gradientBegin;
  final Alignment gradientEnd;

  GradientButton({
    super.key,
    required super.text,
    super.onPressed,
    super.submitForm,
    super.onFailure,
    super.showToastError = true,
    super.loadingStyle,
    super.animationStyle,
    super.splashStyle,
    this.gradientColors,
    super.width,
    super.height,
    this.contentColor,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
  });

  @override
  Widget buildButton(BuildContext context) {
    final palette = context.palette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Color> colors = gradientColors ??
        <Color>[
          palette.brand,
          palette.brandDark,
        ];
    final Color fgColor = contentColor ?? palette.brandOn;
    final BorderRadius radius = AppRadius.xlAll;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: gradientBegin,
          end: gradientEnd,
        ),
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.first.withValues(alpha: isDark ? 0.25 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: colors.last.withValues(alpha: isDark ? 0.15 : 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: fgColor,
            fontSize: AppTypography.base,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
