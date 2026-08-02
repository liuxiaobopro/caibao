import 'package:caibao/app/models/storage_config.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class StorageConfigsPage extends NyStatefulWidget {
  static RouteView path = ('/storage-configs', (_) => StorageConfigsPage());

  StorageConfigsPage({super.key})
      : super(child: () => _StorageConfigsPageState());
}

class _StorageConfigsPageState extends NyPage<StorageConfigsPage> {
  List<S3StorageConfig> _items = [];
  bool _loading = true;

  @override
  get init => () async {
        await _refresh();
      };

  @override
  bool get stateManaged => false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final items = await api<ApiService>((r) => r.listStorageConfigs());
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

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      editing == null ? '新建存储配置' : '编辑存储配置',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                              try {
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
                                if (editing == null) {
                                  await api<ApiService>(
                                    (r) => r.createStorageConfig(body),
                                  );
                                } else {
                                  await api<ApiService>(
                                    (r) => r.updateStorageConfig(
                                      editing.id!,
                                      body,
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
                                setSheet(() => submitting = false);
                              }
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

  Future<void> _enable(S3StorageConfig item) async {
    if (item.id == null) return;
    try {
      await api<ApiService>((r) => r.enableStorageConfig(item.id!));
      await _refresh();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
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
    if (ok != true || item.id == null) return;
    try {
      await api<ApiService>((r) => r.deleteStorageConfig(item.id!));
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
        title: const Text('S3 存储设置'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(onPressed: () => _openForm(), child: const Text('新建')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    '暂无存储配置',
                    style: TextStyle(color: palette.mutedForeground),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.x3),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Material(
                        color: const Color(0xFFF8F8F8),
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
                              const SizedBox(height: 6),
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
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!item.enabled)
                                    TextButton(
                                      onPressed: () => _enable(item),
                                      child: const Text('启用'),
                                    ),
                                  TextButton(
                                    onPressed: () async {
                                      final full = await api<ApiService>(
                                        (r) => r.getStorageConfig(item.id!),
                                      );
                                      await _openForm(editing: full);
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
