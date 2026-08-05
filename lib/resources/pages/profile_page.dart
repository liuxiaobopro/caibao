import 'package:caibao/app/events/logout_event.dart';
import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/app/utils/theme_preference.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/llm_models_page.dart';
import 'package:caibao/resources/pages/storage_configs_page.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProfilePage extends NyStatefulWidget {
  static RouteView path = ('/profile', (_) => ProfilePage());

  ProfilePage({super.key}) : super(child: () => _ProfilePageState());
}

class _ProfilePageState extends NyPage<ProfilePage> {
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
    final palette = context.palette;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.card,
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
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(
            Icons.menu_rounded,
            color: palette.foreground,
            size: 26,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_horiz_rounded,
              color: palette.foreground,
              size: 26,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.muted,
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: palette.brandContainer,
                        backgroundImage:
                            avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? null
                            : Text(
                                initial,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: palette.brandDark,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                            letterSpacing: -0.3,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: palette.mutedForeground,
                        ),
                      ],
                    ),
                    if (_user?.caibaoId.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        '菜包号: ${_user!.caibaoId}',
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.mutedForeground,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Material(
                      color: palette.secondary,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            '菜包账号管理',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: palette.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _MenuCard(
                  children: [
                    _MenuTile(
                      label: 'S3 存储设置',
                      icon: Icons.cloud_outlined,
                      iconBg: const Color(0xFF3B82F6),
                      onTap: () => routeTo(StorageConfigsPage.path),
                    ),
                    _MenuTile(
                      label: '模型配置',
                      icon: Icons.auto_awesome,
                      iconBg: const Color(0xFF8B5CF6),
                      onTap: () => routeTo(LlmModelsPage.path),
                    ),
                    _MenuTile(
                      label: '主题',
                      icon: Icons.palette_outlined,
                      iconBg: const Color(0xFF10B981),
                      trailingText: _themeLabel,
                      onTap: _openThemeSheet,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
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
    this.iconBg,
    this.trailingText,
    this.danger = false,
    this.showChevron = true,
    this.showDivider = true,
    this.center = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconBg;
  final String? trailingText;
  final bool danger;
  final bool showChevron;
  final bool showDivider;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
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
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: iconBg ?? palette.brand,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(child: Text(label, style: labelStyle)),
                      if (trailingText != null) ...[
                        Text(
                          trailingText!,
                          style: TextStyle(
                            fontSize: 14,
                            color: palette.mutedForeground,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                      if (showChevron)
                        Icon(
                          Icons.chevron_right_rounded,
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
            indent: icon != null ? 62 : AppSpacing.x4,
            endIndent: AppSpacing.x4,
            color: palette.muted,
          ),
      ],
    );
  }
}
