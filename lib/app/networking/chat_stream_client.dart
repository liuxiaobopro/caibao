import 'dart:async';
import 'dart:convert';

import 'package:caibao/app/models/chat_sse_event.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ChatStreamClient {
  ChatStreamClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<void> streamConversationChat({
    required String conversationId,
    required String content,
    required void Function(ChatSSEEvent event) onEvent,
    List<String>? fileIds,
    bool enableThinking = false,
    CancelToken? cancelToken,
  }) {
    return _streamChat(
      path: '/conversations/$conversationId/chat',
      content: content,
      onEvent: onEvent,
      fileIds: fileIds,
      enableThinking: enableThinking,
      cancelToken: cancelToken,
    );
  }

  Future<void> streamAgentChat({
    required String agentId,
    required String content,
    required void Function(ChatSSEEvent event) onEvent,
    List<String>? fileIds,
    bool enableThinking = false,
    CancelToken? cancelToken,
  }) {
    return _streamChat(
      path: '/agents/$agentId/chat',
      content: content,
      onEvent: onEvent,
      fileIds: fileIds,
      enableThinking: enableThinking,
      cancelToken: cancelToken,
    );
  }

  Future<void> _streamChat({
    required String path,
    required String content,
    required void Function(ChatSSEEvent event) onEvent,
    List<String>? fileIds,
    bool enableThinking = false,
    CancelToken? cancelToken,
  }) async {
    final token = Auth.data(field: 'token')?.toString();
    final baseUrl =
        getEnv('API_BASE_URL')?.toString().replaceAll(RegExp(r'/$'), '') ?? '';

    final body = <String, dynamic>{
      'content': content,
      'enable_thinking': enableThinking,
    };
    if (fileIds != null && fileIds.isNotEmpty) {
      body['file_ids'] = fileIds;
    }

    final headers = <String, dynamic>{
      'Accept': 'text/event-stream',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await _dio.post<ResponseBody>(
      '$baseUrl$path',
      data: body,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    if (response.statusCode == 401) {
      await Auth.logout();
      throw ApiException('授权已过期', code: 5);
    }

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw ApiException('请求失败 (${response.statusCode ?? 0})');
    }

    final stream = response.data?.stream;
    if (stream == null) {
      throw ApiException('响应无内容');
    }

    var buffer = '';
    await for (final chunk in stream.cast<List<int>>()) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      final parts = buffer.split('\n\n');
      buffer = parts.removeLast();
      for (final part in parts) {
        final event = _parseSSEBlock(part);
        if (event == null) continue;
        onEvent(event);
      }
    }

    if (buffer.trim().isNotEmpty) {
      final event = _parseSSEBlock(buffer);
      if (event != null) onEvent(event);
    }
  }

  ChatSSEEvent? _parseSSEBlock(String block) {
    final lines = block.split('\n');
    var data = '';

    for (final raw in lines) {
      final line = raw.replaceAll('\r', '');
      if (line.isEmpty || line.startsWith(':')) continue;
      if (line.startsWith('data:')) {
        data += line.substring(5).trimLeft();
      }
    }

    if (data.isEmpty) return null;

    try {
      final json = jsonDecode(data);
      if (json is Map<String, dynamic>) {
        return ChatSSEEvent.fromJson(json);
      }
      if (json is Map) {
        return ChatSSEEvent.fromJson(Map<String, dynamic>.from(json));
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
