import 'package:flutter/material.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.onMenuTap,
    this.title = '新对话',
  });

  final VoidCallback onMenuTap;
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppBar(
      backgroundColor: palette.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: onMenuTap,
        icon: Icon(Icons.menu, color: palette.foreground, size: AppSizes.iconXl),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.base,
                      fontWeight: FontWeight.w700,
                      color: palette.foreground,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right,
                  size: AppSizes.iconLg,
                  color: palette.foreground,
                ),
              ],
            ),
          ),
          Text(
            'AI 生成可能有误 注意核实',
            style: TextStyle(
              fontSize: 11,
              color: palette.mutedForeground,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.phone_outlined,
            color: palette.foreground,
            size: AppSizes.iconXl,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.volume_off_outlined,
            color: palette.foreground,
            size: AppSizes.iconXl,
          ),
        ),
        const SizedBox(width: AppSpacing.x1),
      ],
    );
  }
}
