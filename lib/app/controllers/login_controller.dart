import 'package:caibao/app/analytics/analytics.dart';
import 'package:caibao/app/controllers/controller.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/resources/pages/chat_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LoginController extends Controller {
  bool submitting = false;

  Future<void> redirectIfAuthenticated() async {
    if (await Auth.isAuthenticated()) {
      await routeTo(
        ChatPage.path,
        navigationType: NavigationType.pushAndForgetAll,
      );
    }
  }

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    final user = username.trim();
    if (user.isEmpty || password.isEmpty) {
      showToastSorry(description: '请输入用户名和密码');
      return;
    }

    setState(setState: () => submitting = true);
    try {
      final loginResp = await api<ApiService>(
        (request) => request.login(user, password),
      );
      final token = loginResp?['token']?.toString();
      if (token == null || token.isEmpty) {
        throw ApiException('登录失败');
      }

      await Auth.authenticate(data: {'token': token});
      final me = await api<ApiService>((request) => request.fetchMe());
      await Auth.authenticate(
        data: {
          'token': token,
          'id': me?.id,
          'username': me?.username,
          'email': me?.email,
          'nickname': me?.nickname,
          'avatar_url': me?.avatarUrl,
        },
      );

      Analytics.instance.track('login', page: '/login');
      await Analytics.instance.flush();

      await routeTo(
        ChatPage.path,
        navigationType: NavigationType.pushAndForgetAll,
      );
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => submitting = false);
    }
  }
}
