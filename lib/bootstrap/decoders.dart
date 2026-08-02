import 'package:caibao/app/models/chat_message.dart';
import 'package:caibao/app/models/chat_conversation.dart';
import 'package:caibao/app/controllers/home_controller.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_service.dart';

/* Model Decoders
|--------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models.
|
| Learn more https://nylo.dev/docs/7.x/decoders#model-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> modelDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data),

  List<User>: (data) =>
      List.from(data).map((json) => User.fromJson(json)).toList(),
  //
  User: (data) => User.fromJson(data),

  List<ChatConversation>: (data) => List.from(data).map((json) => ChatConversation.fromJson(json)).toList(),

  ChatConversation: (data) => ChatConversation.fromJson(data),

  List<ChatMessage>: (data) => List.from(data).map((json) => ChatMessage.fromJson(json)).toList(),

  ChatMessage: (data) => ChatMessage.fromJson(data),
};

/* API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
|
| Learn more https://nylo.dev/docs/7.x/decoders#api-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> apiDecoders = {
  ApiService: () => ApiService(),

  // ...
};

/* Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
|
| Learn more https://nylo.dev/docs/7.x/controllers
|-------------------------------------------------------------------------- */
final Map<Type, dynamic> controllers = {
  HomeController: () => HomeController(),

  // ...
};
