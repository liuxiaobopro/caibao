import 'package:caibao_theme/caibao_theme.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'todo_api.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key, required this.api});

  final TodoApi api;

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<TodoGroup> _groups = [];
  List<TodoItem> _todos = [];
  String? _activeGroupId;
  bool _loading = true;
  bool _loadingTodos = false;
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    try {
      final groups = await widget.api.listTodoGroups();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _activeGroupId = groups.isNotEmpty ? groups.first.id : null;
      });
      if (_activeGroupId != null) {
        await _loadTodos(_activeGroupId!);
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadTodos(String groupId) async {
    setState(() => _loadingTodos = true);
    try {
      final items = await widget.api.listTodos(groupId);
      if (!mounted) return;
      setState(() => _todos = items);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loadingTodos = false);
    }
  }

  Future<void> _createGroup() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建分组'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '分组名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.isEmpty) return;
    try {
      final id = await widget.api.createTodoGroup(name);
      await _loadGroups();
      if (mounted) {
        setState(() => _activeGroupId = id);
        await _loadTodos(id);
      }
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _addTodo() async {
    final title = _todoController.text.trim();
    if (title.isEmpty || _activeGroupId == null) return;
    try {
      await widget.api.createTodo(groupId: _activeGroupId!, title: title);
      _todoController.clear();
      await _loadTodos(_activeGroupId!);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _toggleTodo(TodoItem item) async {
    if (item.id == null) return;
    try {
      await widget.api.updateTodo(item.id!, done: !item.done);
      await _loadTodos(_activeGroupId!);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _deleteTodo(TodoItem item) async {
    if (item.id == null) return;
    try {
      await widget.api.deleteTodo(item.id!);
      await _loadTodos(_activeGroupId!);
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: _createGroup,
            icon: Icon(
              Icons.create_new_folder_outlined,
              color: palette.foreground,
            ),
            tooltip: '新建分组',
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (_groups.isNotEmpty)
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _groups.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            final selected = group.id == _activeGroupId;
                            return ChoiceChip(
                              label: Text(group.name ?? '未命名'),
                              selected: selected,
                              onSelected: (_) async {
                                setState(() => _activeGroupId = group.id);
                                if (group.id != null) {
                                  await _loadTodos(group.id!);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _groups.isEmpty
                          ? Center(
                              child: Text(
                                '暂无分组，点击右上角新建',
                                style: TextStyle(
                                  color: palette.mutedForeground,
                                ),
                              ),
                            )
                          : _loadingTodos
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : _todos.isEmpty
                                  ? Center(
                                      child: Text(
                                        '暂无待办',
                                        style: TextStyle(
                                          color: palette.mutedForeground,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _todos.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final item = _todos[index];
                                        return Material(
                                          color: palette.secondary,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: ListTile(
                                            leading: Checkbox(
                                              value: item.done,
                                              onChanged: (_) =>
                                                  _toggleTodo(item),
                                            ),
                                            title: Text(
                                              item.title ?? '',
                                              style: TextStyle(
                                                decoration: item.done
                                                    ? TextDecoration
                                                        .lineThrough
                                                    : null,
                                                color: item.done
                                                    ? palette.mutedForeground
                                                    : palette.foreground,
                                              ),
                                            ),
                                            trailing: IconButton(
                                              onPressed: () =>
                                                  _deleteTodo(item),
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: palette.mutedForeground,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                    ),
                    if (_activeGroupId != null)
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _todoController,
                                  decoration: InputDecoration(
                                    hintText: '添加待办',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) => _addTodo(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: _addTodo,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
