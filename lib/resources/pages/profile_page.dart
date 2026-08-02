import 'package:caibao/app/events/logout_event.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/app/utils/theme_preference.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/llm_models_page.dart';
import 'package:caibao/resources/pages/storage_configs_page.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProfilePage extends NyStatefulWidget {
  static RouteView path = ('/profile', (_) => ProfilePage());

  ProfilePage({super.key}) : super(child: () => _ProfilePageState());
}

class _ProfilePageState extends NyPage<ProfilePage> {
  static const Color _bg = Color(0xFFF5F5F5);

  User? _user;
  String _themeMode = themeModeSystem;
  bool _loading = true;

  @override
  get init => () async {
        _themeMode = await ThemePreference.read();
        await _loadUser();
      };

  @override
  bool get stateManaged => false;

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    try {
      final me = await api<ApiService>((request) => request.fetchMe());
      if (!mounted) return;
      setState(() => _user = me);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
      final auth = Auth.data();
      if (auth is Map && mounted) {
        setState(() => _user = User.fromJson(auth));
      }
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openThemeSheet() async {
    final current = await ThemePreference.read();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in [
                (themeModeLight, '明亮'),
                (themeModeDark, '暗黑'),
                (themeModeSystem, '系统'),
              ])
                ListTile(
                  title: Text(option.$2),
                  trailing: current == option.$1
                      ? Icon(Icons.check, color: context.palette.brand)
                      : null,
                  onTap: () async {
                    await ThemePreference.apply(context, option.$1);
                    if (mounted) setState(() => _themeMode = option.$1);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('退出', style: TextStyle(color: context.palette.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await event<LogoutEvent>();
    }
  }

  String get _themeLabel {
    switch (_themeMode) {
      case themeModeLight:
        return '明亮';
      case themeModeDark:
        return '暗黑';
      default:
        return '系统';
    }
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final nickname = _user?.displayName ?? '用户';
    final initial = nickname.isNotEmpty ? nickname.characters.first : '用';
    final avatarUrl = _user?.avatarUrl;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4,
                AppSpacing.x2,
                AppSpacing.x4,
                AppSpacing.x8,
              ),
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: palette.brandContainer,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? null
                          : Text(
                              initial,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: palette.brandDark,
                              ),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nickname,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: palette.foreground,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 22,
                          color: palette.mutedForeground,
                        ),
                      ],
                    ),
                    if (_user?.caibaoId.isNotEmpty == true) ...[
                      const SizedBox(height: AppSpacing.x1),
                      Text(
                        '菜包号: ${_user!.caibaoId}',
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: palette.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.x6),
                _MenuCard(
                  children: [
                    _MenuTile(
                      label: 'S3 存储设置',
                      icon: Icons.cloud_outlined,
                      iconColor: const Color(0xFF3B82F6),
                      onTap: () => routeTo(StorageConfigsPage.path),
                    ),
                    _MenuTile(
                      label: '模型配置',
                      icon: Icons.smart_toy_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () => routeTo(LlmModelsPage.path),
                    ),
                    _MenuTile(
                      label: '主题',
                      icon: Icons.palette_outlined,
                      iconColor: const Color(0xFF10B981),
                      trailingText: _themeLabel,
                      onTap: _openThemeSheet,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x3),
                _MenuCard(
                  children: [
                    _MenuTile(
                      label: '退出登录',
                      danger: true,
                      showChevron: false,
                      showDivider: false,
                      center: true,
                      onTap: _logout,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    required this.onTap,
    this.icon,
    this.iconColor,
    this.trailingText,
    this.danger = false,
    this.showChevron = true,
    this.showDivider = true,
    this.center = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;
  final String? trailingText;
  final bool danger;
  final bool showChevron;
  final bool showDivider;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final labelStyle = TextStyle(
      fontSize: AppTypography.base,
      fontWeight: FontWeight.w500,
      color: danger ? palette.danger : palette.foreground,
    );

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: 14,
            ),
            child: center
                ? SizedBox(
                    width: double.infinity,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: labelStyle,
                    ),
                  )
                : Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: (iconColor ?? palette.brand)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: iconColor ?? palette.brand,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(child: Text(label, style: labelStyle)),
                      if (trailingText != null) ...[
                        Text(
                          trailingText!,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: palette.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (showChevron)
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: palette.mutedForeground,
                        ),
                    ],
                  ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: icon != null ? 60 : AppSpacing.x4,
            endIndent: AppSpacing.x4,
            color: const Color(0xFFE8E8E8),
          ),
      ],
    );
  }
}
