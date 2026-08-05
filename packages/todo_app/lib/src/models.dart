class TodoGroup {
  TodoGroup({
    this.id,
    this.name,
    this.sort = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? name;
  final int sort;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TodoGroup.fromJson(dynamic data) {
    return TodoGroup(
      id: data['id']?.toString(),
      name: data['name']?.toString(),
      sort: data['sort'] is int
          ? data['sort'] as int
          : int.tryParse('${data['sort'] ?? 0}') ?? 0,
      createdAt: _parseDate(data['created_at']),
      updatedAt: _parseDate(data['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sort': sort,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class TodoItem {
  TodoItem({
    this.id,
    this.groupId,
    this.title,
    this.done = false,
    this.sort = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? groupId;
  final String? title;
  final bool done;
  final int sort;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TodoItem.fromJson(dynamic data) {
    return TodoItem(
      id: data['id']?.toString(),
      groupId: data['group_id']?.toString(),
      title: data['title']?.toString(),
      done: data['done'] == true,
      sort: data['sort'] is int
          ? data['sort'] as int
          : int.tryParse('${data['sort'] ?? 0}') ?? 0,
      createdAt: _parseDate(data['created_at']),
      updatedAt: _parseDate(data['updated_at']),
    );
  }

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

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
