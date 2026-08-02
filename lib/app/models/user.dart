import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  static final StorageKey key = 'user';

  String? id;
  String? username;
  String? email;
  String? nickname;
  String? avatarUrl;

  User({
    this.id,
    this.username,
    this.email,
    this.nickname,
    this.avatarUrl,
  }) : super(key: key);

  User.fromJson(dynamic data) : super(key: key) {
    id = data['id']?.toString();
    username = data['username']?.toString();
    email = data['email']?.toString();
    nickname = data['nickname']?.toString();
    avatarUrl = data['avatar_url']?.toString();
  }

  String get displayName {
    if (nickname != null && nickname!.trim().isNotEmpty) {
      return nickname!;
    }
    if (username != null && username!.trim().isNotEmpty) {
      return username!;
    }
    return '用户';
  }

  String get caibaoId => id ?? username ?? '';

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'nickname': nickname,
        'avatar_url': avatarUrl,
      };
}
