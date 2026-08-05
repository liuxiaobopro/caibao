import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    this.onSubmit,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmit;

  void _submit() {
    final text = controller.text;
    if (onSubmit == null || text.trim().isEmpty) return;
    onSubmit!(text);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      color: palette.card,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x4,
        AppSpacing.x2,
        AppSpacing.x4,
        AppSpacing.x3,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: palette.secondary,
          borderRadius: AppRadius.fullAll,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x1),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.camera_alt_outlined,
                color: palette.foreground,
                size: 22,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                enabled: onSubmit != null,
                style: TextStyle(
                  fontSize: 15,
                  color: palette.foreground,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '发消息或按住说话',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: palette.mutedForeground,
                    fontWeight: FontWeight.w400,
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
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: palette.foreground,
                size: 22,
              ),
            ),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final hasText = controller.text.trim().isNotEmpty;
                if (hasText && onSubmit != null) {
                  return IconButton(
                    onPressed: _submit,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.send_rounded,
                      color: palette.userBubble,
                      size: AppSizes.iconXl,
                    ),
                  );
                }
                return IconButton(
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: palette.foreground,
                    size: 24,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
