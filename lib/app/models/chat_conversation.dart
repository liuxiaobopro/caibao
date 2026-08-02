import 'package:nylo_framework/nylo_framework.dart';

class ChatConversation extends Model {
  static StorageKey key = 'chat_conversation';

  String? id;
  String? title;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? lastMessageAt;
  int messageCount;
  bool unread;

  ChatConversation({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.lastMessageAt,
    this.messageCount = 0,
    this.unread = false,
  }) : super(key: key);

  ChatConversation.fromJson(dynamic data)
      : id = data['id']?.toString(),
        title = data['title']?.toString(),
        createdAt = _parseDate(data['created_at']),
        updatedAt = _parseDate(data['updated_at']),
        lastMessageAt = _parseDate(data['last_message_at']),
        messageCount = data['message_count'] is int
            ? data['message_count'] as int
            : int.tryParse('${data['message_count'] ?? 0}') ?? 0,
        unread = data['unread'] == true,
        super(key: key);

  DateTime? get sortAt => lastMessageAt ?? updatedAt ?? createdAt;

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'message_count': messageCount,
      'unread': unread,
    };
  }
}
