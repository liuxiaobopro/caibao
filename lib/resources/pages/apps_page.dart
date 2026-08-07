import 'package:caibao/app/controllers/apps_controller.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AppsPage extends NyStatefulWidget<AppsController> {
  static RouteView path = ('/apps', (_) => AppsPage());

  AppsPage({super.key}) : super(child: () => _AppsPageState());
}

class _AppsPageState extends NyPage<AppsPage> {
  AppsController get controller => widget.controller;

  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final apps = controller.apps;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('应用'),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: apps.isEmpty
          ? Center(
              child: Text(
                '暂无应用',
                style: TextStyle(color: palette.mutedForeground),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.x4),
              itemCount: apps.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.x3),
              itemBuilder: (context, index) {
                final app = apps[index];
                return Material(
                  color: palette.secondary,
                  borderRadius: AppRadius.x2lAll,
                  child: InkWell(
                    borderRadius: AppRadius.x2lAll,
                    onTap: () => controller.openApp(app),
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
                                const SizedBox(height: AppSpacing.x1),
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
