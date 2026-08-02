import 'package:caibao/app/controllers/home_controller.dart';
import 'package:caibao/app/models/agent.dart';
import 'package:caibao/app/models/chat_conversation.dart';
import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/app/models/drive_file.dart';
import 'package:caibao/app/models/llm_model.dart';
import 'package:caibao/app/models/mini_app.dart';
import 'package:caibao/app/models/storage_config.dart';
import 'package:caibao/app/models/todo.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_service.dart';

final Map<Type, dynamic> modelDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data),

  List<User>: (data) =>
      List.from(data).map((json) => User.fromJson(json)).toList(),
  User: (data) => User.fromJson(data),

  List<ChatConversation>: (data) =>
      List.from(data).map((json) => ChatConversation.fromJson(json)).toList(),
  ChatConversation: (data) => ChatConversation.fromJson(data),

  List<ChatMessage>: (data) =>
      List.from(data).map((json) => ChatMessage.fromJson(json)).toList(),
  ChatMessage: (data) => ChatMessage.fromJson(data),

  List<Agent>: (data) =>
      List.from(data).map((json) => Agent.fromJson(json)).toList(),
  Agent: (data) => Agent.fromJson(data),

  List<DriveFile>: (data) =>
      List.from(data).map((json) => DriveFile.fromJson(json)).toList(),
  DriveFile: (data) => DriveFile.fromJson(data),

  List<MiniApp>: (data) =>
      List.from(data).map((json) => MiniApp.fromJson(json)).toList(),
  MiniApp: (data) => MiniApp.fromJson(data),

  List<TodoGroup>: (data) =>
      List.from(data).map((json) => TodoGroup.fromJson(json)).toList(),
  TodoGroup: (data) => TodoGroup.fromJson(data),

  List<TodoItem>: (data) =>
      List.from(data).map((json) => TodoItem.fromJson(json)).toList(),
  TodoItem: (data) => TodoItem.fromJson(data),

  List<S3StorageConfig>: (data) =>
      List.from(data).map((json) => S3StorageConfig.fromJson(json)).toList(),
  S3StorageConfig: (data) => S3StorageConfig.fromJson(data),

  List<LlmModel>: (data) =>
      List.from(data).map((json) => LlmModel.fromJson(json)).toList(),
  LlmModel: (data) => LlmModel.fromJson(data),
};

final Map<Type, dynamic> apiDecoders = {
  ApiService: () => ApiService(),
};

final Map<Type, dynamic> controllers = {
  HomeController: () => HomeController(),
};
