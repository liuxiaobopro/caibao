import 'package:caibao_theme/caibao_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'models.dart';
import 'todo_api.dart';

class AssistantPanel extends StatefulWidget {
  const AssistantPanel({
    super.key,
    required this.api,
    this.onMutated,
  });

  final TodoApi api;
  final Future<void> Function()? onMutated;

  @override
  State<AssistantPanel> createState() => _AssistantPanelState();
}

class _ChatMessage {
  _ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.pending = false,
  });

  final String id;
  final String role;
  String content;
  bool pending;
}

class _AssistantPanelState extends State<AssistantPanel> {
  bool _open = false;
  bool _streaming = false;
  String _error = '';
  final List<_ChatMessage> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  TodoStreamCancel? _cancel;

  @override
  void dispose() {
    _cancel?.call();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _submit() async {
    final text = _input.text.trim();
    if (text.isEmpty || _streaming) return;

    final history = _messages
        .map(
          (m) => TodoAssistantHistoryItem(role: m.role, content: m.content),
        )
        .toList();

    setState(() {
      _error = '';
      _streaming = true;
      _messages.addAll([
        _ChatMessage(
          id: 'u-${DateTime.now().microsecondsSinceEpoch}',
          role: 'user',
          content: text,
        ),
        _ChatMessage(
          id: 'a-${DateTime.now().microsecondsSinceEpoch}',
          role: 'assistant',
          content: '',
          pending: true,
        ),
      ]);
    });
    _input.clear();
    _scrollToBottom();

    var mutated = false;
    try {
      await widget.api.streamAssistant(
        content: text,
        history: history,
        bindCancel: (cancel) => _cancel = cancel,
        onEvent: (event) {
          if (!mounted) return;
          if (event.type == 'delta' && event.content != null) {
            setState(() {
              final last = _messages.isNotEmpty ? _messages.last : null;
              if (last?.role == 'assistant') {
                last!.content = '${last.content}${event.content}';
                last.pending = true;
              }
            });
            _scrollToBottom();
          }
          if (event.type == 'done') {
            mutated = event.mutated == true;
            setState(() {
              final last = _messages.isNotEmpty ? _messages.last : null;
              if (last?.role == 'assistant') {
                last!.content =
                    (event.content?.isNotEmpty == true)
                        ? event.content!
                        : last.content;
                last.pending = false;
              }
            });
          }
          if (event.type == 'error') {
            setState(() {
              _error = event.msg ?? '助手出错了';
              final last = _messages.isNotEmpty ? _messages.last : null;
              if (last?.role == 'assistant' && last!.pending) {
                last.content =
                    last.content.isNotEmpty
                        ? last.content
                        : (event.msg ?? '生成失败');
                last.pending = false;
              }
            });
          }
        },
      );
      if (mutated) {
        await widget.onMutated?.call();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        if (_messages.isNotEmpty &&
            _messages.last.role == 'assistant' &&
            _messages.last.pending) {
          _messages.removeLast();
        }
      });
    } finally {
      _cancel = null;
      if (mounted) setState(() => _streaming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final size = MediaQuery.sizeOf(context);
    final panelW = size.width < 400 ? size.width - 32 : 360.0;
    final panelH = (size.height - 120).clamp(280.0, 480.0);

    return Positioned(
      right: 18,
      bottom: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_open)
            Material(
              color: palette.card,
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: panelW,
                height: panelH,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 6, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '待办助手',
                                  style: TextStyle(
                                    fontSize: AppTypography.base,
                                    fontWeight: FontWeight.w700,
                                    color: palette.foreground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '用对话增删改查分组与待办',
                                  style: TextStyle(
                                    fontSize: AppTypography.xs,
                                    color: palette.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _open = false),
                            icon: Icon(
                              Icons.close,
                              color: palette.mutedForeground,
                              size: 20,
                            ),
                            tooltip: '关闭助手',
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: palette.muted),
                    Expanded(
                      child: _messages.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  '试试：「在买菜分组加一条番茄」或「列出所有分组」',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: AppTypography.sm,
                                    color: palette.mutedForeground,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(12),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final m = _messages[index];
                                final isUser = m.role == 'user';
                                return Align(
                                  alignment: isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    constraints: BoxConstraints(
                                      maxWidth: panelW * 0.92,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? palette.brandContainer
                                          : palette.assistantBubble,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isUser
                                            ? palette.brand.withValues(
                                                alpha: 0.3,
                                              )
                                            : palette.muted,
                                      ),
                                    ),
                                    child: isUser
                                        ? Text(
                                            m.content,
                                            style: TextStyle(
                                              fontSize: AppTypography.sm,
                                              color: palette.brandOnContainer,
                                              height: 1.45,
                                            ),
                                          )
                                        : m.content.isEmpty && m.pending
                                            ? Text(
                                                '…',
                                                style: TextStyle(
                                                  color:
                                                      palette.mutedForeground,
                                                ),
                                              )
                                            : MarkdownBody(
                                                data: m.content,
                                                styleSheet:
                                                    MarkdownStyleSheet.fromTheme(
                                                  Theme.of(context),
                                                ).copyWith(
                                                  p: TextStyle(
                                                    fontSize: AppTypography.sm,
                                                    color: palette.foreground,
                                                    height: 1.45,
                                                  ),
                                                ),
                                              ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: palette.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: palette.danger.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            _error,
                            style: TextStyle(
                              fontSize: AppTypography.xs,
                              color: palette.danger,
                            ),
                          ),
                        ),
                      ),
                    Divider(height: 1, color: palette.muted),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                              controller: _input,
                              enabled: !_streaming,
                              maxLength: 2000,
                              decoration: InputDecoration(
                                hintText: '跟助手说你想做什么…',
                                counterText: '',
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _submit(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _streaming ||
                                    _input.text.trim().isEmpty
                                ? null
                                : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.brand,
                              foregroundColor: palette.brandOn,
                              minimumSize: const Size(64, 42),
                            ),
                            child: _streaming
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: palette.brandOn,
                                    ),
                                  )
                                : const Text('发送'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_open) const SizedBox(height: 12),
          if (!_open)
            FloatingActionButton(
              onPressed: () => setState(() => _open = true),
              backgroundColor: palette.brand,
              foregroundColor: palette.brandOn,
              tooltip: '打开助手',
              child: const Icon(Icons.smart_toy_outlined, size: 26),
            ),
        ],
      ),
    );
  }
}
