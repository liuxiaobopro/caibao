import 'package:caibao_theme/caibao_theme.dart';
import 'package:flutter/material.dart';

import 'crontab_api.dart';
import 'models.dart';

class CrontabApp extends StatefulWidget {
  const CrontabApp({super.key, required this.api});

  final CrontabApi api;

  @override
  State<CrontabApp> createState() => _CrontabAppState();
}

class _CrontabAppState extends State<CrontabApp> {
  List<CronJob> _jobs = [];
  List<CronJobRun> _runs = [];
  String? _selectedId;
  String _error = '';
  bool _loading = true;
  bool _saving = false;

  final _name = TextEditingController();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _cronExpr = TextEditingController();
  CronScheduleType _schedule = CronScheduleType.everyDay;
  CronActionType _action = CronActionType.notification;
  bool _enabled = true;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _content.dispose();
    _cronExpr.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final jobs = await widget.api.listJobs();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  CronJob get _draft => CronJob(
        name: _name.text.trim(),
        title: _title.text.trim(),
        content: _content.text.trim(),
        scheduleType: _schedule,
        cronExpr: _cronExpr.text.trim(),
        hour: _schedule == CronScheduleType.everyDay ||
                _schedule == CronScheduleType.everyWeek
            ? 9
            : null,
        minute: _schedule == CronScheduleType.everyMinute ? null : 0,
        weekday: _schedule == CronScheduleType.everyWeek ? 1 : null,
        actionType: _action,
        enabled: _enabled,
      );

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = '';
    });
    try {
      if (_editingId == null) {
        await widget.api.createJob(_draft);
      } else {
        await widget.api.updateJob(_editingId!, _draft);
      }
      _clearForm();
      await _refresh();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _clearForm() {
    _editingId = null;
    _name.clear();
    _title.clear();
    _content.clear();
    _cronExpr.clear();
    _schedule = CronScheduleType.everyDay;
    _action = CronActionType.notification;
    _enabled = true;
  }

  void _startEdit(CronJob job) {
    setState(() {
      _editingId = job.id;
      _name.text = job.name;
      _title.text = job.title;
      _content.text = job.content;
      _cronExpr.text = job.cronExpr;
      _schedule = job.scheduleType;
      _action = job.actionType;
      _enabled = job.enabled;
    });
  }

  Future<void> _selectRuns(String id) async {
    setState(() => _selectedId = id);
    try {
      final runs = await widget.api.listRuns(id);
      if (!mounted) return;
      setState(() => _runs = runs);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (_loading) {
      return Center(
        child: Text(
          '加载中…',
          style: TextStyle(color: palette.mutedForeground),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.x4),
      children: [
        Text(
          '计划任务',
          style: TextStyle(
            fontSize: AppTypography.x2l,
            fontWeight: FontWeight.w700,
            color: palette.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          '定时站内通知或邮件',
          style: TextStyle(
            fontSize: AppTypography.sm,
            color: palette.mutedForeground,
          ),
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.x3),
          Text(_error, style: TextStyle(color: palette.danger)),
        ],
        const SizedBox(height: AppSpacing.x4),
        Text(
          _editingId == null ? '新建' : '编辑',
          style: TextStyle(
            fontSize: AppTypography.base,
            fontWeight: FontWeight.w600,
            color: palette.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        TextField(
          controller: _name,
          decoration: const InputDecoration(hintText: '名称'),
        ),
        TextField(
          controller: _title,
          decoration: const InputDecoration(hintText: '标题'),
        ),
        TextField(
          controller: _content,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '内容'),
        ),
        DropdownButtonFormField<CronScheduleType>(
          initialValue: _schedule,
          items: CronScheduleType.values
              .map(
                (e) => DropdownMenuItem(value: e, child: Text(e.label)),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _schedule = v);
          },
        ),
        if (_schedule == CronScheduleType.custom)
          TextField(
            controller: _cronExpr,
            decoration: const InputDecoration(hintText: '0 9 * * *'),
          ),
        DropdownButtonFormField<CronActionType>(
          initialValue: _action,
          items: CronActionType.values
              .map(
                (e) => DropdownMenuItem(value: e, child: Text(e.label)),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _action = v);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('启用'),
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
        ),
        Row(
          children: [
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: palette.brand,
                foregroundColor: palette.brandOn,
              ),
              child: Text(_editingId == null ? '创建' : '保存'),
            ),
            if (_editingId != null) ...[
              const SizedBox(width: AppSpacing.x2),
              TextButton(
                onPressed: () => setState(_clearForm),
                child: const Text('取消'),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.x6),
        Text(
          '任务列表',
          style: TextStyle(
            fontSize: AppTypography.base,
            fontWeight: FontWeight.w600,
            color: palette.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        if (_jobs.isEmpty)
          Text(
            '暂无任务',
            style: TextStyle(color: palette.mutedForeground),
          )
        else
          ..._jobs.map((job) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(job.name),
              subtitle: Text(
                '${job.scheduleType.label} · ${job.actionType.label} · '
                '${job.enabled ? '启用' : '停用'} · ${job.cronExpr}',
              ),
              onTap: () {
                final id = job.id;
                if (id != null) {
                  _selectRuns(id);
                }
              },
              trailing: Wrap(
                spacing: AppSpacing.x1,
                children: [
                  IconButton(
                    tooltip: '立即执行',
                    onPressed: () async {
                      final id = job.id;
                      if (id == null) return;
                      try {
                        await widget.api.runJob(id);
                        await _refresh();
                        await _selectRuns(id);
                      } catch (e) {
                        if (mounted) setState(() => _error = e.toString());
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: () => _startEdit(job),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () async {
                      final id = job.id;
                      if (id == null) return;
                      try {
                        await widget.api.deleteJob(id);
                        await _refresh();
                      } catch (e) {
                        if (mounted) setState(() => _error = e.toString());
                      }
                    },
                    icon: Icon(Icons.delete_outline, color: palette.danger),
                  ),
                ],
              ),
            );
          }),
        if (_selectedId != null) ...[
          const SizedBox(height: AppSpacing.x4),
          Text(
            '执行记录',
            style: TextStyle(
              fontSize: AppTypography.base,
              fontWeight: FontWeight.w600,
              color: palette.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          if (_runs.isEmpty)
            Text(
              '暂无记录',
              style: TextStyle(color: palette.mutedForeground),
            )
          else
            ..._runs.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                child: Text(
                  '${r.status.value} · ${r.message} · '
                  '${r.startedAt?.toLocal() ?? ''}',
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    color: r.status == CronRunStatus.failed
                        ? palette.danger
                        : palette.mutedForeground,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
