import 'package:caibao/app/models/agent.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/agent_chat_page.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AgentsPage extends NyStatefulWidget {
  static RouteView path = ('/agents', (_) => AgentsPage());

  AgentsPage({super.key}) : super(child: () => _AgentsPageState());
}

class _AgentsPageState extends NyPage<AgentsPage> {
  List<Agent> _items = [];
  bool _loading = true;
  String _tab = 'system';

  @override
  get init => () async {
        await _refresh();
      };

  @override
  bool get stateManaged => false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final items = await api<ApiService>((r) => r.listAgents());
      if (!mounted) return;
      setState(() => _items = items ?? []);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Agent> get _filtered =>
      _items.where((a) => a.scope == _tab).toList();

  Future<void> _openForm({Agent? editing}) async {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final descCtrl = TextEditingController(text: editing?.description ?? '');
    final instrCtrl = TextEditingController(text: editing?.instruction ?? '');
    var submitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                            final name = nameCtrl.text.trim();
                            final instruction = instrCtrl.text.trim();
                            if (name.isEmpty || instruction.isEmpty) {
                              showToastSorry(description: '请填写名称和指令');
                              return;
                            }
                            setSheetState(() => submitting = true);
                            try {
                              if (editing == null) {
                                await api<ApiService>(
                                  (r) => r.createAgent(
                                    name: name,
                                    instruction: instruction,
                                    description: descCtrl.text.trim(),
                                  ),
                                );
                              } else {
                                await api<ApiService>(
                                  (r) => r.updateAgent(
                                    editing.id!,
                                    name: name,
                                    instruction: instruction,
                                    description: descCtrl.text.trim(),
                                  ),
                                );
                              }
                              if (ctx.mounted) Navigator.pop(ctx);
                              await _refresh();
                            } on ApiException catch (e) {
                              showToastSorry(description: e.message);
                            } catch (e) {
                              showToastSorry(description: e.toString());
                            } finally {
                              setSheetState(() => submitting = false);
                            }
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
    if (ok != true || agent.id == null) return;
    try {
      await api<ApiService>((r) => r.deleteAgent(agent.id!));
      await _refresh();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('发现智能体'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_tab == 'user')
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
              selected: {_tab},
              onSelectionChanged: (v) => setState(() => _tab = v.first),
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          _tab == 'system' ? '暂无系统智能体' : '暂无用户智能体',
                          style: TextStyle(color: palette.mutedForeground),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.x4),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.x3),
                          itemBuilder: (context, index) {
                            final agent = _filtered[index];
                            return Material(
                              color: const Color(0xFFF8F8F8),
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
                                                try {
                                                  final full =
                                                      await api<ApiService>(
                                                    (r) =>
                                                        r.getAgent(agent.id!),
                                                  );
                                                  await _openForm(
                                                    editing: full,
                                                  );
                                                } on ApiException catch (e) {
                                                  showToastSorry(
                                                    description: e.message,
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
