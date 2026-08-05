import 'package:caibao/app/apps/registry.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:caibao/resources/themes/tokens/caibao_palette.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AppDetailPage extends NyStatefulWidget {
  static RouteView path = ('/apps/detail', (_) => AppDetailPage());

  AppDetailPage({super.key}) : super(child: () => _AppDetailPageState());
}

class _AppDetailPageState extends NyPage<AppDetailPage> {
  String _slug = '';
  String _name = '';
  String _description = '';

  @override
  get init => () async {
        final arg = data();
        if (arg is Map) {
          _slug = arg['slug']?.toString() ?? '';
          _name = arg['name']?.toString() ?? '';
          _description = arg['description']?.toString() ?? '';
        }
        final meta = getAppMeta(_slug);
        if (meta != null) {
          _name = meta.name;
          _description = meta.description;
        }
      };

  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final builder = getAppComponent(_slug);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(_name.isEmpty ? '应用' : _name),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
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
            _name,
            style: TextStyle(
              fontSize: AppTypography.x2l,
              fontWeight: FontWeight.w700,
              color: palette.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            _description.isNotEmpty ? _description : '暂无描述',
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
