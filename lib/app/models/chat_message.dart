import 'package:nylo_framework/nylo_framework.dart';

enum ChatMessageRole { user, assistant, system }

class ChatMessage extends Model {
  static StorageKey key = 'chat_message';

  String? id;
  ChatMessageRole role;
  String? content;
  DateTime? createdAt;
  String? status;
  int? seq;

  ChatMessage({
    this.id,
    this.role = ChatMessageRole.user,
    this.content,
    this.createdAt,
    this.status,
    this.seq,
  }) : super(key: key);

  ChatMessage.fromJson(dynamic data)
      : id = data['id']?.toString(),
        role = _parseRole(data['role']),
        content = data['content']?.toString(),
        createdAt = data['created_at'] != null
            ? DateTime.tryParse(data['created_at'].toString())
            : null,
        status = data['status']?.toString(),
        seq = data['seq'] is int
            ? data['seq'] as int
            : int.tryParse('${data['seq'] ?? ''}'),
        super(key: key);

  static ChatMessageRole _parseRole(dynamic value) {
    switch (value?.toString()) {
      case 'assistant':
        return ChatMessageRole.assistant;
      case 'system':
        return ChatMessageRole.system;
      default:
        return ChatMessageRole.user;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'created_at': createdAt?.toIso8601String(),
      'status': status,
      'seq': seq,
    };
  }
}
