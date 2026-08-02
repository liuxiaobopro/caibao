import 'package:nylo_framework/nylo_framework.dart';

enum ChatMessageRole { user, assistant }

class ChatMessage extends Model {
  static StorageKey key = 'chat_message';

  String? id;
  ChatMessageRole role;
  String? content;
  DateTime? createdAt;

  ChatMessage({
    this.id,
    this.role = ChatMessageRole.user,
    this.content,
    this.createdAt,
  }) : super(key: key);

  ChatMessage.fromJson(dynamic data)
      : id = data['id'],
        role = data['role'] == 'assistant'
            ? ChatMessageRole.assistant
            : ChatMessageRole.user,
        content = data['content'],
        createdAt = data['createdAt'] != null
            ? DateTime.tryParse(data['createdAt'].toString())
            : null,
        super(key: key);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role == ChatMessageRole.assistant ? 'assistant' : 'user',
      'content': content,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
