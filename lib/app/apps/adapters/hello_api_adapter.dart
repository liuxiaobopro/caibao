import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao_hello_app/caibao_hello_app.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HelloApiAdapter implements HelloApi {
  @override
  Future<Map<String, dynamic>> fetchMe() async {
    final user = await api<ApiService>((r) => r.fetchMe());
    return user.toJson();
  }
}
