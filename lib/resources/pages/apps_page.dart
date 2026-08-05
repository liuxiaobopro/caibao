import 'package:caibao/app/apps/registry.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/app_detail_page.dart';
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
  @override
  bool get stateManaged => false;

  void _openApp(AppMeta app) {
    routeTo(
      AppDetailPage.path,
      data: {
        'slug': app.slug,
        'name': app.name,
        'description': app.description,
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
      body: appList.isEmpty
          ? Center(
              child: Text(
                '暂无应用',
                style: TextStyle(color: palette.mutedForeground),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.x4),
              itemCount: appList.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.x3),
              itemBuilder: (context, index) {
                final app = appList[index];
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
                              child: ColoredBox(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.name,
                                  style: TextStyle(
                                    fontSize: AppTypography.base,
                                    fontWeight: FontWeight.w600,
                                    color: palette.foreground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  app.description,
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
    );
  }
}
