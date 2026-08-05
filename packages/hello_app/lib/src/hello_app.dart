import 'dart:convert';

import 'package:caibao_theme/caibao_theme.dart';
import 'package:flutter/material.dart';

import 'hello_api.dart';

class HelloApp extends StatefulWidget {
  const HelloApp({super.key, required this.api});

  final HelloApi api;

  @override
  State<HelloApp> createState() => _HelloAppState();
}

class _HelloAppState extends State<HelloApp> {
  String _status = '加载中…';
  Map<String, dynamic>? _me;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _status = '加载中…';
      _error = null;
    });
    try {
      final me = await widget.api.fetchMe();
      if (!mounted) return;
      setState(() {
        _me = me;
        _status = '已接入';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = '应用加载失败';
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          '示例应用',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: palette.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _status,
          style: TextStyle(
            fontSize: 13,
            color: palette.mutedForeground,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: palette.danger.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              _error!,
              style: TextStyle(
                fontSize: 13,
                color: palette.danger,
              ),
            ),
          ),
        ],
        if (_me != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.muted),
            ),
            child: Text(
              const JsonEncoder.withIndent('  ').convert(_me),
              style: TextStyle(
                fontSize: 13,
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
}
