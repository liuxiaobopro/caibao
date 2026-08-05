import 'package:caibao/app/analytics/analytics.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/chat_page.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LoginPage extends NyStatefulWidget {
  static RouteView path = ('/login', (_) => LoginPage());

  LoginPage({super.key}) : super(child: () => _LoginPageState());
}

class _LoginPageState extends NyPage<LoginPage> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'app');
  final TextEditingController _passwordController =
      TextEditingController(text: 'app123');
  bool _submitting = false;

  @override
  get init => () async {
        if (await Auth.isAuthenticated()) {
          await routeTo(ChatPage.path, navigationType: NavigationType.pushAndForgetAll);
        }
      };

  @override
  bool get stateManaged => false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      showToastSorry(description: '请输入用户名和密码');
      return;
    }

    setState(() => _submitting = true);
    try {
      final loginResp = await api<ApiService>(
        (request) => request.login(username, password),
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

      await routeTo(ChatPage.path, navigationType: NavigationType.pushAndForgetAll);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.x10),
              Text(
                '菜包',
                style: TextStyle(
                  fontSize: AppTypography.x3l,
                  fontWeight: FontWeight.w700,
                  color: palette.foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(
                '登录后继续对话',
                style: TextStyle(
                  fontSize: AppTypography.base,
                  color: palette.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.x8),
              TextField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.x2lAll,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x4),
              TextField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.x2lAll,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x6),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.brand,
                    foregroundColor: palette.brandOn,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.x2lAll,
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
