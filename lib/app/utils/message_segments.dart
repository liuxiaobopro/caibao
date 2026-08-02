const String thinkOpen = '<think>';
const String thinkClose = '</think>';

sealed class MessageSegment {
  const MessageSegment();
}

class TextSegment extends MessageSegment {
  const TextSegment(this.text);
  final String text;
}

class ThinkingSegment extends MessageSegment {
  const ThinkingSegment(this.text, {this.streaming = false});
  final String text;
  final bool streaming;
}

final RegExp _thinkBlockRe = RegExp(
  '$thinkOpen([\\s\\S]*?)$thinkClose',
  caseSensitive: false,
);

List<MessageSegment> parseMessageSegments(String content) {
  if (content.isEmpty) return const [];

  final segments = <MessageSegment>[];
  var cursor = 0;

  for (final match in _thinkBlockRe.allMatches(content)) {
    if (match.start > cursor) {
      final text = content.substring(cursor, match.start);
      if (text.trim().isNotEmpty) {
        segments.add(TextSegment(text));
      }
    }
    segments.add(ThinkingSegment(match.group(1) ?? ''));
    cursor = match.end;
  }

  final rest = content.substring(cursor);
  final lower = rest.toLowerCase();
  final openIdx = lower.indexOf(thinkOpen);
  if (openIdx >= 0) {
    if (openIdx > 0) {
      final text = rest.substring(0, openIdx);
      if (text.trim().isNotEmpty) {
        segments.add(TextSegment(text));
      }
    }
    segments.add(
      ThinkingSegment(
        rest.substring(openIdx + thinkOpen.length),
        streaming: true,
      ),
    );
  } else if (rest.trim().isNotEmpty || segments.isEmpty) {
    segments.add(TextSegment(rest.isEmpty ? content : rest));
  }

  return segments;
}
