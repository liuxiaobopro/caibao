import 'package:caibao/app/controllers/agent_chat_controller.dart';
import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/widgets/chat/assistant_message_body.dart';
import 'package:caibao/resources/widgets/chat/chat_composer.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AgentChatPage extends NyStatefulWidget<AgentChatController> {
  static RouteView path = ('/agents/chat', (_) => AgentChatPage());

  AgentChatPage({super.key}) : super(child: () => _AgentChatPageState());
}

class _AgentChatPageState extends NyPage<AgentChatPage> {
  AgentChatController get controller => widget.controller;

  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  get init => () async {
        controller.onScrollToBottom = _scrollToBottom;
        controller.onClearComposer = _composerController.clear;
        await controller.bootstrap(data());
      };

  @override
  bool get stateManaged => false;

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    final c = controller;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(c.title),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: '清空上下文',
            onPressed: c.clearContext,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: c.loading
                  ? const Center(child: CircularProgressIndicator())
                  : c.messages.isEmpty
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
                          itemCount: c.messages.length,
                          itemBuilder: (context, index) {
                            final message = c.messages[index];
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
                                    bottom: AppSpacing.x4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width * 0.78,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.userBubble,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                      bottomLeft: Radius.circular(18),
                                      bottomRight: Radius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    content,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: palette.onUserBubble,
                                      fontWeight: FontWeight.w400,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.x4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width * 0.88,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.assistantBubble,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: AssistantMessageBody(content: content),
                              ),
                            );
                          },
                        ),
            ),
            ChatComposer(
              controller: _composerController,
              onSubmit: c.sending ? null : c.submit,
            ),
          ],
        ),
      ),
    );
  }
}
