import 'package:caibao/app/apps/registry.dart';
import 'package:caibao/app/controllers/app_detail_controller.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:caibao/resources/themes/tokens/caibao_palette.dart';
import 'package:caibao_todo_app/caibao_todo_app.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AppDetailPage extends NyStatefulWidget<AppDetailController> {
  static RouteView path = ('/apps/detail', (_) => AppDetailPage());

  AppDetailPage({super.key}) : super(child: () => _AppDetailPageState());
}

class _AppDetailPageState extends NyPage<AppDetailPage> {
  AppDetailController get controller => widget.controller;

  @override
  get init => () async {
        controller.bootstrap(data());
      };

  @override
  bool get stateManaged => true;

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final builder = controller.componentBuilder;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(controller.name.isEmpty ? '应用' : controller.name),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (controller.slug == AppSlug.todos)
            IconButton(
              tooltip: '新建分组',
              onPressed: () => TodoAppBarActions.createGroup?.call(),
              icon: Icon(
                Icons.create_new_folder_outlined,
                color: palette.foreground,
              ),
            ),
        ],
      ),
      body: builder != null
          ? builder(context)
          : _buildUnsupported(palette),
    );
  }

  Widget _buildUnsupported(CaibaoPalette palette) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x6),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: AppRadius.x2lAll,
            child: SizedBox(
              width: 72,
              height: 72,
              child: ColoredBox(
                color: palette.muted,
                child: Icon(
                  Icons.apps_outlined,
                  size: 36,
                  color: palette.mutedForeground,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x4),
          Text(
            controller.name,
            style: TextStyle(
              fontSize: AppTypography.x2l,
              fontWeight: FontWeight.w700,
              color: palette.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            controller.description.isNotEmpty
                ? controller.description
                : '暂无描述',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTypography.base,
              color: palette.mutedForeground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.x6),
          Text(
            '该应用暂未提供原生页面',
            style: TextStyle(
              fontSize: AppTypography.sm,
              color: palette.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
