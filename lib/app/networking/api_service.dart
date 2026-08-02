import 'package:caibao/app/models/chat_conversation.dart';
import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/dio/interceptors/bearer_auth_interceptor.dart';
import 'package:caibao/bootstrap/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ApiService extends NyApiService {
  ApiService()
      : super(
          decoders: modelDecoders,
          useNetworkLogger: true,
        );

  @override
  String get baseUrl => getEnv('API_BASE_URL');

  @override
  Map<Type, Interceptor> get interceptors => <Type, Interceptor>{
        ...super.interceptors,
        BearerAuthInterceptor: BearerAuthInterceptor(),
      };

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    final token = Auth.data(field: 'token')?.toString();
    if (token != null && token.isNotEmpty) {
      headers.addBearerToken(token);
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final data = await _data(
      (dio) => dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      ),
      auth: false,
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<User> fetchMe() async {
    final data = await _data((dio) => dio.get('/auth/me'));
    return User.fromJson(data);
  }

  Future<({List<ChatConversation> items, int total})> listConversations({
    int pageNum = 1,
    int pageSize = 50,
    String? keyword,
  }) async {
    final query = <String, dynamic>{
      'page_num': pageNum,
      'page_size': pageSize,
    };
    if (keyword != null && keyword.trim().isNotEmpty) {
      query['keyword'] = keyword.trim();
    }

    final data = await _data(
      (dio) => dio.get('/conversations', queryParameters: query),
    );
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => ChatConversation.fromJson(e))
        .toList();
    final total = map['total'] is int
        ? map['total'] as int
        : int.tryParse('${map['total'] ?? items.length}') ?? items.length;
    return (items: items, total: total);
  }

  Future<String> createConversation({String title = ''}) async {
    final data = await _data(
      (dio) => dio.post('/conversations', data: {'title': title}),
    );
    final map = Map<String, dynamic>.from(data as Map);
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) {
      throw ApiException('创建会话失败');
    }
    return id;
  }

  Future<void> deleteConversation(String id) async {
    await _data((dio) => dio.delete('/conversations/$id'));
  }

  Future<List<ChatMessage>> listMessages(String conversationId) async {
    final data = await _data(
      (dio) => dio.get('/conversations/$conversationId/messages'),
    );
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => ChatMessage.fromJson(e))
        .toList();
  }

  Future<dynamic> _data(
    Future Function(Dio dio) request, {
    bool auth = true,
  }) async {
    final body = await network<Map<String, dynamic>>(
      request: request,
      shouldSetAuthHeaders: auth,
    );
    if (body == null) {
      throw ApiException('网络错误');
    }
    final code = body['code'];
    if (code != 0) {
      throw ApiException(
        body['msg']?.toString() ?? '请求失败',
        code: code is int ? code : -1,
      );
    }
    return body['data'];
  }
}
