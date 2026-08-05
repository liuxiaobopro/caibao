import 'package:flutter/material.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';

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
      backgroundColor: palette.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: onMenuTap,
        icon: Icon(
          Icons.menu_rounded,
          color: palette.foreground,
          size: 26,
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: palette.foreground,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 1),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: palette.mutedForeground,
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'AI 生成可能有误 注意核实',
            style: TextStyle(
              fontSize: 11,
              color: palette.mutedForeground,
              height: 1.2,
              fontWeight: FontWeight.w400,
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
            Icons.auto_awesome_outlined,
            color: palette.foreground,
            size: AppSizes.iconXl,
          ),
        ),
        const SizedBox(width: AppSpacing.x1),
      ],
    );
  }
}
