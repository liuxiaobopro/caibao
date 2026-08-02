import 'package:nylo_framework/nylo_framework.dart';

class Agent extends Model {
  static StorageKey key = 'agent';

  String? id;
  String? scope;
  String? userId;
  String? name;
  String? description;
  String? instruction;
  String? avatarUrl;
  bool isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  Agent({
    this.id,
    this.scope,
    this.userId,
    this.name,
    this.description,
    this.instruction,
    this.avatarUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  }) : super(key: key);

  Agent.fromJson(dynamic data)
      : id = data['id']?.toString(),
        scope = data['scope']?.toString(),
        userId = data['user_id']?.toString(),
        name = data['name']?.toString(),
        description = data['description']?.toString(),
        instruction = data['instruction']?.toString(),
        avatarUrl = data['avatar_url']?.toString(),
        isActive = data['is_active'] != false,
        createdAt = _parseDate(data['created_at']),
        updatedAt = _parseDate(data['updated_at']),
        super(key: key);

  bool get isSystem => scope == 'system';
  bool get isUser => scope == 'user';

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'scope': scope,
        'user_id': userId,
        'name': name,
        'description': description,
        'instruction': instruction,
        'avatar_url': avatarUrl,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
