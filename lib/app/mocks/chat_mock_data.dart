import 'package:caibao/app/models/chat_conversation.dart';

class MockChatUser {
  const MockChatUser({
    required this.nickname,
    required this.caibaoId,
  });

  final String nickname;
  final String caibaoId;
}

class ConversationGroup {
  const ConversationGroup({
    required this.label,
    required this.items,
  });

  final String label;
  final List<ChatConversation> items;
}

abstract final class ChatMockData {
  static const MockChatUser user = MockChatUser(
    nickname: '刘十三',
    caibaoId: 'user_qSuXRuYT7W',
  );

  static List<ConversationGroup> conversationGroups() {
    final now = DateTime.now();
    return [
      ConversationGroup(
        label: '今天',
        items: [
          ChatConversation(
            id: 'c1',
            title: '沈阳二手房过户流程指南',
            updatedAt: now,
          ),
        ],
      ),
      ConversationGroup(
        label: '最近一周',
        items: [
          ChatConversation(
            id: 'c2',
            title: '服务器出网流量携带APN字段的实现...',
            updatedAt: now.subtract(const Duration(days: 2)),
            unread: true,
          ),
          ChatConversation(
            id: 'c3',
            title: 'APN6数据标识和请求方式是否是ipv4还是i...',
            updatedAt: now.subtract(const Duration(days: 3)),
          ),
          ChatConversation(
            id: 'c4',
            title: '房产过户税费指南',
            updatedAt: now.subtract(const Duration(days: 5)),
          ),
        ],
      ),
      ConversationGroup(
        label: '更早',
        items: [
          ChatConversation(
            id: 'c5',
            title: '丰巢取件遗漏物品处理办法',
            updatedAt: now.subtract(const Duration(days: 10)),
          ),
          ChatConversation(
            id: 'c6',
            title: '沈阳二手房过户指南',
            updatedAt: now.subtract(const Duration(days: 12)),
          ),
          ChatConversation(
            id: 'c7',
            title: 'Golang实现APN6应用侧封装',
            updatedAt: now.subtract(const Duration(days: 15)),
          ),
          ChatConversation(
            id: 'c8',
            title: '奥美拉唑缓解胃部刺痛',
            updatedAt: now.subtract(const Duration(days: 20)),
          ),
        ],
      ),
    ];
  }
}
