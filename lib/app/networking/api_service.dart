import 'dart:io';

import 'package:caibao/app/models/agent.dart';
import 'package:caibao/app/models/chat_conversation.dart';
import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/app/models/drive_file.dart';
import 'package:caibao/app/models/llm_model.dart';
import 'package:caibao/app/models/notification_item.dart';
import 'package:caibao/app/models/storage_config.dart';
import 'package:caibao/app/models/upload_signature.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/dio/interceptors/bearer_auth_interceptor.dart';
import 'package:caibao/bootstrap/decoders.dart';
import 'package:caibao_crontab_app/caibao_crontab_app.dart';
import 'package:caibao_todo_app/caibao_todo_app.dart';
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

  Future<List<Agent>> listAgents() async {
    final data = await _data((dio) => dio.get('/agents'));
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => Agent.fromJson(e))
        .toList();
  }

  Future<Agent> getAgent(String id) async {
    final data = await _data((dio) => dio.get('/agents/$id'));
    return Agent.fromJson(data);
  }

  Future<String> createAgent({
    required String name,
    required String instruction,
    String description = '',
    String avatarUrl = '',
    bool isActive = true,
  }) async {
    final data = await _data(
      (dio) => dio.post(
        '/agents',
        data: {
          'name': name,
          'instruction': instruction,
          'description': description,
          'avatar_url': avatarUrl,
          'is_active': isActive,
        },
      ),
    );
    final map = Map<String, dynamic>.from(data as Map);
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) {
      throw ApiException('创建智能体失败');
    }
    return id;
  }

  Future<void> updateAgent(
    String id, {
    String? name,
    String? instruction,
    String? description,
    String? avatarUrl,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (instruction != null) body['instruction'] = instruction;
    if (description != null) body['description'] = description;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    if (isActive != null) body['is_active'] = isActive;
    await _data((dio) => dio.patch('/agents/$id', data: body));
  }

  Future<void> deleteAgent(String id) async {
    await _data((dio) => dio.delete('/agents/$id'));
  }

  Future<List<ChatMessage>> listAgentMessages(String agentId) async {
    final data = await _data((dio) => dio.get('/agents/$agentId/messages'));
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => ChatMessage.fromJson(e))
        .toList();
  }

  Future<void> clearAgentContext(String agentId) async {
    await _data((dio) => dio.post('/agents/$agentId/clear-context'));
  }

  Future<List<DriveFile>> listFiles({String? conversationId}) async {
    final query = <String, dynamic>{};
    if (conversationId != null && conversationId.isNotEmpty) {
      query['conversation_id'] = conversationId;
    }
    final data = await _data(
      (dio) => dio.get('/files', queryParameters: query),
    );
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => DriveFile.fromJson(e))
        .toList();
  }

  Future<void> deleteFile(String id) async {
    await _data((dio) => dio.delete('/files/$id'));
  }

  Future<String> getFileURL(String id) async {
    final data = await _data((dio) => dio.get('/files/$id/url'));
    final map = Map<String, dynamic>.from(data as Map);
    final url = map['url']?.toString() ?? '';
    if (url.isEmpty) {
      throw ApiException('获取文件地址失败');
    }
    return url;
  }

  Future<UploadSignature> getUploadSignature({
    required String filename,
    String contentType = '',
  }) async {
    final data = await _data(
      (dio) => dio.post(
        '/files/upload-signature',
        data: {
          'filename': filename,
          'content_type': contentType,
        },
      ),
    );
    return UploadSignature.fromJson(data);
  }

  Future<DriveFile> confirmFile({
    required String storageConfigId,
    required String objectKey,
    required String name,
    required int size,
    String contentType = '',
    String? conversationId,
    String source = 'user',
  }) async {
    final body = <String, dynamic>{
      'storage_config_id': storageConfigId,
      'object_key': objectKey,
      'name': name,
      'size': size,
      'content_type': contentType,
      'source': source,
    };
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversation_id'] = conversationId;
    }
    final data = await _data(
      (dio) => dio.post('/files/confirm', data: body),
    );
    return DriveFile.fromJson(data);
  }

  /// 预签名直传对象存储后 confirm（对齐 Web `uploadFileDirect`）。
  Future<DriveFile> uploadFileDirect({
    required File file,
    required String filename,
    String contentType = '',
    String? conversationId,
    String source = 'user',
  }) async {
    final size = await file.length();
    if (size <= 0) {
      throw ApiException('文件为空');
    }

    final sig = await getUploadSignature(
      filename: filename,
      contentType: contentType,
    );
    final uploadUrl = sig.uploadUrl.trim();
    if (uploadUrl.isEmpty) {
      throw ApiException('上传地址无效');
    }

    final putType =
        (sig.contentType.isNotEmpty ? sig.contentType : contentType).trim();
    final putDio = Dio();
    try {
      final putRes = await putDio.put<List<int>>(
        uploadUrl,
        data: await file.readAsBytes(),
        options: Options(
          headers: {
            if (putType.isNotEmpty) Headers.contentTypeHeader: putType,
          },
          contentType: putType.isNotEmpty ? putType : null,
          validateStatus: (code) => code != null && code >= 200 && code < 300,
        ),
      );
      if (putRes.statusCode == null ||
          putRes.statusCode! < 200 ||
          putRes.statusCode! >= 300) {
        throw ApiException('上传失败（${putRes.statusCode ?? 0}）');
      }
    } on DioException catch (e) {
      throw ApiException(e.message ?? '上传失败');
    } finally {
      putDio.close(force: true);
    }

    return confirmFile(
      storageConfigId: sig.storageConfigId,
      objectKey: sig.key,
      name: filename,
      size: size,
      contentType: contentType,
      conversationId: conversationId,
      source: source,
    );
  }

  Future<List<TodoGroup>> listTodoGroups() async {
    final data = await _data((dio) => dio.get('/todo-groups'));
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => TodoGroup.fromJson(e))
        .toList();
  }

  Future<String> createTodoGroup(String name) async {
    final data = await _data(
      (dio) => dio.post('/todo-groups', data: {'name': name}),
    );
    final map = Map<String, dynamic>.from(data as Map);
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) {
      throw ApiException('创建分组失败');
    }
    return id;
  }

  Future<void> updateTodoGroup(String id, {required String name}) async {
    await _data((dio) => dio.patch('/todo-groups/$id', data: {'name': name}));
  }

  Future<void> deleteTodoGroup(String id) async {
    await _data((dio) => dio.delete('/todo-groups/$id'));
  }

  Future<List<TodoItem>> listTodos(String groupId) async {
    final data = await _data(
      (dio) => dio.get(
        '/todos',
        queryParameters: {'group_id': groupId},
      ),
    );
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => TodoItem.fromJson(e))
        .toList();
  }

  Future<String> createTodo({
    required String groupId,
    required String title,
  }) async {
    final data = await _data(
      (dio) => dio.post(
        '/todos',
        data: {'group_id': groupId, 'title': title},
      ),
    );
    final map = Map<String, dynamic>.from(data as Map);
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) {
      throw ApiException('创建待办失败');
    }
    return id;
  }

  Future<void> updateTodo(
    String id, {
    String? title,
    bool? done,
    String? groupId,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (done != null) body['done'] = done;
    if (groupId != null) body['group_id'] = groupId;
    await _data((dio) => dio.patch('/todos/$id', data: body));
  }

  Future<void> deleteTodo(String id) async {
    await _data((dio) => dio.delete('/todos/$id'));
  }

  Future<List<CronJob>> listCronJobs() async {
    final data = await _data((dio) => dio.get('/cron-jobs'));
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => CronJob.fromJson(e))
        .toList();
  }

  Future<CronJob> createCronJob(CronJob draft) async {
    final data = await _data(
      (dio) => dio.post('/cron-jobs', data: draft.toCreateBody()),
    );
    return CronJob.fromJson(data);
  }

  Future<CronJob> updateCronJob(String id, CronJob draft) async {
    final data = await _data(
      (dio) => dio.patch('/cron-jobs/$id', data: draft.toCreateBody()),
    );
    return CronJob.fromJson(data);
  }

  Future<void> deleteCronJob(String id) async {
    await _data((dio) => dio.delete('/cron-jobs/$id'));
  }

  Future<CronRunStatus> runCronJob(String id) async {
    final data = await _data((dio) => dio.post('/cron-jobs/$id/run'));
    final map = Map<String, dynamic>.from(data as Map);
    return CronRunStatus.parse(map['status']?.toString());
  }

  Future<List<CronJobRun>> listCronJobRuns(String id) async {
    final data = await _data((dio) => dio.get('/cron-jobs/$id/runs'));
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => CronJobRun.fromJson(e))
        .toList();
  }

  Future<List<S3StorageConfig>> listStorageConfigs() async {
    final data = await _data((dio) => dio.get('/storage-configs'));
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => S3StorageConfig.fromJson(e))
        .toList();
  }

  Future<S3StorageConfig> getStorageConfig(String id) async {
    final data = await _data((dio) => dio.get('/storage-configs/$id'));
    return S3StorageConfig.fromJson(data);
  }

  Future<String> createStorageConfig(Map<String, dynamic> body) async {
    final data = await _data(
      (dio) => dio.post('/storage-configs', data: body),
    );
    final map = Map<String, dynamic>.from(data as Map);
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) throw ApiException('创建存储配置失败');
    return id;
  }

  Future<void> updateStorageConfig(String id, Map<String, dynamic> body) async {
    await _data((dio) => dio.patch('/storage-configs/$id', data: body));
  }

  Future<void> deleteStorageConfig(String id) async {
    await _data((dio) => dio.delete('/storage-configs/$id'));
  }

  Future<void> enableStorageConfig(String id) async {
    await _data((dio) => dio.post('/storage-configs/$id/enable'));
  }

  Future<List<LlmModel>> listLlmModels() async {
    final data = await _data((dio) => dio.get('/llm-models'));
    final map = Map<String, dynamic>.from(data as Map);
    return (map['items'] as List? ?? [])
        .map((e) => LlmModel.fromJson(e))
        .toList();
  }

  Future<LlmModel> getLlmModel(String id) async {
    final data = await _data((dio) => dio.get('/llm-models/$id'));
    return LlmModel.fromJson(data);
  }

  Future<String> createLlmModel(Map<String, dynamic> body) async {
    final data = await _data((dio) => dio.post('/llm-models', data: body));
    final map = Map<String, dynamic>.from(data as Map);
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) throw ApiException('创建模型失败');
    return id;
  }

  Future<void> updateLlmModel(String id, Map<String, dynamic> body) async {
    await _data((dio) => dio.patch('/llm-models/$id', data: body));
  }

  Future<void> deleteLlmModel(String id) async {
    await _data((dio) => dio.delete('/llm-models/$id'));
  }

  Future<void> enableLlmModel(String id) async {
    await _data((dio) => dio.post('/llm-models/$id/enable'));
  }

  Future<({List<NotificationItem> items, int total})> listNotifications({
    int pageNum = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) async {
    final query = <String, dynamic>{
      'page_num': pageNum,
      'page_size': pageSize,
    };
    if (unreadOnly) {
      query['unread_only'] = 'true';
    }

    final data = await _data(
      (dio) => dio.get('/notifications', queryParameters: query),
    );
    final map = Map<String, dynamic>.from(data as Map? ?? {});
    final items = (map['items'] as List? ?? [])
        .map((e) => NotificationItem.fromJson(e))
        .toList();
    final total = map['total'] is int
        ? map['total'] as int
        : int.tryParse('${map['total'] ?? items.length}') ?? items.length;
    return (items: items, total: total);
  }

  Future<int> getUnreadNotificationCount() async {
    final data = await _data((dio) => dio.get('/notifications/unread-count'));
    final map = Map<String, dynamic>.from(data as Map? ?? {});
    final count = map['count'];
    if (count is int) return count;
    return int.tryParse('${count ?? 0}') ?? 0;
  }

  Future<void> markNotificationRead(String id) async {
    await _data((dio) => dio.post('/notifications/$id/read'));
  }

  Future<int> markAllNotificationsRead() async {
    final data = await _data((dio) => dio.post('/notifications/read-all'));
    final map = Map<String, dynamic>.from(data as Map? ?? {});
    final count = map['count'];
    if (count is int) return count;
    return int.tryParse('${count ?? 0}') ?? 0;
  }

  Future<int> trackEvents(List<Map<String, dynamic>> events) async {
    final data = await _data(
      (dio) => dio.post('/analytics/events', data: {'events': events}),
    );
    final map = Map<String, dynamic>.from(data as Map? ?? {});
    final accepted = map['accepted'];
    if (accepted is int) return accepted;
    return int.tryParse('${accepted ?? events.length}') ?? events.length;
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
