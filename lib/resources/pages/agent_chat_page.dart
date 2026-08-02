import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/app/networking/chat_stream_client.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:caibao/resources/widgets/chat/assistant_message_body.dart';
import 'package:caibao/resources/widgets/chat/chat_composer.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AgentChatPage extends NyStatefulWidget {
  static RouteView path = ('/agents/chat', (_) => AgentChatPage());

  AgentChatPage({super.key}) : super(child: () => _AgentChatPageState());
}

class _AgentChatPageState extends NyPage<AgentChatPage> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatStreamClient _streamClient = ChatStreamClient();

  String? _agentId;
  String _title = '智能体对话';
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  get init => () async {
        final arg = data();
        if (arg is Map) {
          _agentId = arg['id']?.toString();
          _title = arg['name']?.toString().isNotEmpty == true
              ? arg['name'].toString()
              : '智能体对话';
        }
        if (_agentId == null || _agentId!.isEmpty) {
          setState(() => _loading = false);
          return;
        }
        try {
          final agent = await api<ApiService>((r) => r.getAgent(_agentId!));
          final msgs =
              await api<ApiService>((r) => r.listAgentMessages(_agentId!));
          if (!mounted) return;
          setState(() {
            _title = agent?.name?.isNotEmpty == true ? agent!.name! : _title;
            _messages = msgs ?? [];
          });
        } on ApiException catch (e) {
          showToastSorry(description: e.message);
        } catch (e) {
          showToastSorry(description: e.toString());
        } finally {
          if (mounted) setState(() => _loading = false);
        }
      };

  @override
  bool get stateManaged => false;

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _clearContext() async {
    if (_agentId == null) return;
    try {
      await api<ApiService>((r) => r.clearAgentContext(_agentId!));
      if (!mounted) return;
      setState(() => _messages = []);
      showToastSuccess(description: '已清空上下文');
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> _onSubmit(String text) async {
    final content = text.trim();
    if (content.isEmpty || _sending || _agentId == null) return;

    setState(() => _sending = true);
    _composerController.clear();
    setState(() {
      _messages = [
        ..._messages,
        ChatMessage(
          role: ChatMessageRole.user,
          content: content,
          createdAt: DateTime.now(),
        ),
        ChatMessage(
          role: ChatMessageRole.assistant,
          content: '',
          createdAt: DateTime.now(),
          status: 'streaming',
        ),
      ];
    });
    _scrollToBottom();

    try {
      await _streamClient.streamAgentChat(
        agentId: _agentId!,
        content: content,
        onEvent: (event) {
          if (!mounted) return;
          if (event.type == 'delta' && event.content != null) {
            setState(() {
              if (_messages.isEmpty) return;
              final last = _messages.last;
              if (last.role != ChatMessageRole.assistant) return;
              _messages[_messages.length - 1] = ChatMessage(
                id: event.messageId ?? last.id,
                role: ChatMessageRole.assistant,
                content: '${last.content ?? ''}${event.content}',
                createdAt: last.createdAt,
                status: 'streaming',
              );
            });
            _scrollToBottom();
          } else if (event.type == 'done') {
            setState(() {
              if (_messages.isEmpty) return;
              final last = _messages.last;
              if (last.role != ChatMessageRole.assistant) return;
              _messages[_messages.length - 1] = ChatMessage(
                id: event.messageId ?? last.id,
                role: ChatMessageRole.assistant,
                content: last.content,
                createdAt: last.createdAt,
                status: 'done',
              );
            });
          } else if (event.type == 'error') {
            showToastSorry(description: event.msg ?? '生成失败');
          }
        },
      );
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: '清空上下文',
            onPressed: _clearContext,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(
                          child: Text(
                            '开始与智能体对话',
                            style: TextStyle(color: palette.mutedForeground),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.x4,
                            vertical: AppSpacing.x3,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isUser =
                                message.role == ChatMessageRole.user;
                            final content = message.content?.isNotEmpty == true
                                ? message.content!
                                : (message.status == 'streaming' ? '...' : '');

                            if (isUser) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.x3,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.x4,
                                    vertical: AppSpacing.x3,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width * 0.78,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.userBubble,
                                    borderRadius: AppRadius.x2lAll,
                                  ),
                                  child: Text(
                                    content,
                                    style: TextStyle(
                                      fontSize: AppTypography.base,
                                      color: palette.brandOn,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.x3,
                              ),
                              child: AssistantMessageBody(content: content),
                            );
                          },
                        ),
            ),
            ChatComposer(
              controller: _composerController,
              onSubmit: _sending ? null : _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
