enum CronScheduleType {
  everyMinute('every_minute', '每分钟'),
  everyHour('every_hour', '每小时'),
  everyDay('every_day', '每天'),
  everyWeek('every_week', '每周'),
  custom('custom', '自定义');

  const CronScheduleType(this.value, this.label);

  final String value;
  final String label;

  static CronScheduleType? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final item in CronScheduleType.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  static CronScheduleType parse(
    String? raw, {
    CronScheduleType fallback = CronScheduleType.everyDay,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

enum CronActionType {
  notification('notification', '站内通知'),
  email('email', '邮件');

  const CronActionType(this.value, this.label);

  final String value;
  final String label;

  static CronActionType? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final item in CronActionType.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  static CronActionType parse(
    String? raw, {
    CronActionType fallback = CronActionType.notification,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

enum CronRunStatus {
  success('success'),
  failed('failed');

  const CronRunStatus(this.value);

  final String value;

  static CronRunStatus? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final item in CronRunStatus.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  static CronRunStatus parse(
    String? raw, {
    CronRunStatus fallback = CronRunStatus.success,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

class CronJob {
  CronJob({
    this.id,
    required this.name,
    required this.title,
    required this.content,
    required this.scheduleType,
    required this.cronExpr,
    this.minute,
    this.hour,
    this.weekday,
    required this.actionType,
    this.actionPayload,
    this.enabled = true,
    this.lastRunAt,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String name;
  final String title;
  final String content;
  final CronScheduleType scheduleType;
  final String cronExpr;
  final int? minute;
  final int? hour;
  final int? weekday;
  final CronActionType actionType;
  final String? actionPayload;
  final bool enabled;
  final DateTime? lastRunAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CronJob.fromJson(dynamic data) {
    return CronJob(
      id: data['id']?.toString(),
      name: data['name']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      scheduleType: CronScheduleType.parse(data['schedule_type']?.toString()),
      cronExpr: data['cron_expr']?.toString() ?? '',
      minute: _asInt(data['minute']),
      hour: _asInt(data['hour']),
      weekday: _asInt(data['weekday']),
      actionType: CronActionType.parse(data['action_type']?.toString()),
      actionPayload: data['action_payload']?.toString(),
      enabled: data['enabled'] == true,
      lastRunAt: _parseDate(data['last_run_at']),
      createdAt: _parseDate(data['created_at']),
      updatedAt: _parseDate(data['updated_at']),
    );
  }

  Map<String, dynamic> toCreateBody() {
    return {
      'name': name,
      'title': title,
      'content': content,
      'schedule_type': scheduleType.value,
      if (scheduleType == CronScheduleType.custom) 'cron_expr': cronExpr,
      if (minute != null) 'minute': minute,
      if (hour != null) 'hour': hour,
      if (weekday != null) 'weekday': weekday,
      'action_type': actionType.value,
      if (actionPayload != null && actionPayload!.isNotEmpty)
        'action_payload': actionPayload,
      'enabled': enabled,
    };
  }
}

class CronJobRun {
  CronJobRun({
    this.id,
    this.jobId,
    required this.status,
    this.message = '',
    this.startedAt,
  });

  final String? id;
  final String? jobId;
  final CronRunStatus status;
  final String message;
  final DateTime? startedAt;

  factory CronJobRun.fromJson(dynamic data) {
    return CronJobRun(
      id: data['id']?.toString(),
      jobId: data['job_id']?.toString(),
      status: CronRunStatus.parse(data['status']?.toString()),
      message: data['message']?.toString() ?? '',
      startedAt: _parseDate(data['started_at']),
    );
  }
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse('$v');
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
