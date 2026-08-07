import 'package:caibao/app/controllers/llm_models_controller.dart';
import 'package:caibao/app/models/llm_model.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LlmModelsPage extends NyStatefulWidget<LlmModelsController> {
  static RouteView path = ('/llm-models', (_) => LlmModelsPage());

  LlmModelsPage({super.key}) : super(child: () => _LlmModelsPageState());
}

class _LlmModelsPageState extends NyPage<LlmModelsPage> {
  LlmModelsController get controller => widget.controller;

  @override
  get init => () async {
        await controller.refresh();
      };

  @override
  bool get stateManaged => false;

  Future<void> _openForm({LlmModel? editing}) async {
    final name = TextEditingController(text: editing?.name ?? '');
    final model = TextEditingController(text: editing?.model ?? '');
    final baseUrl = TextEditingController(text: editing?.baseUrl ?? '');
    final apiKey = TextEditingController();
    var category = editing?.category ?? LlmModelCategory.multimodal;
    var submitting = false;
    final palette = context.palette;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.x2l)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.x4,
                AppSpacing.x4,
                AppSpacing.x4,
                AppSpacing.x4 + bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      editing == null ? '新建模型' : '编辑模型',
                      style: const TextStyle(
                        fontSize: AppTypography.lg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: '名称'),
                    ),
                    TextField(
                      controller: model,
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),
                    TextField(
                      controller: baseUrl,
                      decoration: const InputDecoration(labelText: 'Base URL'),
                    ),
                    TextField(
                      controller: apiKey,
                      decoration: InputDecoration(
                        labelText:
                            editing == null ? 'API Key' : 'API Key（留空不改）',
                      ),
                      obscureText: true,
                    ),
                    DropdownButtonFormField<LlmModelCategory>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: '分类'),
                      items: LlmModelsController.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setSheet(() => category = v);
                      },
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    FilledButton(
                      onPressed: submitting
                          ? null
                          : () async {
                              if (model.text.trim().isEmpty ||
                                  baseUrl.text.trim().isEmpty ||
                                  (editing == null &&
                                      apiKey.text.trim().isEmpty)) {
                                showToastSorry(description: '请填写必填项');
                                return;
                              }
                              setSheet(() => submitting = true);
                              final body = <String, dynamic>{
                                'name': name.text.trim(),
                                'model': model.text.trim(),
                                'base_url': baseUrl.text.trim(),
                                'category': category.value,
                              };
                              if (apiKey.text.trim().isNotEmpty) {
                                body['api_key'] = apiKey.text.trim();
                              }
                              final ok = await controller.saveModel(
                                editing: editing,
                                body: body,
                              );
                              if (ok && ctx.mounted) Navigator.pop(ctx);
                              setSheet(() => submitting = false);
                            },
                      child: Text(submitting ? '提交中…' : '保存'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    name.dispose();
    model.dispose();
    baseUrl.dispose();
    apiKey.dispose();
  }

  Future<void> _delete(LlmModel item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除模型'),
        content: Text('确定删除「${item.name ?? item.model}」吗？'),
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
    await controller.deleteModel(item);
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final c = controller;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('模型配置'),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(onPressed: () => _openForm(), child: const Text('新建')),
        ],
      ),
      body: c.loading
          ? const Center(child: CircularProgressIndicator())
          : c.items.isEmpty
              ? Center(
                  child: Text(
                    '暂无模型',
                    style: TextStyle(color: palette.mutedForeground),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: c.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    itemCount: c.items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.x3),
                    itemBuilder: (context, index) {
                      final item = c.items[index];
                      return Material(
                        color: palette.secondary,
                        borderRadius: AppRadius.x2lAll,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.x4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name?.isNotEmpty == true
                                          ? item.name!
                                          : (item.model ?? '未命名'),
                                      style: TextStyle(
                                        fontSize: AppTypography.base,
                                        fontWeight: FontWeight.w600,
                                        color: palette.foreground,
                                      ),
                                    ),
                                  ),
                                  if (item.enabled)
                                    Text(
                                      '已启用',
                                      style: TextStyle(
                                        fontSize: AppTypography.xs,
                                        color: palette.brand,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.x1_5),
                              Text(
                                '${item.model ?? ''} · ${item.category?.label ?? ''}',
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  color: palette.mutedForeground,
                                ),
                              ),
                              Text(
                                item.baseUrl ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  color: palette.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!item.enabled)
                                    TextButton(
                                      onPressed: () => c.enable(item),
                                      child: const Text('启用'),
                                    ),
                                  TextButton(
                                    onPressed: () async {
                                      final full =
                                          await c.fetchModel(item.id!);
                                      if (full != null) {
                                        await _openForm(editing: full);
                                      }
                                    },
                                    child: const Text('编辑'),
                                  ),
                                  TextButton(
                                    onPressed: () => _delete(item),
                                    child: Text(
                                      '删除',
                                      style:
                                          TextStyle(color: palette.danger),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
