import 'dart:async';

import 'package:caibao/app/analytics/analytics.dart';
import 'package:caibao/app/analytics/analytics_route_observer.dart';
import 'package:caibao/app/utils/theme_preference.dart';
import 'package:caibao/config/localization.dart';
import 'package:caibao/resources/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Main entry point for the application
class Main extends StatefulWidget {
  final String? initialRoute;
  final ThemeMode themeMode;
  final List<NavigatorObserver> navigatorObservers;
  final GlobalKey<NavigatorState>? navigatorKey;
  final Route<dynamic>? Function(RouteSettings settings) onGenerateRoute;
  final Route<dynamic>? Function(RouteSettings settings) onUnknownRoute;
  final Nylo? nylo;

  Main(
    Nylo nylo, {
    super.key,
  })  : onGenerateRoute = nylo.router!.generator(),
        onUnknownRoute = nylo.router!.unknownRoute(),
        navigatorKey = NyNavigator.instance.router.navigatorKey,
        initialRoute = nylo.getInitialRoute(),
        navigatorObservers = [
          ...nylo.getNavigatorObservers(),
          AnalyticsRouteObserver(),
        ],
        nylo = nylo,
        // Always use MaterialApp.theme; NyThemeManager swaps themeData.
        themeMode = ThemeMode.light;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends NyPage<Main> {
  @override
  get init => () async {
        await Analytics.instance.init();
        if (!mounted) return;
        await ThemePreference.restore(context);
      };

  /// Map of lifecycle actions
  @override
  get lifecycleActions {
    final base = widget.nylo?.appLifecycleStates ??
        <AppLifecycleState, dynamic Function()>{};
    return {
      ...base,
      AppLifecycleState.paused: () {
        base[AppLifecycleState.paused]?.call();
        unawaited(Analytics.instance.flush());
      },
      AppLifecycleState.detached: () {
        base[AppLifecycleState.detached]?.call();
        unawaited(Analytics.instance.flush());
      },
      AppLifecycleState.hidden: () {
        base[AppLifecycleState.hidden]?.call();
        unawaited(Analytics.instance.flush());
      },
    };
  }

  /// Disable dev panel for main app page.
  @override
  bool get useDevPanel => false;

  /// Loading style for the page.
  @override
  LoadingStyle get loadingStyle => LoadingStyle.normal(
        child: MaterialApp(
          color: Colors.white,
          debugShowMaterialGrid: true,
          showPerformanceOverlay: false,
          checkerboardRasterCacheImages: false,
          checkerboardOffscreenLayers: false,
          showSemanticsDebugger: false,
          debugShowCheckedModeBanner: true,
          home: Scaffold(backgroundColor: Colors.white, body: Loader()),
        ),
      );

  /// The [view] method displays your page.
  @override
  Widget view(BuildContext context) {
    return NyApp.materialApp(
      navigatorKey: widget.navigatorKey,
      themeMode: widget.themeMode,
      navigatorObservers: widget.navigatorObservers,
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onUnknownRoute: widget.onUnknownRoute,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final overlay = theme.appBarTheme.systemOverlayStyle ??
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: theme.scaffoldBackgroundColor,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        return locale;
      },
      supportedLocales: LocalizationConfig.supportedLocales,
    );
  }
}
