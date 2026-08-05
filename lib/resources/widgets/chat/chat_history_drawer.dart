import 'package:caibao/app/models/chat_conversation.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/utils/conversation_groups.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/agents_page.dart';
import 'package:caibao/resources/pages/apps_page.dart';
import 'package:caibao/resources/pages/drive_page.dart';
import 'package:caibao/resources/pages/profile_page.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_shadows.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({
    super.key,
    required this.onNewChat,
    required this.onSelectConversation,
    required this.onDeleteConversation,
    required this.onRefresh,
    required this.onNavigate,
    required this.conversations,
    this.user,
    this.loading = false,
  });

  final VoidCallback onNewChat;
  final ValueChanged<ChatConversation> onSelectConversation;
  final ValueChanged<ChatConversation> onDeleteConversation;
  final Future<void> Function() onRefresh;
  final Future<void> Function(dynamic route) onNavigate;
  final List<ChatConversation> conversations;
  final User? user;
  final bool loading;

  void _go(BuildContext context, dynamic route) {
    Navigator.of(context).pop();
    onNavigate(route);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final width = MediaQuery.sizeOf(context).width * 0.88;
    final groups = groupConversations(conversations);
    final nickname = user?.displayName ?? '用户';
    final initial =
        nickname.isNotEmpty ? nickname.characters.first : '用';

    return Drawer(
      width: width,
      backgroundColor: palette.sidebar,
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
                      color: palette.card,
                      borderRadius: AppRadius.x3lAll,
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _go(context, ProfilePage.path),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: palette.brandContainer,
                                child: Text(
                                  initial,
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
                                  nickname,
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
                              icon: Icons.smart_toy_outlined,
                              label: '智能体',
                              onTap: () => _go(context, AgentsPage.path),
                            ),
                            _Shortcut(
                              icon: Icons.folder_outlined,
                              label: '云盘',
                              onTap: () => _go(context, DrivePage.path),
                            ),
                            _Shortcut(
                              icon: Icons.apps_outlined,
                              label: '应用',
                              onTap: () => _go(context, AppsPage.path),
                            ),
                            _Shortcut(
                              icon: Icons.settings_outlined,
                              label: '设置',
                              onTap: () => _go(context, ProfilePage.path),
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
                  child: RefreshIndicator(
                    onRefresh: onRefresh,
                    child: loading && conversations.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(child: CircularProgressIndicator()),
                            ],
                          )
                        : groups.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.x5,
                                  AppSpacing.x8,
                                  AppSpacing.x5,
                                  100,
                                ),
                                children: [
                                  Text(
                                    '暂无对话',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: AppTypography.base,
                                      color: palette.mutedForeground,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            fontWeight: FontWeight.w500,
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
                                          onLongPress: () =>
                                              onDeleteConversation(item),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
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
                  color: palette.card,
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
                        border: Border.all(color: palette.muted),
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
    required this.onLongPress,
  });

  final ChatConversation conversation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: AppSizes.iconLg,
              color: palette.mutedForeground,
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Text(
                conversation.title?.isNotEmpty == true
                    ? conversation.title!
                    : '新对话',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.base,
                  color: palette.foreground,
                  fontWeight: FontWeight.w600,
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
