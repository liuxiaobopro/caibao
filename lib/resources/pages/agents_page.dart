import 'package:caibao/app/controllers/agents_controller.dart';
import 'package:caibao/app/models/agent.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/agent_chat_page.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AgentsPage extends NyStatefulWidget<AgentsController> {
  static RouteView path = ('/agents', (_) => AgentsPage());

  AgentsPage({super.key}) : super(child: () => _AgentsPageState());
}

class _AgentsPageState extends NyPage<AgentsPage> {
  AgentsController get controller => widget.controller;

  @override
  get init => () async {
        await controller.refresh();
      };

  @override
  bool get stateManaged => false;

  Future<void> _openForm({Agent? editing}) async {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final descCtrl = TextEditingController(text: editing?.description ?? '');
    final instrCtrl = TextEditingController(text: editing?.instruction ?? '');
    var submitting = false;
    final palette = context.palette;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    editing == null ? '新建智能体' : '编辑智能体',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: '名称'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: '描述'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: instrCtrl,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(labelText: '指令'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: submitting
                        ? null
                        : () async {
                            setSheetState(() => submitting = true);
                            final ok = await controller.saveAgent(
                              editing: editing,
                              name: nameCtrl.text,
                              instruction: instrCtrl.text,
                              description: descCtrl.text,
                            );
                            if (ok && ctx.mounted) Navigator.pop(ctx);
                            setSheetState(() => submitting = false);
                          },
                    child: Text(submitting ? '提交中…' : '保存'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    descCtrl.dispose();
    instrCtrl.dispose();
  }

  Future<void> _delete(Agent agent) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除智能体'),
        content: Text('确定删除「${agent.name}」吗？相关上下文也会一并清除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await controller.deleteAgent(agent);
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final c = controller;
    final filtered = c.filtered;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('发现智能体'),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (c.tab == 'user')
            TextButton(
              onPressed: () => _openForm(),
              child: const Text('新建'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'system', label: Text('系统')),
                ButtonSegment(value: 'user', label: Text('用户')),
              ],
              selected: {c.tab},
              onSelectionChanged: (v) => c.setTab(v.first),
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          Expanded(
            child: c.loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          c.tab == 'system' ? '暂无系统智能体' : '暂无用户智能体',
                          style: TextStyle(color: palette.mutedForeground),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: c.refresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.x4),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.x3),
                          itemBuilder: (context, index) {
                            final agent = filtered[index];
                            return Material(
                              color: palette.secondary,
                              borderRadius: AppRadius.x2lAll,
                              child: InkWell(
                                borderRadius: AppRadius.x2lAll,
                                onTap: () {
                                  if (agent.id == null) return;
                                  routeTo(
                                    AgentChatPage.path,
                                    data: {'id': agent.id, 'name': agent.name},
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.x4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              agent.name ?? '',
                                              style: TextStyle(
                                                fontSize: AppTypography.base,
                                                fontWeight: FontWeight.w600,
                                                color: palette.foreground,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: palette.muted,
                                              borderRadius: AppRadius.fullAll,
                                            ),
                                            child: Text(
                                              agent.isSystem ? '系统' : '用户',
                                              style: TextStyle(
                                                fontSize: AppTypography.xs,
                                                color: palette.mutedForeground,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        (agent.description?.isNotEmpty == true)
                                            ? agent.description!
                                            : '暂无描述',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: AppTypography.sm,
                                          color: palette.mutedForeground,
                                        ),
                                      ),
                                      if (agent.isUser) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                final full = await controller
                                                    .fetchAgent(agent.id!);
                                                if (full != null) {
                                                  await _openForm(
                                                    editing: full,
                                                  );
                                                }
                                              },
                                              child: const Text('编辑'),
                                            ),
                                            TextButton(
                                              onPressed: () => _delete(agent),
                                              child: Text(
                                                '删除',
                                                style: TextStyle(
                                                  color: palette.danger,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
