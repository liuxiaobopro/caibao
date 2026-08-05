import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao_todo_app/caibao_todo_app.dart';
import 'package:nylo_framework/nylo_framework.dart';

class TodoApiAdapter implements TodoApi {
  @override
  Future<List<TodoGroup>> listTodoGroups() async {
    return await api<ApiService>((r) => r.listTodoGroups()) ?? [];
  }

  @override
  Future<String> createTodoGroup(String name) async {
    return await api<ApiService>((r) => r.createTodoGroup(name));
  }

  @override
  Future<void> updateTodoGroup(String id, {required String name}) async {
    await api<ApiService>((r) => r.updateTodoGroup(id, name: name));
  }

  @override
  Future<void> deleteTodoGroup(String id) async {
    await api<ApiService>((r) => r.deleteTodoGroup(id));
  }

  @override
  Future<List<TodoItem>> listTodos(String groupId) async {
    return await api<ApiService>((r) => r.listTodos(groupId)) ?? [];
  }

  @override
  Future<String> createTodo({
    required String groupId,
    required String title,
  }) async {
    return await api<ApiService>(
      (r) => r.createTodo(groupId: groupId, title: title),
    );
  }

  @override
  Future<void> updateTodo(
    String id, {
    String? title,
    bool? done,
    String? groupId,
  }) async {
    await api<ApiService>(
      (r) => r.updateTodo(id, title: title, done: done, groupId: groupId),
    );
  }

  @override
  Future<void> deleteTodo(String id) async {
    await api<ApiService>((r) => r.deleteTodo(id));
  }
}
