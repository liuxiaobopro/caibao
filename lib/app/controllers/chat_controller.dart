import 'package:caibao/app/controllers/controller.dart';
import 'package:caibao/app/models/chat_conversation.dart';
import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/app/models/drive_file.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/app/networking/chat_stream_client.dart';
import 'package:caibao/app/services/chat_stream_handler.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ChatController extends Controller {
  final ChatStreamClient _streamClient = ChatStreamClient();

  String title = '菜包';
  String? activeConversationId;
  String conversationKeyword = '';
  List<ChatConversation> conversations = [];
  List<ChatMessage> messages = [];
  User? user;
  bool loadingConversations = false;
  bool loadingMessages = false;
  bool sending = false;

  VoidCallback? onScrollToBottom;
  VoidCallback? onClearComposer;

  Future<void> loadUser() async {
    try {
      final me = await api<ApiService>((request) => request.fetchMe());
      setState(setState: () => user = me);
    } catch (_) {
      final auth = Auth.data();
      if (auth is Map) {
        setState(setState: () => user = User.fromJson(auth));
      }
    }
  }

  Future<void> loadConversations({String? keyword}) async {
    if (keyword != null) {
      conversationKeyword = keyword;
    }
    final kw = conversationKeyword.trim();
    setState(setState: () => loadingConversations = true);
    try {
      final result = await api<ApiService>(
        (request) => request.listConversations(
          keyword: kw.isEmpty ? null : kw,
        ),
      );
      setState(setState: () {
        conversations = result?.items ?? [];
      });
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => loadingConversations = false);
    }
  }

  Future<void> loadMessages(String conversationId) async {
    setState(setState: () => loadingMessages = true);
    try {
      final items = await api<ApiService>(
        (request) => request.listMessages(conversationId),
      );
      setState(setState: () => messages = items ?? []);
      onScrollToBottom?.call();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => loadingMessages = false);
    }
  }

  void newChat() {
    setState(setState: () {
      title = '菜包';
      activeConversationId = null;
      messages = [];
    });
    onClearComposer?.call();
  }

  Future<void> selectConversation(ChatConversation conversation) async {
    setState(setState: () {
      title = conversation.title?.isNotEmpty == true
          ? conversation.title!
          : '菜包';
      activeConversationId = conversation.id;
      messages = [];
    });
    if (conversation.id != null) {
      await loadMessages(conversation.id!);
    }
  }

  Future<void> deleteConversation(ChatConversation conversation) async {
    final id = conversation.id;
    if (id == null) return;
    try {
      await api<ApiService>((request) => request.deleteConversation(id));
      setState(setState: () {
        conversations = conversations.where((item) => item.id != id).toList();
        if (activeConversationId == id) {
          title = '菜包';
          activeConversationId = null;
          messages = [];
        }
      });
      if (activeConversationId == null) {
        onClearComposer?.call();
      }
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> submit(
    String text, {
    List<String> fileIds = const [],
    List<DriveFile> attachments = const [],
  }) async {
    final content = text.trim();
    if ((content.isEmpty && fileIds.isEmpty) || sending) return;

    setState(setState: () => sending = true);
    onClearComposer?.call();

    var conversationId = activeConversationId;
    try {
      if (conversationId == null) {
        final titleSource = content.isNotEmpty
            ? content
            : (attachments.isNotEmpty
                ? (attachments.first.name ?? '图片')
                : '新对话');
        final convTitle = titleSource.length > 64
            ? '${titleSource.substring(0, 64)}...'
            : titleSource;
        conversationId = await api<ApiService>(
          (request) => request.createConversation(title: convTitle),
        );
        if (conversationId == null || conversationId.isEmpty) {
          throw ApiException('创建会话失败');
        }
        setState(setState: () {
          activeConversationId = conversationId;
          title = titleSource;
        });
      }

      setState(setState: () {
        messages = ChatStreamHandler.appendPendingExchange(
          messages: messages,
          userContent: content.isNotEmpty ? content : '[附件]',
          attachments: attachments,
        );
      });
      onScrollToBottom?.call();

      await _streamClient.streamConversationChat(
        conversationId: conversationId,
        content: content,
        fileIds: fileIds.isEmpty ? null : fileIds,
        onEvent: (event) {
          if (ChatStreamHandler.isError(event)) {
            showToastSorry(description: event.msg ?? '生成失败');
            return;
          }
          final updated = ChatStreamHandler.applyEvent(
            messages: messages,
            event: event,
          );
          if (updated == null) return;
          setState(setState: () => messages = updated);
          if (event.type == 'delta') {
            onScrollToBottom?.call();
          }
        },
      );

      await loadConversations();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => sending = false);
    }
  }
}
