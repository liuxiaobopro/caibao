import 'package:flutter/material.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';

class ChatQuickAction {
  const ChatQuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class ChatQuickActions extends StatelessWidget {
  const ChatQuickActions({super.key, this.onTap});

  final void Function(ChatQuickAction action)? onTap;

  static const List<ChatQuickAction> actions = [
    ChatQuickAction(icon: Icons.smart_toy_outlined, label: '创建智能体'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ColoredBox(
      color: palette.card,
      child: SizedBox(
        height: AppSizes.buttonLg + AppSpacing.x3,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x4,
            AppSpacing.x3,
            AppSpacing.x4,
            AppSpacing.x1,
          ),
          itemCount: actions.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.x2),
          itemBuilder: (context, index) {
            final action = actions[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap?.call(action),
                borderRadius: AppRadius.fullAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x3_5,
                    vertical: AppSpacing.x2,
                  ),
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: AppRadius.fullAll,
                    border: Border.all(color: palette.muted, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action.icon,
                        size: 15,
                        color: palette.foreground,
                      ),
                      const SizedBox(width: AppSpacing.x1),
                      Text(
                        action.label,
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: palette.foreground,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
