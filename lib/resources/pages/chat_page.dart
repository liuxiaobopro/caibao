import 'package:caibao/app/models/chat_conversation.dart';
import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/app/networking/chat_stream_client.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:caibao/app/utils/message_segments.dart';
import 'package:caibao/resources/widgets/chat/chat_app_bar.dart';
import 'package:caibao/resources/widgets/chat/chat_composer.dart';
import 'package:caibao/resources/widgets/chat/chat_history_drawer.dart';
import 'package:caibao/resources/widgets/chat/chat_quick_actions.dart';
import 'package:caibao/resources/widgets/chat/thinking_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ChatPage extends NyStatefulWidget {
  static RouteView path = ('/chat', (_) => ChatPage());

  ChatPage({super.key}) : super(child: () => _ChatPageState());
}

class _ChatPageState extends NyPage<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatStreamClient _streamClient = ChatStreamClient();

  String _title = '菜包';
  String? _activeConversationId;
  List<ChatConversation> _conversations = [];
  List<ChatMessage> _messages = [];
  User? _user;
  bool _loadingConversations = false;
  bool _loadingMessages = false;
  bool _sending = false;
  bool _showScrollToBottom = false;

  @override
  get init => () async {
        _scrollController.addListener(_onScroll);
        await _loadUser();
        await _loadConversations();
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

  Future<void> _loadUser() async {
    try {
      final me = await api<ApiService>((request) => request.fetchMe());
      if (!mounted) return;
      setState(() => _user = me);
    } catch (_) {
      final auth = Auth.data();
      if (auth is Map && mounted) {
        setState(() => _user = User.fromJson(auth));
      }
    }
  }

  Future<void> _loadConversations() async {
    setState(() => _loadingConversations = true);
    try {
      final result = await api<ApiService>(
        (request) => request.listConversations(),
      );
      if (!mounted) return;
      setState(() {
        _conversations = result?.items ?? [];
      });
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      if (mounted) setState(() => _loadingConversations = false);
    }
  }

  Future<void> _loadMessages(String conversationId) async {
    setState(() => _loadingMessages = true);
    try {
      final items = await api<ApiService>(
        (request) => request.listMessages(conversationId),
      );
      if (!mounted) return;
      setState(() => _messages = items ?? []);
      _scrollToBottom();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      if (mounted) setState(() => _loadingMessages = false);
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

  void _onNewChat() {
    setState(() {
      _title = '菜包';
      _activeConversationId = null;
      _messages = [];
      _composerController.clear();
    });
  }

  Future<void> _onSelectConversation(ChatConversation conversation) async {
    setState(() {
      _title = conversation.title?.isNotEmpty == true
          ? conversation.title!
          : '菜包';
      _activeConversationId = conversation.id;
      _messages = [];
    });
    if (conversation.id != null) {
      await _loadMessages(conversation.id!);
    }
  }

  Future<void> _onDeleteConversation(ChatConversation conversation) async {
    final id = conversation.id;
    if (id == null) return;
    try {
      await api<ApiService>((request) => request.deleteConversation(id));
      if (!mounted) return;
      setState(() {
        _conversations =
            _conversations.where((item) => item.id != id).toList();
        if (_activeConversationId == id) {
          _onNewChat();
        }
      });
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> _onSubmit(String text) async {
    final content = text.trim();
    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);
    _composerController.clear();

    var conversationId = _activeConversationId;
    try {
      if (conversationId == null) {
        final title =
            content.length > 64 ? '${content.substring(0, 64)}...' : content;
        conversationId = await api<ApiService>(
          (request) => request.createConversation(title: title),
        );
        if (conversationId == null || conversationId.isEmpty) {
          throw ApiException('创建会话失败');
        }
        setState(() {
          _activeConversationId = conversationId;
          _title = content;
        });
      }

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

      await _streamClient.streamConversationChat(
        conversationId: conversationId,
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

      await _loadConversations();
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
      key: _scaffoldKey,
      backgroundColor: palette.background,
      drawer: ChatHistoryDrawer(
        user: _user,
        conversations: _conversations,
        activeConversationId: _activeConversationId,
        loading: _loadingConversations,
        onNewChat: _onNewChat,
        onSelectConversation: _onSelectConversation,
        onDeleteConversation: _onDeleteConversation,
        onRefresh: _loadConversations,
        onNavigate: _navigateFromDrawer,
      ),
      appBar: ChatAppBar(
        onMenuTap: _openDrawer,
        title: _title,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _loadingMessages
                      ? const Center(child: CircularProgressIndicator())
                      : _messages.isEmpty
                          ? Center(
                              child: Text(
                                _activeConversationId == null ? '' : '暂无消息',
                                style: TextStyle(
                                  color: palette.mutedForeground,
                                  fontSize: AppTypography.base,
                                ),
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
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
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

                                final segments = parseMessageSegments(content);
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        for (final segment in segments)
                                          if (segment is ThinkingSegment)
                                            ThinkingBlock(
                                              text: segment.text,
                                              streaming: segment.streaming,
                                            )
                                          else if (segment is TextSegment &&
                                              segment.text.trim().isNotEmpty)
                                            MarkdownBody(
                                              data: segment.text,
                                              selectable: true,
                                              styleSheet: MarkdownStyleSheet
                                                      .fromTheme(
                                                Theme.of(context),
                                              )
                                                  .copyWith(
                                                p: TextStyle(
                                                  fontSize: 16,
                                                  color: palette.foreground,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.55,
                                                ),
                                                strong: TextStyle(
                                                  fontSize: 16,
                                                  color: palette.foreground,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.55,
                                                ),
                                                listBullet: TextStyle(
                                                  fontSize: 16,
                                                  color: palette.foreground,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.55,
                                                ),
                                              ),
                                            ),
                                      ],
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
                _composerController.text = action.label;
                _composerController.selection = TextSelection.fromPosition(
                  TextPosition(offset: action.label.length),
                );
              },
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
