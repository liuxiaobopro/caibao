import 'dart:async';

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
import 'package:caibao/resources/widgets/notifications/notification_bell.dart';
import 'package:flutter/material.dart';

class ChatHistoryDrawer extends StatefulWidget {
  const ChatHistoryDrawer({
    super.key,
    required this.onNewChat,
    required this.onSelectConversation,
    required this.onDeleteConversation,
    required this.onRefresh,
    required this.onNavigate,
    required this.onSearch,
    required this.conversations,
    this.activeConversationId,
    this.user,
    this.loading = false,
    this.keyword = '',
  });

  final VoidCallback onNewChat;
  final ValueChanged<ChatConversation> onSelectConversation;
  final ValueChanged<ChatConversation> onDeleteConversation;
  final Future<void> Function() onRefresh;
  final Future<void> Function(dynamic route) onNavigate;
  final ValueChanged<String> onSearch;
  final List<ChatConversation> conversations;
  final String? activeConversationId;
  final User? user;
  final bool loading;
  final String keyword;

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  static const _searchDebounce = Duration(milliseconds: 300);

  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.keyword);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    final delay = value.trim().isEmpty ? Duration.zero : _searchDebounce;
    _debounce = Timer(delay, () => widget.onSearch(value));
  }

  void _go(BuildContext context, dynamic route) {
    Navigator.of(context).pop();
    widget.onNavigate(route);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final width = MediaQuery.sizeOf(context).width * 0.88;
    final groups = groupConversations(widget.conversations);
    final nickname = widget.user?.displayName ?? '用户';
    final initial =
        nickname.isNotEmpty ? nickname.characters.first : '用';
    final hasKeyword = _searchController.text.trim().isNotEmpty;

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
                    AppSpacing.x3,
                    AppSpacing.x1,
                    AppSpacing.x2,
                    AppSpacing.x2,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.crop_free_rounded,
                          color: palette.foreground,
                          size: AppSizes.iconXl,
                        ),
                      ),
                      const Spacer(),
                      NotificationBell(
                        onNavigate: (route) async => _go(context, route),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x4,
                    0,
                    AppSpacing.x4,
                    AppSpacing.x2,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: '搜索...',
                      isDense: true,
                      filled: true,
                      fillColor: palette.secondary.withValues(alpha: 0.7),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: palette.mutedForeground,
                        size: AppSizes.iconLg,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.fullAll,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.fullAll,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.fullAll,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3,
                        vertical: AppSpacing.x2_5,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.x4,
                      AppSpacing.x4,
                      AppSpacing.x4,
                      AppSpacing.x3_5,
                    ),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: AppRadius.x2lAll,
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _go(context, ProfilePage.path),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: AppRadius.x3l,
                                backgroundColor: palette.brandContainer,
                                backgroundImage: widget.user?.avatarUrl !=
                                            null &&
                                        widget.user!.avatarUrl!.isNotEmpty
                                    ? NetworkImage(widget.user!.avatarUrl!)
                                    : null,
                                child: widget.user?.avatarUrl != null &&
                                        widget.user!.avatarUrl!.isNotEmpty
                                    ? null
                                    : Text(
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
                                    fontWeight: FontWeight.w700,
                                    color: palette.foreground,
                                    letterSpacing: -0.2,
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
                              icon: Icons.cloud_outlined,
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
                const SizedBox(height: AppSpacing.x7),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
                  child: Text(
                    '对话历史',
                    style: TextStyle(
                      fontSize: AppTypography.xl,
                      fontWeight: FontWeight.w800,
                      color: palette.foreground,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: widget.onRefresh,
                    child: widget.loading && widget.conversations.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: AppSizes.previewThumb),
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
                                    hasKeyword ? '无匹配会话' : '暂无会话',
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
                                  AppSpacing.x3,
                                  0,
                                  AppSpacing.x3,
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
                                        padding: const EdgeInsets.fromLTRB(
                                          AppSpacing.x2,
                                          AppSpacing.x4,
                                          AppSpacing.x2,
                                          AppSpacing.x2,
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
                                          selected: item.id ==
                                              widget.activeConversationId,
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            widget.onSelectConversation(item);
                                          },
                                          onLongPress: () => widget
                                              .onDeleteConversation(item),
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
              bottom: AppSpacing.x7,
              child: Center(
                child: Material(
                  color: palette.card,
                  elevation: 0,
                  borderRadius: AppRadius.fullAll,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onNewChat();
                    },
                    borderRadius: AppRadius.fullAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x7,
                        vertical: AppSpacing.x3_5,
                      ),
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: AppRadius.fullAll,
                        boxShadow: AppShadows.soft,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
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
          horizontal: AppSpacing.x1_5,
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
                color: palette.mutedForeground,
                fontWeight: FontWeight.w400,
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
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final ChatConversation conversation;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x0_5),
      child: Material(
        color: selected ? palette.secondary : Colors.transparent,
        borderRadius: AppRadius.xlAll,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: AppRadius.xlAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x3,
              vertical: AppSpacing.x3_5,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: AppSizes.iconMd,
                  color: palette.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.x2_5),
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
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: AppSpacing.x2),
                  Icon(
                    Icons.more_horiz_rounded,
                    size: AppSizes.iconLg,
                    color: palette.mutedForeground,
                  ),
                ] else if (conversation.unread) ...[
                  const SizedBox(width: AppSpacing.x2),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: palette.userBubble,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
