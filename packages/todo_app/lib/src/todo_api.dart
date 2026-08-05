import 'models.dart';

abstract class TodoApi {
  Future<List<TodoGroup>> listTodoGroups();

  Future<String> createTodoGroup(String name);

  Future<void> updateTodoGroup(String id, {required String name});

  Future<void> deleteTodoGroup(String id);

  Future<List<TodoItem>> listTodos(String groupId);

  Future<String> createTodo({
    required String groupId,
    required String title,
  });

  Future<void> updateTodo(
    String id, {
    String? title,
    bool? done,
    String? groupId,
  });

  Future<void> deleteTodo(String id);
}
