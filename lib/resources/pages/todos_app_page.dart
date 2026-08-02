import 'package:caibao/app/models/todo.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class TodosAppPage extends NyStatefulWidget {
  static RouteView path = ('/apps/todos', (_) => TodosAppPage());

  TodosAppPage({super.key}) : super(child: () => _TodosAppPageState());
}

class _TodosAppPageState extends NyPage<TodosAppPage> {
  List<TodoGroup> _groups = [];
  List<TodoItem> _todos = [];
  String? _activeGroupId;
  bool _loading = true;
  bool _loadingTodos = false;
  final TextEditingController _todoController = TextEditingController();

  @override
  get init => () async {
        await _loadGroups();
      };

  @override
  bool get stateManaged => false;

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    try {
      final groups = await api<ApiService>((r) => r.listTodoGroups()) ?? [];
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _activeGroupId = groups.isNotEmpty ? groups.first.id : null;
      });
      if (_activeGroupId != null) {
        await _loadTodos(_activeGroupId!);
      }
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadTodos(String groupId) async {
    setState(() => _loadingTodos = true);
    try {
      final items = await api<ApiService>((r) => r.listTodos(groupId));
      if (!mounted) return;
      setState(() => _todos = items ?? []);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
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
      final id = await api<ApiService>((r) => r.createTodoGroup(name));
      await _loadGroups();
      if (id != null && mounted) {
        setState(() => _activeGroupId = id);
        await _loadTodos(id);
      }
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> _addTodo() async {
    final title = _todoController.text.trim();
    if (title.isEmpty || _activeGroupId == null) return;
    try {
      await api<ApiService>(
        (r) => r.createTodo(groupId: _activeGroupId!, title: title),
      );
      _todoController.clear();
      await _loadTodos(_activeGroupId!);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> _toggleTodo(TodoItem item) async {
    if (item.id == null) return;
    try {
      await api<ApiService>(
        (r) => r.updateTodo(item.id!, done: !item.done),
      );
      await _loadTodos(_activeGroupId!);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> _deleteTodo(TodoItem item) async {
    if (item.id == null) return;
    try {
      await api<ApiService>((r) => r.deleteTodo(item.id!));
      await _loadTodos(_activeGroupId!);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final arg = data();
    final title = arg is Map && arg['name']?.toString().isNotEmpty == true
        ? arg['name'].toString()
        : '待办清单';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _createGroup,
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: '新建分组',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_groups.isNotEmpty)
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
                      itemCount: _groups.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.x2),
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
                const SizedBox(height: AppSpacing.x2),
                Expanded(
                  child: _groups.isEmpty
                      ? Center(
                          child: Text(
                            '暂无分组，点击右上角新建',
                            style: TextStyle(color: palette.mutedForeground),
                          ),
                        )
                      : _loadingTodos
                          ? const Center(child: CircularProgressIndicator())
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
                                  padding: const EdgeInsets.all(AppSpacing.x4),
                                  itemCount: _todos.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: AppSpacing.x2),
                                  itemBuilder: (context, index) {
                                    final item = _todos[index];
                                    return Material(
                                      color: const Color(0xFFF8F8F8),
                                      borderRadius: AppRadius.x2lAll,
                                      child: ListTile(
                                        leading: Checkbox(
                                          value: item.done,
                                          onChanged: (_) => _toggleTodo(item),
                                        ),
                                        title: Text(
                                          item.title ?? '',
                                          style: TextStyle(
                                            fontSize: AppTypography.base,
                                            decoration: item.done
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: item.done
                                                ? palette.mutedForeground
                                                : palette.foreground,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          onPressed: () => _deleteTodo(item),
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
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.x4,
                        AppSpacing.x2,
                        AppSpacing.x4,
                        AppSpacing.x3,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _todoController,
                              decoration: InputDecoration(
                                hintText: '添加待办',
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.x2lAll,
                                ),
                                isDense: true,
                              ),
                              onSubmitted: (_) => _addTodo(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x2),
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
    );
  }
}
