import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/app/models/chat_sse_event.dart';
import 'package:caibao/app/models/drive_file.dart';

class ChatStreamHandler {
  ChatStreamHandler._();

  static List<ChatMessage> appendPendingExchange({
    required List<ChatMessage> messages,
    required String userContent,
    List<DriveFile>? attachments,
  }) {
    return [
      ...messages,
      ChatMessage(
        role: ChatMessageRole.user,
        content: userContent,
        createdAt: DateTime.now(),
        attachments: attachments ?? [],
      ),
      ChatMessage(
        role: ChatMessageRole.assistant,
        content: '',
        createdAt: DateTime.now(),
        status: 'streaming',
      ),
    ];
  }

  /// Returns updated messages, or null when the event should not mutate the list.
  static List<ChatMessage>? applyEvent({
    required List<ChatMessage> messages,
    required ChatSSEEvent event,
  }) {
    if (event.type == 'delta' && event.content != null) {
      if (messages.isEmpty) return null;
      final last = messages.last;
      if (last.role != ChatMessageRole.assistant) return null;
      final updated = List<ChatMessage>.from(messages);
      updated[updated.length - 1] = ChatMessage(
        id: event.messageId ?? last.id,
        role: ChatMessageRole.assistant,
        content: '${last.content ?? ''}${event.content}',
        createdAt: last.createdAt,
        status: 'streaming',
        attachments: last.attachments,
      );
      return updated;
    }

    if (event.type == 'done') {
      if (messages.isEmpty) return null;
      final last = messages.last;
      if (last.role != ChatMessageRole.assistant) return null;
      final updated = List<ChatMessage>.from(messages);
      updated[updated.length - 1] = ChatMessage(
        id: event.messageId ?? last.id,
        role: ChatMessageRole.assistant,
        content: event.content ?? last.content,
        createdAt: last.createdAt,
        status: 'done',
        attachments: last.attachments,
      );
      return updated;
    }

    return null;
  }

  static bool isError(ChatSSEEvent event) => event.type == 'error';
}
