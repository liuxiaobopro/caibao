import 'package:caibao/resources/pages/agents_page.dart';
import 'package:caibao/resources/pages/apps_page.dart';
import 'package:caibao/resources/pages/chat_page.dart';
import 'package:caibao/resources/pages/drive_page.dart';
import 'package:caibao/resources/pages/profile_page.dart';

/// Maps web notification `link` paths to Flutter [RouteView] paths.
dynamic resolveNotificationLink(String? link) {
  if (link == null) return null;
  final path = link.trim();
  if (path.isEmpty) return null;

  final normalized = path.startsWith('/') ? path : '/$path';
  final base = normalized.split('?').first.split('#').first;

  return switch (base) {
    '/chat' => ChatPage.path,
    '/agents' => AgentsPage.path,
    '/drive' => DrivePage.path,
    '/apps' => AppsPage.path,
    '/profile' => ProfilePage.path,
    _ => null,
  };
}
