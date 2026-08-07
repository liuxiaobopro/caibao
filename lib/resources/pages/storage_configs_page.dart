import 'package:caibao/app/controllers/storage_configs_controller.dart';
import 'package:caibao/app/models/storage_config.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class StorageConfigsPage extends NyStatefulWidget<StorageConfigsController> {
  static RouteView path = ('/storage-configs', (_) => StorageConfigsPage());

  StorageConfigsPage({super.key})
      : super(child: () => _StorageConfigsPageState());
}

class _StorageConfigsPageState extends NyPage<StorageConfigsPage> {
  StorageConfigsController get controller => widget.controller;

  @override
  get init => () async {
        await controller.refresh();
      };

  @override
  bool get stateManaged => true;

  Future<void> _openForm({S3StorageConfig? editing}) async {
    final name = TextEditingController(text: editing?.name ?? '');
    final endpoint = TextEditingController(text: editing?.endpoint ?? '');
    final region = TextEditingController(text: editing?.region ?? '');
    final bucket = TextEditingController(text: editing?.bucket ?? '');
    final accessKey = TextEditingController(text: editing?.accessKeyId ?? '');
    final secretKey =
        TextEditingController(text: editing?.secretAccessKey ?? '');
    final domain = TextEditingController(text: editing?.domain ?? '');
    var forcePathStyle = editing?.forcePathStyle ?? true;
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
                      editing == null ? '新建存储配置' : '编辑存储配置',
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
                      controller: endpoint,
                      decoration: const InputDecoration(labelText: 'Endpoint'),
                    ),
                    TextField(
                      controller: region,
                      decoration: const InputDecoration(labelText: 'Region'),
                    ),
                    TextField(
                      controller: bucket,
                      decoration: const InputDecoration(labelText: 'Bucket'),
                    ),
                    TextField(
                      controller: accessKey,
                      decoration:
                          const InputDecoration(labelText: 'Access Key'),
                    ),
                    TextField(
                      controller: secretKey,
                      decoration:
                          const InputDecoration(labelText: 'Secret Key'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: domain,
                      decoration: const InputDecoration(labelText: 'Domain'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Force Path Style'),
                      value: forcePathStyle,
                      onChanged: (v) => setSheet(() => forcePathStyle = v),
                    ),
                    FilledButton(
                      onPressed: submitting
                          ? null
                          : () async {
                              if (endpoint.text.trim().isEmpty ||
                                  bucket.text.trim().isEmpty ||
                                  accessKey.text.trim().isEmpty ||
                                  (editing == null &&
                                      secretKey.text.trim().isEmpty)) {
                                showToastSorry(description: '请填写必填项');
                                return;
                              }
                              setSheet(() => submitting = true);
                              final body = <String, dynamic>{
                                'name': name.text.trim(),
                                'endpoint': endpoint.text.trim(),
                                'region': region.text.trim(),
                                'bucket': bucket.text.trim(),
                                'access_key_id': accessKey.text.trim(),
                                'domain': domain.text.trim(),
                                'force_path_style': forcePathStyle,
                              };
                              if (secretKey.text.trim().isNotEmpty) {
                                body['secret_access_key'] =
                                    secretKey.text.trim();
                              }
                              final ok = await controller.saveConfig(
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
    endpoint.dispose();
    region.dispose();
    bucket.dispose();
    accessKey.dispose();
    secretKey.dispose();
    domain.dispose();
  }

  Future<void> _delete(S3StorageConfig item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除配置'),
        content: Text('确定删除「${item.name}」吗？'),
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
    await controller.deleteConfig(item);
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final c = controller;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('S3 存储设置'),
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
                    '暂无存储配置',
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
                                          : (item.bucket ?? '未命名'),
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
                                item.endpoint ?? '',
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  color: palette.mutedForeground,
                                ),
                              ),
                              Text(
                                'bucket: ${item.bucket ?? ''}',
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
                                          await c.fetchConfig(item.id!);
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
