import 'package:caibao/app/controllers/profile_controller.dart';
import 'package:caibao/app/utils/theme_preference.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/pages/llm_models_page.dart';
import 'package:caibao/resources/pages/storage_configs_page.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_shadows.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProfilePage extends NyStatefulWidget<ProfileController> {
  static RouteView path = ('/profile', (_) => ProfilePage());

  ProfilePage({super.key}) : super(child: () => _ProfilePageState());
}

class _ProfilePageState extends NyPage<ProfilePage> {
  ProfileController get controller => widget.controller;

  @override
  get init => () async {
        await controller.bootstrap();
      };

  @override
  bool get stateManaged => true;

  Future<void> _openThemeSheet() async {
    final current = await ThemePreference.read();
    if (!mounted) return;
    final palette = context.palette;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.x2l)),
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
                    await controller.applyTheme(option.$1);
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
      await controller.logout();
    }
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final user = controller.user;
    final nickname = user?.displayName ?? '用户';
    final initial = nickname.isNotEmpty ? nickname.characters.first : '用';
    final avatarUrl = user?.avatarUrl;

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
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4,
                AppSpacing.x1,
                AppSpacing.x4,
                AppSpacing.x8,
              ),
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
                        boxShadow: AppShadows.avatar,
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
                                  fontSize: AppTypography.x4l,
                                  fontWeight: FontWeight.w700,
                                  color: palette.brandDark,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x3_5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nickname,
                          style: TextStyle(
                            fontSize: AppTypography.x2l,
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
                    if (user?.caibaoId.isNotEmpty == true) ...[
                      const SizedBox(height: AppSpacing.x1),
                      Text(
                        '菜包号: ${user!.caibaoId}',
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: palette.mutedForeground,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.x3_5),
                    Material(
                      color: palette.secondary,
                      borderRadius: AppRadius.x3lAll,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: AppRadius.x3lAll,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.x5,
                            vertical: AppSpacing.x2_5,
                          ),
                          child: Text(
                            '菜包账号管理',
                            style: TextStyle(
                              fontSize: AppTypography.sm,
                              fontWeight: FontWeight.w700,
                              color: palette.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x7),
                _MenuCard(
                  children: [
                    _MenuTile(
                      label: 'S3 存储设置',
                      icon: Icons.cloud_outlined,
                      iconBg: palette.info,
                      onTap: () => routeTo(StorageConfigsPage.path),
                    ),
                    _MenuTile(
                      label: '模型配置',
                      icon: Icons.auto_awesome,
                      iconBg: palette.violet,
                      onTap: () => routeTo(LlmModelsPage.path),
                    ),
                    _MenuTile(
                      label: '主题',
                      icon: Icons.palette_outlined,
                      iconBg: palette.success,
                      trailingText: controller.themeLabel,
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
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: AppRadius.x3lAll,
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
      fontSize: AppTypography.base,
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
              vertical: AppSpacing.x3_5,
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
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: palette.onAccentIcon,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.x3),
                      ],
                      Expanded(child: Text(label, style: labelStyle)),
                      if (trailingText != null) ...[
                        Text(
                          trailingText!,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: palette.mutedForeground,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.x0_5),
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
