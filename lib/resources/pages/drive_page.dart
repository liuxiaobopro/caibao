import 'package:caibao/app/models/drive_file.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';

class DrivePage extends NyStatefulWidget {
  static RouteView path = ('/drive', (_) => DrivePage());

  DrivePage({super.key}) : super(child: () => _DrivePageState());
}

class _DrivePageState extends NyPage<DrivePage> {
  List<DriveFile> _items = [];
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
      final items = await api<ApiService>((r) => r.listFiles());
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

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatTime(DateTime? at) {
    if (at == null) return '';
    final local = at.toLocal();
    return '${local.month}/${local.day} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _resolveUrl(String? url) {
    final raw = url?.trim() ?? '';
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('blob:')) {
      return raw;
    }
    return 'https://$raw';
  }

  Future<void> _openFile(DriveFile file) async {
    if (file.id == null) return;
    try {
      var url = _resolveUrl(file.url);
      if (url.isEmpty) {
        url = _resolveUrl(
          await api<ApiService>((r) => r.getFileURL(file.id!)),
        );
      }
      if (url.isEmpty) {
        throw ApiException('文件地址无效');
      }

      if (file.isImage && mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(ctx).width * 0.9,
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.8,
              ),
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(child: Text('加载失败')),
                  ),
                ),
              ),
            ),
          ),
        );
        return;
      }

      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        showToastSorry(description: '无法打开文件');
      }
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> _delete(DriveFile file) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除文件'),
        content: Text('确定删除「${file.name}」吗？'),
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
    if (ok != true || file.id == null) return;
    try {
      await api<ApiService>((r) => r.deleteFile(file.id!));
      await _refresh();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  IconData _iconFor(DriveFile file) {
    if (file.isImage) return Icons.image_outlined;
    final name = file.name ?? '';
    if (RegExp(r'\.(xlsx?|csv)$', caseSensitive: false).hasMatch(name)) {
      return Icons.table_chart_outlined;
    }
    if (RegExp(r'\.(pdf|docx?|txt|md)$', caseSensitive: false).hasMatch(name)) {
      return Icons.description_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('云盘'),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    '暂无文件',
                    style: TextStyle(color: palette.mutedForeground),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.x2),
                    itemBuilder: (context, index) {
                      final file = _items[index];
                      return Material(
                        color: palette.secondary,
                        borderRadius: AppRadius.x2lAll,
                        child: InkWell(
                          borderRadius: AppRadius.x2lAll,
                          onTap: () => _openFile(file),
                          onLongPress: () => _delete(file),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.x3),
                            child: Row(
                              children: [
                                Icon(_iconFor(file), color: palette.foreground),
                                const SizedBox(width: AppSpacing.x3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.name ?? '未命名',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: AppTypography.base,
                                          fontWeight: FontWeight.w500,
                                          color: palette.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatSize(file.size)} · ${_formatTime(file.createdAt)}'
                                        '${file.source != null ? ' · ${file.source}' : ''}',
                                        style: TextStyle(
                                          fontSize: AppTypography.xs,
                                          color: palette.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'delete') _delete(file);
                                    if (v == 'open') _openFile(file);
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'open',
                                      child: Text('打开'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('删除'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
