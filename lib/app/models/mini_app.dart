import 'package:nylo_framework/nylo_framework.dart';

class MiniApp extends Model {
  static StorageKey key = 'mini_app';

  String? id;
  String? slug;
  String? name;
  String? description;
  String? iconUrl;
  String? entryUrl;
  List<String> scopes;
  int sort;
  DateTime? createdAt;
  DateTime? updatedAt;

  MiniApp({
    this.id,
    this.slug,
    this.name,
    this.description,
    this.iconUrl,
    this.entryUrl,
    this.scopes = const [],
    this.sort = 0,
    this.createdAt,
    this.updatedAt,
  }) : super(key: key);

  MiniApp.fromJson(dynamic data)
      : id = data['id']?.toString(),
        slug = data['slug']?.toString(),
        name = data['name']?.toString(),
        description = data['description']?.toString(),
        iconUrl = data['icon_url']?.toString(),
        entryUrl = data['entry_url']?.toString(),
        scopes = (data['scopes'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
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
        'slug': slug,
        'name': name,
        'description': description,
        'icon_url': iconUrl,
        'entry_url': entryUrl,
        'scopes': scopes,
        'sort': sort,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class MiniAppSession {
  MiniAppSession({
    required this.sessionToken,
    required this.expiresIn,
    required this.entryUrl,
    required this.scopes,
    required this.slug,
    required this.name,
  });

  final String sessionToken;
  final int expiresIn;
  final String entryUrl;
  final List<String> scopes;
  final String slug;
  final String name;

  factory MiniAppSession.fromJson(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    return MiniAppSession(
      sessionToken: map['session_token']?.toString() ?? '',
      expiresIn: map['expires_in'] is int
          ? map['expires_in'] as int
          : int.tryParse('${map['expires_in'] ?? 0}') ?? 0,
      entryUrl: map['entry_url']?.toString() ?? '',
      scopes: (map['scopes'] as List? ?? []).map((e) => e.toString()).toList(),
      slug: map['slug']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }
}
