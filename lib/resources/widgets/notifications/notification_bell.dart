import 'package:caibao/app/models/notification_item.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/app/utils/notification_link.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({
    super.key,
    this.onNavigate,
  });

  /// Called with a Flutter route after closing the sheet (and optionally drawer).
  final Future<void> Function(dynamic route)? onNavigate;

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with WidgetsBindingObserver {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshUnread();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshUnread();
    }
  }

  Future<void> _refreshUnread() async {
    try {
      final count =
          await api<ApiService>((r) => r.getUnreadNotificationCount());
      if (!mounted) return;
      setState(() => _unread = count);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _openSheet() async {
    final palette = context.palette;
    var items = <NotificationItem>[];
    var unread = _unread;
    var loading = true;
    var loadStarted = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> load() async {
              try {
                final results = await Future.wait([
                  api<ApiService>(
                    (r) => r.listNotifications(pageNum: 1, pageSize: 20),
                  ),
                  api<ApiService>((r) => r.getUnreadNotificationCount()),
                ]);
                final data =
                    results[0] as ({List<NotificationItem> items, int total});
                final count = results[1] as int;
                if (!sheetContext.mounted) return;
                setSheetState(() {
                  items = data.items;
                  unread = count;
                  loading = false;
                });
                if (mounted) setState(() => _unread = count);
              } catch (_) {
                if (!sheetContext.mounted) return;
                setSheetState(() => loading = false);
              }
            }

            if (!loadStarted) {
              loadStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                load();
              });
            }

            Future<void> onItemTap(NotificationItem item) async {
              if (!item.read && item.id != null) {
                try {
                  await api<ApiService>(
                    (r) => r.markNotificationRead(item.id!),
                  );
                  if (!sheetContext.mounted) return;
                  setSheetState(() {
                    items = [
                      for (final row in items)
                        if (row.id == item.id)
                          NotificationItem(
                            id: row.id,
                            scope: row.scope,
                            title: row.title,
                            content: row.content,
                            link: row.link,
                            read: true,
                            createdAt: row.createdAt,
                            updatedAt: row.updatedAt,
                          )
                        else
                          row,
                    ];
                    unread = unread > 0 ? unread - 1 : 0;
                  });
                  if (mounted) setState(() => _unread = unread);
                } catch (_) {
                  // ignore
                }
              }

              final route = resolveNotificationLink(item.link);
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
              if (route != null && widget.onNavigate != null) {
                await widget.onNavigate!(route);
              }
            }

            Future<void> onReadAll() async {
              try {
                await api<ApiService>((r) => r.markAllNotificationsRead());
                if (!sheetContext.mounted) return;
                setSheetState(() {
                  items = [
                    for (final row in items)
                      NotificationItem(
                        id: row.id,
                        scope: row.scope,
                        title: row.title,
                        content: row.content,
                        link: row.link,
                        read: true,
                        createdAt: row.createdAt,
                        updatedAt: row.updatedAt,
                      ),
                  ];
                  unread = 0;
                });
                if (mounted) setState(() => _unread = 0);
              } catch (_) {
                // ignore
              }
            }

            final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.7;

            return SafeArea(
              child: SizedBox(
                height: maxHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                      child: Row(
                        children: [
                          Text(
                            '消息通知',
                            style: TextStyle(
                              fontSize: AppTypography.base,
                              fontWeight: FontWeight.w600,
                              color: palette.foreground,
                            ),
                          ),
                          const Spacer(),
                          if (unread > 0)
                            TextButton(
                              onPressed: () => onReadAll(),
                              child: Text(
                                '全部已读',
                                style: TextStyle(
                                  fontSize: AppTypography.xs,
                                  color: palette.mutedForeground,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: palette.muted),
                    Expanded(
                      child: loading && items.isEmpty
                          ? Center(
                              child: Text(
                                '加载中…',
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  color: palette.mutedForeground,
                                ),
                              ),
                            )
                          : items.isEmpty
                              ? Center(
                                  child: Text(
                                    '暂无通知',
                                    style: TextStyle(
                                      fontSize: AppTypography.sm,
                                      color: palette.mutedForeground,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.x1,
                                  ),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) => Divider(
                                    height: 1,
                                    color: palette.muted,
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return _NotificationTile(
                                      item: item,
                                      onTap: () => onItemTap(item),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    await _refreshUnread();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = _unread > 0 ? '通知，$_unread 条未读' : '通知';
    final badgeText = _unread > 99 ? '99+' : '$_unread';

    return IconButton(
      tooltip: label,
      onPressed: _openSheet,
      icon: Badge(
        isLabelVisible: _unread > 0,
        backgroundColor: palette.danger,
        textColor: palette.brandOn,
        label: Text(
          badgeText,
          style: const TextStyle(fontSize: 10, height: 1),
        ),
        child: Icon(
          Icons.notifications_none_rounded,
          color: palette.foreground,
          size: 24,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2_5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.read ? Colors.transparent : palette.brand,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: palette.foreground,
                            fontWeight:
                                item.read ? FontWeight.w400 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.isBroadcast) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: palette.secondary,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '广播',
                            style: TextStyle(
                              fontSize: 10,
                              color: palette.secondaryForeground,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.content != null && item.content!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.content!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        color: palette.mutedForeground,
                      ),
                    ),
                  ],
                  if (item.createdAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(item.createdAt!),
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.mutedForeground.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$m/$d $h:$min';
  }
}
