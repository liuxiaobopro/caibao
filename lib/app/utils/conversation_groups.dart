import 'package:caibao/app/models/chat_conversation.dart';

class ConversationGroup {
  const ConversationGroup({
    required this.label,
    required this.items,
  });

  final String label;
  final List<ChatConversation> items;
}

List<ConversationGroup> groupConversations(List<ChatConversation> items) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = todayStart.subtract(const Duration(days: 7));

  final today = <ChatConversation>[];
  final week = <ChatConversation>[];
  final earlier = <ChatConversation>[];

  final sorted = [...items]..sort((a, b) {
      final aAt = a.sortAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bAt = b.sortAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bAt.compareTo(aAt);
    });

  for (final item in sorted) {
    final at = item.sortAt;
    if (at == null) {
      earlier.add(item);
      continue;
    }
    if (!at.isBefore(todayStart)) {
      today.add(item);
    } else if (!at.isBefore(weekStart)) {
      week.add(item);
    } else {
      earlier.add(item);
    }
  }

  return [
    if (today.isNotEmpty) ConversationGroup(label: '今天', items: today),
    if (week.isNotEmpty) ConversationGroup(label: '最近一周', items: week),
    if (earlier.isNotEmpty) ConversationGroup(label: '更早', items: earlier),
  ];
}
