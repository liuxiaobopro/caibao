import 'package:flutter/material.dart';
import 'package:caibao/app/mocks/chat_mock_data.dart';
import 'package:caibao/app/models/chat_conversation.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/profile_page.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_shadows.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({
    super.key,
    required this.onNewChat,
    required this.onSelectConversation,
  });

  final VoidCallback onNewChat;
  final ValueChanged<ChatConversation> onSelectConversation;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final width = MediaQuery.sizeOf(context).width * 0.88;
    final groups = ChatMockData.conversationGroups();
    final user = ChatMockData.user;

    return Drawer(
      width: width,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x4,
                    AppSpacing.x2,
                    AppSpacing.x2,
                    AppSpacing.x3,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.crop_free,
                          color: palette.foreground,
                          size: AppSizes.iconXl,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_none,
                          color: palette.foreground,
                          size: AppSizes.iconXl,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.search,
                          color: palette.foreground,
                          size: AppSizes.iconXl,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.x4,
                      AppSpacing.x4,
                      AppSpacing.x4,
                      AppSpacing.x3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.x3lAll,
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            routeTo(ProfilePage.path);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: palette.brandContainer,
                                child: Text(
                                  user.nickname.characters.first,
                                  style: TextStyle(
                                    color: palette.brandDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: AppTypography.lg,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.x3),
                              Expanded(
                                child: Text(
                                  user.nickname,
                                  style: TextStyle(
                                    fontSize: AppTypography.lg,
                                    fontWeight: FontWeight.w600,
                                    color: palette.foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Shortcut(
                              icon: Icons.cloud_outlined,
                              label: '云空间',
                              onTap: () {},
                            ),
                            _Shortcut(
                              icon: Icons.star_border,
                              label: '收藏',
                              onTap: () {},
                            ),
                            _Shortcut(
                              icon: Icons.folder_outlined,
                              label: '档案',
                              onTap: () {},
                            ),
                            _Shortcut(
                              icon: Icons.settings_outlined,
                              label: '设置',
                              onTap: () {
                                Navigator.of(context).pop();
                                routeTo(ProfilePage.path);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.x5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
                  child: Row(
                    children: [
                      Text(
                        '问答',
                        style: TextStyle(
                          fontSize: AppTypography.lg,
                          fontWeight: FontWeight.w700,
                          color: palette.foreground,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.more_horiz,
                        color: palette.mutedForeground,
                        size: AppSizes.iconXl,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.x5,
                      0,
                      AppSpacing.x5,
                      100,
                    ),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.x3,
                              bottom: AppSpacing.x2,
                            ),
                            child: Text(
                              group.label,
                              style: TextStyle(
                                fontSize: AppTypography.sm,
                                color: palette.mutedForeground,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          ...group.items.map(
                            (item) => _ConversationTile(
                              conversation: item,
                              onTap: () {
                                Navigator.of(context).pop();
                                onSelectConversation(item);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.x6,
              child: Center(
                child: Material(
                  color: Colors.white,
                  elevation: 2,
                  shadowColor: const Color(0x26000000),
                  borderRadius: AppRadius.fullAll,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onNewChat();
                    },
                    borderRadius: AppRadius.fullAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x6,
                        vertical: AppSpacing.x3_5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.fullAll,
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: AppSizes.iconLg,
                            color: palette.foreground,
                          ),
                          const SizedBox(width: AppSpacing.x2),
                          Text(
                            '新建对话',
                            style: TextStyle(
                              fontSize: AppTypography.base,
                              fontWeight: FontWeight.w600,
                              color: palette.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x1,
        ),
        child: Column(
          children: [
            Icon(icon, size: AppSizes.iconXl, color: palette.foreground),
            const SizedBox(height: AppSpacing.x1_5),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.xs,
                color: palette.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                conversation.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.base,
                  color: palette.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (conversation.unread) ...[
              const SizedBox(width: AppSpacing.x2),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
