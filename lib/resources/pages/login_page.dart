import 'package:caibao/app/controllers/login_controller.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LoginPage extends NyStatefulWidget<LoginController> {
  static RouteView path = ('/login', (_) => LoginPage());

  LoginPage({super.key}) : super(child: () => _LoginPageState());
}

class _LoginPageState extends NyPage<LoginPage> {
  LoginController get controller => widget.controller;

  final TextEditingController _usernameController =
      TextEditingController(text: 'app');
  final TextEditingController _passwordController =
      TextEditingController(text: 'app123');

  @override
  get init => () async {
        await controller.redirectIfAuthenticated();
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
    await controller.submit(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final submitting = controller.submitting;

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
                  onPressed: submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.brand,
                    foregroundColor: palette.brandOn,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.x2lAll,
                    ),
                  ),
                  child: submitting
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
