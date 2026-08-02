import 'package:caibao/app/utils/message_segments.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:caibao/resources/widgets/chat/thinking_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AssistantMessageBody extends StatelessWidget {
  const AssistantMessageBody({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final segments = parseMessageSegments(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final segment in segments)
          if (segment is ThinkingSegment)
            ThinkingBlock(
              text: segment.text,
              streaming: segment.streaming,
            )
          else if (segment is TextSegment && segment.text.trim().isNotEmpty)
            MarkdownBody(
              data: segment.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                p: TextStyle(
                  fontSize: AppTypography.base,
                  color: palette.foreground,
                  height: 1.5,
                ),
                strong: TextStyle(
                  fontSize: AppTypography.base,
                  color: palette.foreground,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
                listBullet: TextStyle(
                  fontSize: AppTypography.base,
                  color: palette.foreground,
                ),
              ),
            ),
        if (segments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x1),
            child: Text(
              content,
              style: TextStyle(
                fontSize: AppTypography.base,
                color: palette.foreground,
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}
