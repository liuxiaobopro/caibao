import 'package:caibao/app/utils/message_segments.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/agent_chat_page.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class MessageCardView extends StatelessWidget {
  const MessageCardView({super.key, required this.card});

  final MessageCard card;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (card is AgentCreatedCard) {
      final agent = card as AgentCreatedCard;
      final name = agent.name.trim();
      final initial = name.isNotEmpty ? name.substring(0, 1) : '智';

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.x3),
        child: Material(
          color: palette.card.withValues(alpha: 0.7),
          borderRadius: AppRadius.xlAll,
          child: InkWell(
            borderRadius: AppRadius.xlAll,
            onTap: () {
              routeTo(
                AgentChatPage.path,
                data: {'id': agent.id, 'name': agent.name},
              );
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 448),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3_5,
                vertical: AppSpacing.x3,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.xlAll,
                border: Border.all(
                  color: palette.muted.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.brand.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        fontWeight: FontWeight.w500,
                        color: palette.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            fontWeight: FontWeight.w500,
                            color: palette.foreground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x0_5),
                        Text(
                          '${agent.message ?? '智能体创建成功'} · 点击开始对话',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.xs,
                            color: palette.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: palette.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3_5,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: palette.card.withValues(alpha: 0.7),
          borderRadius: AppRadius.xlAll,
          border: Border.all(color: palette.muted.withValues(alpha: 0.7)),
        ),
        child: Text(
          '未知卡片：${card.type}',
          style: TextStyle(
            fontSize: AppTypography.sm,
            color: palette.mutedForeground,
          ),
        ),
      ),
    );
  }
}
