import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    this.controller,
    this.onSubmit,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onSubmit;

  void _submit() {
    final text = controller?.text ?? '';
    if (onSubmit == null || text.trim().isEmpty) return;
    onSubmit!(text);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x4,
        AppSpacing.x2,
        AppSpacing.x4,
        AppSpacing.x3,
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: AppRadius.fullAll,
          border: Border.all(color: palette.muted),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.camera_alt_outlined,
                color: palette.foreground,
                size: AppSizes.iconXl,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                enabled: onSubmit != null,
                style: TextStyle(
                  fontSize: AppTypography.base,
                  color: palette.foreground,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '发消息或按住说话',
                  hintStyle: TextStyle(
                    fontSize: AppTypography.base,
                    color: palette.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.x3,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onSubmit == null ? null : _submit,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.send_rounded,
                color: onSubmit == null
                    ? palette.mutedForeground
                    : palette.foreground,
                size: AppSizes.iconXl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
