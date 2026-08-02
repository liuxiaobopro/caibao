class ChatSSEEvent {
  const ChatSSEEvent({
    required this.type,
    this.content,
    this.messageId,
    this.msg,
  });

  final String type;
  final String? content;
  final String? messageId;
  final String? msg;

  factory ChatSSEEvent.fromJson(Map<String, dynamic> json) {
    return ChatSSEEvent(
      type: json['type']?.toString() ?? '',
      content: json['content']?.toString(),
      messageId: json['message_id']?.toString(),
      msg: json['msg']?.toString(),
    );
  }
}
