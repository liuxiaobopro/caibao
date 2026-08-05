import 'package:caibao/app/controllers/chat_controller.dart';
import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:caibao/resources/widgets/chat/assistant_message_body.dart';
import 'package:caibao/resources/widgets/chat/chat_app_bar.dart';
import 'package:caibao/resources/widgets/chat/chat_composer.dart';
import 'package:caibao/resources/widgets/chat/chat_history_drawer.dart';
import 'package:caibao/resources/widgets/chat/chat_quick_actions.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ChatPage extends NyStatefulWidget<ChatController> {
  static RouteView path = ('/chat', (_) => ChatPage());

  ChatPage({super.key}) : super(child: () => _ChatPageState());
}

class _ChatPageState extends NyPage<ChatPage> {
  ChatController get controller => widget.controller;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  get init => () async {
        _scrollController.addListener(_onScroll);
        controller.onScrollToBottom = _scrollToBottom;
        controller.onClearComposer = _composerController.clear;
        await controller.loadUser();
        await controller.loadConversations();
      };

  @override
  bool get stateManaged => false;

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final show = pos.maxScrollExtent - pos.pixels > 80;
    if (show != _showScrollToBottom) {
      setState(() => _showScrollToBottom = show);
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _navigateFromDrawer(dynamic route) async {
    await routeTo(route);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scaffoldKey.currentState?.openDrawer();
    });
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
      key: _scaffoldKey,
      backgroundColor: palette.background,
      drawer: ChatHistoryDrawer(
        user: c.user,
        conversations: c.conversations,
        activeConversationId: c.activeConversationId,
        loading: c.loadingConversations,
        onNewChat: c.newChat,
        onSelectConversation: c.selectConversation,
        onDeleteConversation: c.deleteConversation,
        onRefresh: c.loadConversations,
        onNavigate: _navigateFromDrawer,
      ),
      appBar: ChatAppBar(
        onMenuTap: _openDrawer,
        title: c.title,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  c.loadingMessages
                      ? const Center(child: CircularProgressIndicator())
                      : c.messages.isEmpty
                          ? Center(
                              child: Text(
                                c.activeConversationId == null
                                    ? '有什么我能帮你的吗？'
                                    : '暂无消息',
                                style: TextStyle(
                                  color: c.activeConversationId == null
                                      ? palette.foreground
                                      : palette.mutedForeground,
                                  fontSize: c.activeConversationId == null
                                      ? AppTypography.x3l
                                      : AppTypography.base,
                                  fontWeight: c.activeConversationId == null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  letterSpacing: -0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.x4,
                                AppSpacing.x4,
                                AppSpacing.x4,
                                AppSpacing.x5,
                              ),
                              itemCount: c.messages.length,
                              itemBuilder: (context, index) {
                                final message = c.messages[index];
                                final isUser =
                                    message.role == ChatMessageRole.user;
                                final content =
                                    message.content?.isNotEmpty == true
                                        ? message.content!
                                        : (message.status == 'streaming'
                                            ? '...'
                                            : '');

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
                                            MediaQuery.sizeOf(context).width *
                                                0.78,
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
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
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
                                          MediaQuery.sizeOf(context).width *
                                              0.88,
                                    ),
                                    decoration: BoxDecoration(
                                      color: palette.assistantBubble,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: AssistantMessageBody(
                                      content: content,
                                    ),
                                  ),
                                );
                              },
                            ),
                  if (_showScrollToBottom)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: Center(
                        child: Material(
                          color: palette.card,
                          elevation: 1,
                          shadowColor: const Color(0x33000000),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _scrollToBottom,
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: palette.foreground,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ChatQuickActions(
              onTap: (action) {
                const prompt = '创建智能体: ';
                _composerController.text = prompt;
                _composerController.selection = TextSelection.fromPosition(
                  const TextPosition(offset: prompt.length),
                );
              },
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
