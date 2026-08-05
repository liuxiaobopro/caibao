import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/widgets/buttons/abstract/app_button.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatefulAppButton {
  final Color? backgroundColor;
  final Color? contentColor;

  SecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.submitForm,
    super.onFailure,
    super.showToastError = true,
    super.loadingStyle,
    super.width,
    super.height,
    super.animationStyle,
    super.splashStyle,
    this.contentColor,
    this.backgroundColor,
  });

  @override
  Widget buildButton(BuildContext context) {
    final palette = context.palette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = backgroundColor ?? palette.secondary;
    final Color fgColor = contentColor ?? palette.secondaryForeground;
    final BorderRadius radius = BorderRadius.circular(14);

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        boxShadow: isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: palette.foreground.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: fgColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
