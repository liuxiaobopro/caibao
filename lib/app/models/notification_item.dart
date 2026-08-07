import 'package:nylo_framework/nylo_framework.dart';

class NotificationItem extends Model {
  static StorageKey key = 'notification_item';

  String? id;
  String? scope;
  String? title;
  String? content;
  String? link;
  bool read;
  DateTime? createdAt;
  DateTime? updatedAt;

  NotificationItem({
    this.id,
    this.scope,
    this.title,
    this.content,
    this.link,
    this.read = false,
    this.createdAt,
    this.updatedAt,
  }) : super(key: key);

  NotificationItem.fromJson(dynamic data)
      : id = data['id']?.toString(),
        scope = data['scope']?.toString(),
        title = data['title']?.toString(),
        content = data['content']?.toString(),
        link = data['link']?.toString(),
        read = data['read'] == true,
        createdAt = _parseDate(data['created_at']),
        updatedAt = _parseDate(data['updated_at']),
        super(key: key);

  bool get isBroadcast => scope == 'broadcast';

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scope': scope,
      'title': title,
      'content': content,
      'link': link,
      'read': read,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
