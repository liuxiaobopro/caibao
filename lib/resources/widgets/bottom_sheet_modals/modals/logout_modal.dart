import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/widgets/local_asset_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Used in BottomSheetModal
class LogoutModal extends StatelessWidget {
  const LogoutModal({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: <Widget>[
        Container(
          height: AppSizes.logoBadge,
          width: AppSizes.logoBadge,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.secondary,
            borderRadius: AppRadius.fullAll,
          ),
          child: LocalAsset.image(
            "logo.png",
            height: AppSizes.logoMark,
            width: AppSizes.logoMark,
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        TextTr(
          "Are you sure you want to logout of your account?",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.x4),
      ],
    );
  }
}
