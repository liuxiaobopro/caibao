import 'dart:ui';

import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/widgets/buttons/abstract/app_button.dart';
import 'package:flutter/material.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';

class TransparencyButton extends StatefulAppButton {
  final Color? contentColor;
  final double blurAmount;

  TransparencyButton({
    super.key,
    required super.text,
    super.onPressed,
    super.submitForm,
    super.onFailure,
    super.showToastError = true,
    super.loadingStyle,
    super.animationStyle,
    super.splashStyle,
    this.contentColor,
    this.blurAmount = 10,
    super.width,
    super.height,
  });

  @override
  Widget buildButton(BuildContext context) {
    final palette = context.palette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color fgColor = contentColor ?? palette.foreground;
    final Color bgColor = isDark
        ? palette.brandOn.withValues(alpha: 0.12)
        : palette.foreground.withValues(alpha: 0.05);
    final BorderRadius radius = AppRadius.xlAll;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            border: Border.all(
              color: isDark
                  ? palette.brandOn.withValues(alpha: 0.1)
                  : palette.foreground.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: fgColor,
              fontSize: AppTypography.base,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
