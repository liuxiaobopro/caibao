import 'dart:convert';

import 'package:caibao/app/apps/registry.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
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
  bool _loading = true;
  String _status = '加载中…';
  String? _error;
  User? _me;

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

        if (_slug == 'hello') {
          await _loadHello();
          return;
        }

        if (mounted) setState(() => _loading = false);
      };

  @override
  bool get stateManaged => false;

  Future<void> _loadHello() async {
    setState(() {
      _loading = true;
      _status = '加载中…';
      _error = null;
    });
    try {
      final me = await api<ApiService>((r) => r.fetchMe());
      if (!mounted) return;
      setState(() {
        _me = me;
        _status = '已接入';
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = '应用加载失败';
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = '应用加载失败';
        _error = e.toString();
        _loading = false;
      });
    }
  }

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
          : _slug == 'hello'
              ? _buildHello(palette)
              : _buildUnsupported(palette),
    );
  }

  Widget _buildHello(CaibaoPalette palette) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.x6),
      children: [
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
          _status,
          style: TextStyle(
            fontSize: AppTypography.sm,
            color: palette.mutedForeground,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.x4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.x3),
            decoration: BoxDecoration(
              color: palette.danger.withValues(alpha: 0.1),
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: palette.danger.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              _error!,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: palette.danger,
              ),
            ),
          ),
        ],
        if (_me != null) ...[
          const SizedBox(height: AppSpacing.x4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.x3),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: palette.muted),
            ),
            child: Text(
              const JsonEncoder.withIndent('  ').convert(_me!.toJson()),
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: palette.foreground,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
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
