import 'package:nylo_framework/nylo_framework.dart';

class ChatConversation extends Model {
  static StorageKey key = 'chat_conversation';

  String? id;
  String? title;
  DateTime? updatedAt;
  bool unread;

  ChatConversation({
    this.id,
    this.title,
    this.updatedAt,
    this.unread = false,
  }) : super(key: key);

  ChatConversation.fromJson(dynamic data)
      : id = data['id'],
        title = data['title'],
        updatedAt = data['updatedAt'] != null
            ? DateTime.tryParse(data['updatedAt'].toString())
            : null,
        unread = data['unread'] == true,
        super(key: key);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'updatedAt': updatedAt?.toIso8601String(),
      'unread': unread,
    };
  }
}
