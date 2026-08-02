import 'package:caibao/app/models/mini_app.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/app_detail_page.dart';
import 'package:caibao/resources/pages/todos_app_page.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AppsPage extends NyStatefulWidget {
  static RouteView path = ('/apps', (_) => AppsPage());

  AppsPage({super.key}) : super(child: () => _AppsPageState());
}

class _AppsPageState extends NyPage<AppsPage> {
  List<MiniApp> _items = [];
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
      final items = await api<ApiService>((r) => r.listApps());
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

  void _openApp(MiniApp app) {
    final slug = app.slug ?? '';
    if (slug == 'todos') {
      routeTo(TodosAppPage.path, data: {'slug': slug, 'name': app.name});
      return;
    }
    routeTo(
      AppDetailPage.path,
      data: {
        'slug': slug,
        'name': app.name,
        'description': app.description,
        'icon_url': app.iconUrl,
      },
    );
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('应用'),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    '暂无应用',
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
                      final app = _items[index];
                      return Material(
                        color: palette.secondary,
                        borderRadius: AppRadius.x2lAll,
                        child: InkWell(
                          borderRadius: AppRadius.x2lAll,
                          onTap: () => _openApp(app),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.x4),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: AppRadius.lgAll,
                                  child: SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: app.iconUrl?.isNotEmpty == true
                                        ? Image.network(
                                            app.iconUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                ColoredBox(
                                              color: palette.muted,
                                              child: Icon(
                                                Icons.apps_outlined,
                                                color: palette.mutedForeground,
                                              ),
                                            ),
                                          )
                                        : ColoredBox(
                                            color: palette.muted,
                                            child: Icon(
                                              Icons.apps_outlined,
                                              color: palette.mutedForeground,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.x3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.name ?? '',
                                        style: TextStyle(
                                          fontSize: AppTypography.base,
                                          fontWeight: FontWeight.w600,
                                          color: palette.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (app.description?.isNotEmpty == true)
                                            ? app.description!
                                            : '暂无描述',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: AppTypography.sm,
                                          color: palette.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: palette.mutedForeground,
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
