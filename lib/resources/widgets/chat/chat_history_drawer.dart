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
                  padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.crop_free_rounded,
                          color: palette.foreground,
                          size: 24,
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                        size: 20,
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
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(18),
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
                                radius: 22,
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  nickname,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: palette.foreground,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
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
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '对话历史',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: palette.foreground,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: widget.onRefresh,
                    child: widget.loading && widget.conversations.isEmpty
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
                                  20,
                                  32,
                                  20,
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
                                  12,
                                  0,
                                  12,
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
                                          8,
                                          16,
                                          8,
                                          8,
                                        ),
                                        child: Text(
                                          group.label,
                                          style: TextStyle(
                                            fontSize: 13,
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
              bottom: 28,
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
                        horizontal: 28,
                        vertical: 14,
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
                            size: 20,
                            color: palette.foreground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '新建对话',
                            style: TextStyle(
                              fontSize: 15,
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Icon(icon, size: 24, color: palette.foreground),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? palette.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
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
                      fontSize: 15,
                      color: palette.foreground,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.more_horiz_rounded,
                    size: AppSizes.iconLg,
                    color: palette.mutedForeground,
                  ),
                ] else if (conversation.unread) ...[
                  const SizedBox(width: 8),
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
