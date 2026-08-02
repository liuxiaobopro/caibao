import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ThinkingBlock extends StatefulWidget {
  const ThinkingBlock({
    super.key,
    required this.text,
    this.streaming = false,
  });

  final String text;
  final bool streaming;

  @override
  State<ThinkingBlock> createState() => _ThinkingBlockState();
}

class _ThinkingBlockState extends State<ThinkingBlock> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final expanded = widget.streaming || _open;
    final body = widget.text.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x3),
      decoration: BoxDecoration(
        color: palette.muted.withValues(alpha: 0.35),
        borderRadius: AppRadius.x2lAll,
        border: Border.all(color: palette.muted),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: widget.streaming
                ? null
                : () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3,
                vertical: AppSpacing.x2_5,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: palette.mutedForeground,
                  ),
                  const SizedBox(width: AppSpacing.x1_5),
                  Expanded(
                    child: Text(
                      '深度思考',
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        fontWeight: FontWeight.w600,
                        color: palette.mutedForeground,
                      ),
                    ),
                  ),
                  if (!widget.streaming)
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: palette.mutedForeground,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (expanded && body.isNotEmpty) ...[
            Divider(height: 1, color: palette.muted),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x3,
                AppSpacing.x2_5,
                AppSpacing.x3,
                AppSpacing.x3,
              ),
              child: MarkdownBody(
                data: body,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(
                  p: TextStyle(
                    fontSize: AppTypography.xs,
                    color: palette.mutedForeground,
                    height: 1.5,
                  ),
                  strong: TextStyle(
                    fontSize: AppTypography.xs,
                    color: palette.mutedForeground,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                  listBullet: TextStyle(
                    fontSize: AppTypography.xs,
                    color: palette.mutedForeground,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
