import 'package:caibao/resources/pages/profile_page.dart';
import 'package:caibao/resources/pages/chat_page.dart';
import 'package:caibao/resources/pages/login_page.dart';
import 'package:caibao/resources/pages/not_found_page.dart';
import 'package:caibao/resources/pages/home_page.dart';
import 'package:caibao/routes/guards/auth_route_guard.dart';
import 'package:nylo_framework/nylo_framework.dart';

NyRouter appRouter() => nyRoutes((NyRouter router) {
      router.add(LoginPage.path).initialRoute();
      router
          .add(ChatPage.path)
          .authenticatedRoute()
          .addRouteGuard(AuthRouteGuard());
      router.add(ProfilePage.path).addRouteGuard(AuthRouteGuard());
      router.add(HomePage.path);
      router.add(NotFoundPage.path).unknownRoute();
    });
