import 'package:caibao/app/controllers/controller.dart';
import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/app/networking/chat_stream_client.dart';
import 'package:caibao/app/services/chat_stream_handler.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AgentChatController extends Controller {
  final ChatStreamClient _streamClient = ChatStreamClient();

  String? agentId;
  String title = '智能体对话';
  List<ChatMessage> messages = [];
  bool loading = true;
  bool sending = false;

  VoidCallback? onScrollToBottom;
  VoidCallback? onClearComposer;

  Future<void> bootstrap(dynamic arg) async {
    if (arg is Map) {
      agentId = arg['id']?.toString();
      title = arg['name']?.toString().isNotEmpty == true
          ? arg['name'].toString()
          : '智能体对话';
    }
    if (agentId == null || agentId!.isEmpty) {
      setState(setState: () => loading = false);
      return;
    }
    try {
      final agent = await api<ApiService>((r) => r.getAgent(agentId!));
      final msgs =
          await api<ApiService>((r) => r.listAgentMessages(agentId!));
      setState(setState: () {
        title = agent?.name?.isNotEmpty == true ? agent!.name! : title;
        messages = msgs ?? [];
      });
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => loading = false);
    }
  }

  Future<void> clearContext() async {
    if (agentId == null) return;
    try {
      await api<ApiService>((r) => r.clearAgentContext(agentId!));
      setState(setState: () => messages = []);
      showToastSuccess(description: '已清空上下文');
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> submit(String text) async {
    final content = text.trim();
    if (content.isEmpty || sending || agentId == null) return;

    setState(setState: () => sending = true);
    onClearComposer?.call();
    setState(setState: () {
      messages = ChatStreamHandler.appendPendingExchange(
        messages: messages,
        userContent: content,
      );
    });
    onScrollToBottom?.call();

    try {
      await _streamClient.streamAgentChat(
        agentId: agentId!,
        content: content,
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
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => sending = false);
    }
  }
}
