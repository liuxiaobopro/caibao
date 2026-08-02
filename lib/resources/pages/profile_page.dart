import 'package:caibao/app/models/user.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProfilePage extends NyStatefulWidget {
  static RouteView path = ('/profile', (_) => ProfilePage());

  ProfilePage({super.key}) : super(child: () => _ProfilePageState());
}

class _ProfilePageState extends NyPage<ProfilePage> {
  User? _user;
  bool _loading = true;

  @override
  get init => () async {
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

  void _noopTap(String label) {
    showToastSorry(description: label);
  }

  @override
  Widget view(BuildContext context) {
    final palette = context.palette;
    final user = _user;
    final nickname = user?.displayName ?? '用户';
    final caibaoId = user?.caibaoId ?? '';
    final initial =
        nickname.isNotEmpty ? nickname.characters.first : '用';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.menu, color: palette.foreground, size: AppSizes.iconXl),
        ),
        actions: [
          IconButton(
            onPressed: () => _noopTap('更多'),
            icon: Icon(
              Icons.more_horiz,
              color: palette.foreground,
              size: AppSizes.iconXl,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x4,
                  0,
                  AppSpacing.x4,
                  AppSpacing.x8,
                ),
                children: [
                  const SizedBox(height: AppSpacing.x2),
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: palette.brandContainer,
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: AppTypography.x3l,
                          fontWeight: FontWeight.w700,
                          color: palette.brandDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nickname,
                        style: TextStyle(
                          fontSize: AppTypography.x2l,
                          fontWeight: FontWeight.w700,
                          color: palette.foreground,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: AppSizes.iconLg,
                        color: palette.mutedForeground,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x1_5),
                  Text(
                    '菜包号: $caibaoId',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      color: palette.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x5),
                  Center(
                    child: OutlinedButton(
                      onPressed: () => _noopTap('菜包账号管理'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: palette.foreground,
                        side: const BorderSide(color: Color(0xFFE5E5E5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.x2lAll,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x8,
                          vertical: AppSpacing.x3,
                        ),
                      ),
                      child: Text(
                        '菜包账号管理',
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: FontWeight.w600,
                          color: palette.foreground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.auto_awesome,
                        iconBg: const Color(0xFF3A3A3A),
                        label: '菜包专业版',
                        trailingText: '立即升级',
                        onTap: () => _noopTap('菜包专业版'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.face_retouching_natural,
                        iconBg: const Color(0xFF8B7355),
                        label: '菜包形象',
                        onTap: () => _noopTap('菜包形象'),
                      ),
                      _SettingsTile(
                        icon: Icons.volume_up,
                        iconBg: const Color(0xFF7C5CBF),
                        label: '声音',
                        onTap: () => _noopTap('声音'),
                      ),
                      _SettingsTile(
                        icon: Icons.text_fields,
                        iconBg: const Color(0xFF3A3A3A),
                        label: '字号与背景',
                        onTap: () => _noopTap('字号与背景'),
                      ),
                      _SettingsTile(
                        icon: Icons.psychology_alt,
                        iconBg: const Color(0xFF2F80ED),
                        label: '记忆',
                        trailingText: '已关闭',
                        onTap: () => _noopTap('记忆'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.add_comment,
                        iconBg: const Color(0xFF2F80ED),
                        label: '开启新话题',
                        onTap: () => _noopTap('开启新话题'),
                      ),
                      _SettingsTile(
                        icon: Icons.search,
                        iconBg: const Color(0xFF2F80ED),
                        label: '查找聊天内容',
                        onTap: () => _noopTap('查找聊天内容'),
                      ),
                      _SettingsTile(
                        icon: Icons.bolt,
                        iconBg: const Color(0xFF2F80ED),
                        label: '新对话默认模式',
                        trailingText: '快速',
                        trailingIcon: Icons.unfold_more,
                        onTap: () => _noopTap('新对话默认模式'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.x2lAll,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.trailingText,
    this.trailingIcon = Icons.chevron_right,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String? trailingText;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.x2lAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3_5,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(icon, color: Colors.white, size: AppSizes.iconMd),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppTypography.base,
                  fontWeight: FontWeight.w500,
                  color: palette.foreground,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: palette.mutedForeground,
                ),
              ),
              const SizedBox(width: AppSpacing.x1),
            ],
            Icon(
              trailingIcon,
              size: AppSizes.iconLg,
              color: palette.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
