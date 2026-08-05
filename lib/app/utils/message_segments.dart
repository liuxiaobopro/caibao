import 'dart:convert';

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

class CardSegment extends MessageSegment {
  const CardSegment(this.card);
  final MessageCard card;
}

sealed class MessageCard {
  const MessageCard({required this.type});
  final String type;
}

class AgentCreatedCard extends MessageCard {
  const AgentCreatedCard({
    required this.id,
    required this.name,
    this.message,
  }) : super(type: 'agent_created');

  final String id;
  final String name;
  final String? message;
}

class UnknownMessageCard extends MessageCard {
  const UnknownMessageCard({required super.type});
}

final RegExp _thinkBlockRe = RegExp(
  '$thinkOpen([\\s\\S]*?)$thinkClose',
  caseSensitive: false,
);

final RegExp _cardFenceRe = RegExp(
  r'```caibao\.card\s*\n([\s\S]*?)\n```',
);

MessageCard? tryParseCard(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final obj = Map<String, dynamic>.from(decoded);

    var type = obj['type'] is String ? obj['type'] as String : '';
    if (type.isEmpty && _isLegacyAgentCreated(obj)) {
      type = 'agent_created';
    }
    if (type.isEmpty) return null;

    if (type == 'agent_created') {
      final id = obj['id'] is String ? obj['id'] as String : '';
      final name = obj['name'] is String ? obj['name'] as String : '';
      if (id.isEmpty || name.isEmpty) return null;
      return AgentCreatedCard(
        id: id,
        name: name,
        message: obj['message'] is String ? obj['message'] as String : null,
      );
    }

    return UnknownMessageCard(type: type);
  } catch (_) {
    return null;
  }
}

bool _isLegacyAgentCreated(Map<String, dynamic> obj) {
  return obj['id'] is String &&
      obj['name'] is String &&
      obj['message'] is String &&
      (obj['message'] as String).contains('智能体');
}

String stripThinking(String content) {
  if (content.isEmpty) return '';
  var out = content.replaceAll(_thinkBlockRe, '');
  final openIdx = out.toLowerCase().indexOf(thinkOpen);
  if (openIdx >= 0) {
    out = out.substring(0, openIdx);
  }
  return out.trim();
}

sealed class _RawPart {
  const _RawPart();
}

class _RawText extends _RawPart {
  const _RawText(this.text);
  final String text;
}

class _RawThinking extends _RawPart {
  const _RawThinking(this.text, {this.streaming = false});
  final String text;
  final bool streaming;
}

List<_RawPart> _splitThinkingParts(String content) {
  final parts = <_RawPart>[];
  var cursor = 0;

  for (final match in _thinkBlockRe.allMatches(content)) {
    if (match.start > cursor) {
      parts.add(_RawText(content.substring(cursor, match.start)));
    }
    parts.add(_RawThinking(match.group(1) ?? ''));
    cursor = match.end;
  }

  final rest = content.substring(cursor);
  final lower = rest.toLowerCase();
  final openIdx = lower.indexOf(thinkOpen);
  if (openIdx >= 0) {
    if (openIdx > 0) {
      parts.add(_RawText(rest.substring(0, openIdx)));
    }
    parts.add(
      _RawThinking(
        rest.substring(openIdx + thinkOpen.length),
        streaming: true,
      ),
    );
  } else if (rest.isNotEmpty) {
    parts.add(_RawText(rest));
  }

  return parts;
}

List<MessageSegment> _parseCardSegments(String content) {
  if (content.isEmpty) return const [];

  final segments = <MessageSegment>[];
  var cursor = 0;
  var matched = false;

  for (final match in _cardFenceRe.allMatches(content)) {
    matched = true;
    if (match.start > cursor) {
      final text = content.substring(cursor, match.start);
      if (text.trim().isNotEmpty) {
        segments.add(TextSegment(text));
      }
    }
    final card = tryParseCard((match.group(1) ?? '').trim());
    if (card != null) {
      segments.add(CardSegment(card));
    } else if (match.group(0) != null) {
      segments.add(TextSegment(match.group(0)!));
    }
    cursor = match.end;
  }

  final rest = content.substring(cursor);
  if (!matched) {
    final legacy = _tryExtractLeadingLegacyCard(content);
    if (legacy != null) {
      return [
        CardSegment(legacy.card),
        if (legacy.rest.trim().isNotEmpty) TextSegment(legacy.rest),
      ];
    }
  }

  if (rest.trim().isNotEmpty || segments.isEmpty) {
    if (rest.isNotEmpty || segments.isEmpty) {
      segments.add(TextSegment(rest.isEmpty ? content : rest));
    }
  }

  return segments;
}

({MessageCard card, String rest})? _tryExtractLeadingLegacyCard(
  String content,
) {
  final trimmed = content.trimLeft();
  if (!trimmed.startsWith('{')) return null;

  var depth = 0;
  var end = -1;
  for (var i = 0; i < trimmed.length; i++) {
    final ch = trimmed[i];
    if (ch == '{') {
      depth++;
    } else if (ch == '}') {
      depth--;
      if (depth == 0) {
        end = i + 1;
        break;
      }
    }
  }
  if (end < 0) return null;

  final card = tryParseCard(trimmed.substring(0, end));
  if (card == null) return null;
  return (card: card, rest: trimmed.substring(end));
}

/// 解析消息内容为思考段 + 文本段 + 卡片段。
List<MessageSegment> parseMessageSegments(String content) {
  if (content.isEmpty) return const [];

  final parts = _splitThinkingParts(content);
  if (parts.isEmpty) {
    return _parseCardSegments(content);
  }

  final segments = <MessageSegment>[];
  for (final part in parts) {
    if (part is _RawThinking) {
      segments.add(
        ThinkingSegment(part.text, streaming: part.streaming),
      );
      continue;
    }
    if (part is _RawText) {
      segments.addAll(_parseCardSegments(part.text));
    }
  }
  return segments;
}
