import 'package:nylo_framework/nylo_framework.dart';

class DriveFile extends Model {
  static StorageKey key = 'drive_file';

  String? id;
  String? storageConfigId;
  String? storageConfigName;
  String? conversationId;
  String? conversationTitle;
  String? messageId;
  String? source;
  String? name;
  int size;
  String? contentType;
  String? url;
  DateTime? createdAt;
  DateTime? updatedAt;

  DriveFile({
    this.id,
    this.storageConfigId,
    this.storageConfigName,
    this.conversationId,
    this.conversationTitle,
    this.messageId,
    this.source,
    this.name,
    this.size = 0,
    this.contentType,
    this.url,
    this.createdAt,
    this.updatedAt,
  }) : super(key: key);

  DriveFile.fromJson(dynamic data)
      : id = data['id']?.toString(),
        storageConfigId = data['storage_config_id']?.toString(),
        storageConfigName = data['storage_config_name']?.toString(),
        conversationId = data['conversation_id']?.toString(),
        conversationTitle = data['conversation_title']?.toString(),
        messageId = data['message_id']?.toString(),
        source = data['source']?.toString(),
        name = data['name']?.toString(),
        size = data['size'] is int
            ? data['size'] as int
            : int.tryParse('${data['size'] ?? 0}') ?? 0,
        contentType = data['content_type']?.toString(),
        url = data['url']?.toString(),
        createdAt = _parseDate(data['created_at']),
        updatedAt = _parseDate(data['updated_at']),
        super(key: key);

  bool get isImage {
    final type = contentType ?? '';
    if (type.startsWith('image/')) return true;
    final n = name ?? '';
    return RegExp(r'\.(png|jpe?g|gif|webp|bmp|svg)$', caseSensitive: false)
        .hasMatch(n);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'storage_config_id': storageConfigId,
        'storage_config_name': storageConfigName,
        'conversation_id': conversationId,
        'conversation_title': conversationTitle,
        'message_id': messageId,
        'source': source,
        'name': name,
        'size': size,
        'content_type': contentType,
        'url': url,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
