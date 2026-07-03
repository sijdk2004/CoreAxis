import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/gestures.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/platform/presentation/providers/industry_scenario_provider.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

void main() {
  runApp(
    const ProviderScope(
      child: FurniFlowApp(),
    ),
  );
}

class FurniFlowApp extends ConsumerWidget {
  const FurniFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final scenarioState = ref.watch(industryScenarioProvider);
    
    final activeColor = scenarioState.previewScenario?.primaryColor ?? scenarioState.activeScenario?.primaryColor;

    ThemeData overrideTheme(ThemeData base) {
      if (activeColor == null) return base;
      return base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: activeColor,
        ),
      );
    }

    return MaterialApp.router(
      title: 'CoreAxis ERP',
      debugShowCheckedModeBanner: false,
      theme: overrideTheme(AppTheme.lightTheme),
      darkTheme: overrideTheme(AppTheme.darkTheme),
      themeMode: themeMode,
      scrollBehavior: AppScrollBehavior(),
      routerConfig: router,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
    );
  }
}
