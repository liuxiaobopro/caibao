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
    ChatQuickAction(icon: Icons.bolt_outlined, label: '快速'),
    ChatQuickAction(icon: Icons.auto_awesome, label: 'AI 创作'),
    ChatQuickAction(icon: Icons.shopping_bag_outlined, label: '买前问菜包'),
    ChatQuickAction(icon: Icons.edit_square, label: '帮我写'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
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
                  color: Colors.white,
                  borderRadius: AppRadius.fullAll,
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      action.icon,
                      size: AppSizes.iconMd,
                      color: palette.foreground,
                    ),
                    const SizedBox(width: AppSpacing.x1_5),
                    Text(
                      action.label,
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: palette.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
