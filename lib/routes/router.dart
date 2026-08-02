import 'package:caibao/resources/pages/profile_page.dart';
import 'package:caibao/resources/pages/chat_page.dart';
import 'package:caibao/resources/pages/not_found_page.dart';
import 'package:caibao/resources/pages/home_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* App Router
|--------------------------------------------------------------------------
| * [Tip] Create pages faster 🚀
| Terminal: "metro make:page profile_page"

| Learn more https://nylo.dev/docs/7.x/router
|-------------------------------------------------------------------------- */

NyRouter appRouter() => nyRoutes((NyRouter router) {
      router.add(ChatPage.path).initialRoute();
      router.add(ProfilePage.path);
      router.add(HomePage.path);
      router.add(NotFoundPage.path).unknownRoute();
});
