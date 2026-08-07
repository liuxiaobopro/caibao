import 'package:caibao/app/controllers/drive_controller.dart';
import 'package:caibao/app/models/drive_file.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/utils/drive_file_helpers.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DrivePage extends NyStatefulWidget<DriveController> {
  static RouteView path = ('/drive', (_) => DrivePage());

  DrivePage({super.key}) : super(child: () => _DrivePageState());
}

class _DrivePageState extends NyPage<DrivePage> {
  DriveController get controller => widget.controller;

  @override
  get init => () async {
        await controller.refresh();
      };

  @override
  bool get stateManaged => false;

  Future<void> _openFile(DriveFile file) async {
    if (file.id == null) return;
    try {
      final url = await controller.resolveFileUrl(file);
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

      await controller.openExternal(url);
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
    if (ok != true) return;
    await controller.deleteFile(file);
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final c = controller;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('云盘'),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: c.loading
          ? const Center(child: CircularProgressIndicator())
          : c.items.isEmpty
              ? Center(
                  child: Text(
                    '暂无文件',
                    style: TextStyle(color: palette.mutedForeground),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: c.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    itemCount: c.items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.x2),
                    itemBuilder: (context, index) {
                      final file = c.items[index];
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
                                Icon(c.iconFor(file),
                                    color: palette.foreground),
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
                                      const SizedBox(height: AppSpacing.x1),
                                      Text(
                                        '${formatDriveFileSize(file.size)} · ${formatDriveFileTime(file.createdAt)}'
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
