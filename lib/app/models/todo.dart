import 'package:nylo_framework/nylo_framework.dart';

class TodoGroup extends Model {
  static StorageKey key = 'todo_group';

  String? id;
  String? name;
  int sort;
  DateTime? createdAt;
  DateTime? updatedAt;

  TodoGroup({
    this.id,
    this.name,
    this.sort = 0,
    this.createdAt,
    this.updatedAt,
  }) : super(key: key);

  TodoGroup.fromJson(dynamic data)
      : id = data['id']?.toString(),
        name = data['name']?.toString(),
        sort = data['sort'] is int
            ? data['sort'] as int
            : int.tryParse('${data['sort'] ?? 0}') ?? 0,
        createdAt = _parseDate(data['created_at']),
        updatedAt = _parseDate(data['updated_at']),
        super(key: key);

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sort': sort,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class TodoItem extends Model {
  static StorageKey key = 'todo_item';

  String? id;
  String? groupId;
  String? title;
  bool done;
  int sort;
  DateTime? createdAt;
  DateTime? updatedAt;

  TodoItem({
    this.id,
    this.groupId,
    this.title,
    this.done = false,
    this.sort = 0,
    this.createdAt,
    this.updatedAt,
  }) : super(key: key);

  TodoItem.fromJson(dynamic data)
      : id = data['id']?.toString(),
        groupId = data['group_id']?.toString(),
        title = data['title']?.toString(),
        done = data['done'] == true,
        sort = data['sort'] is int
            ? data['sort'] as int
            : int.tryParse('${data['sort'] ?? 0}') ?? 0,
        createdAt = _parseDate(data['created_at']),
        updatedAt = _parseDate(data['updated_at']),
        super(key: key);

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'group_id': groupId,
        'title': title,
        'done': done,
        'sort': sort,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
