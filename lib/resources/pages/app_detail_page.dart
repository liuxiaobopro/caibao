import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
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
  String? _iconUrl;
  bool _loading = true;

  @override
  get init => () async {
        final arg = data();
        if (arg is Map) {
          _slug = arg['slug']?.toString() ?? '';
          _name = arg['name']?.toString() ?? '';
          _description = arg['description']?.toString() ?? '';
          _iconUrl = arg['icon_url']?.toString();
        }
        if (_slug.isEmpty) {
          setState(() => _loading = false);
          return;
        }
        try {
          final app = await api<ApiService>((r) => r.getApp(_slug));
          if (!mounted) return;
          setState(() {
            _name = app?.name?.isNotEmpty == true ? app!.name! : _name;
            _description = app?.description ?? _description;
            _iconUrl = app?.iconUrl ?? _iconUrl;
          });
        } on ApiException catch (e) {
          showToastSorry(description: e.message);
        } catch (e) {
          showToastSorry(description: e.toString());
        } finally {
          if (mounted) setState(() => _loading = false);
        }
      };

  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(_name.isEmpty ? '应用' : _name),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.x6),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.x2lAll,
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: _iconUrl?.isNotEmpty == true
                          ? Image.network(_iconUrl!, fit: BoxFit.cover)
                          : ColoredBox(
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
            ),
    );
  }
}
