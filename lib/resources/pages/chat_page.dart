import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:caibao/app/models/chat_conversation.dart';
import 'package:caibao/resources/widgets/chat/chat_app_bar.dart';
import 'package:caibao/resources/widgets/chat/chat_composer.dart';
import 'package:caibao/resources/widgets/chat/chat_history_drawer.dart';
import 'package:caibao/resources/widgets/chat/chat_quick_actions.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';

class ChatPage extends NyStatefulWidget {
  static RouteView path = ('/chat', (_) => ChatPage());

  ChatPage({super.key}) : super(child: () => _ChatPageState());
}

class _ChatPageState extends NyPage<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _composerController = TextEditingController();

  String _title = '新对话';
  String? _activeConversationId;

  @override
  get init => () {};

  @override
  bool get stateManaged => false;

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onNewChat() {
    setState(() {
      _title = '新对话';
      _activeConversationId = null;
      _composerController.clear();
    });
  }

  void _onSelectConversation(ChatConversation conversation) {
    setState(() {
      _title = conversation.title ?? '新对话';
      _activeConversationId = conversation.id;
    });
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: ChatHistoryDrawer(
        onNewChat: _onNewChat,
        onSelectConversation: _onSelectConversation,
      ),
      appBar: ChatAppBar(
        onMenuTap: _openDrawer,
        title: _title,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _activeConversationId == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(AppSpacing.x6),
                        child: Text(
                          _title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                      ),
              ),
            ),
            ChatQuickActions(
              onTap: (_) {},
            ),
            const SizedBox(height: AppSpacing.x3),
            ChatComposer(controller: _composerController),
          ],
        ),
      ),
    );
  }
}
