import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: RifqApp()));
}

class RifqApp extends ConsumerStatefulWidget {
  const RifqApp({super.key});

  @override
  ConsumerState<RifqApp> createState() => _RifqAppState();
}

class _RifqAppState extends ConsumerState<RifqApp> {
  @override
  void initState() {
    super.initState();
    // ربط معالج ضغطات التنبيهات (أزرار «رجعت» و«5 دقايق كمان» والتفاعل).
    ref.read(notificationCenterProvider).bind();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    return settingsAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('حدث خطأ: $e'))),
      ),
      data: (settings) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          title: 'رِفْق',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: rifqLightTheme(),
          darkTheme: rifqDarkTheme(),
          themeMode: switch (settings.theme) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          locale: const Locale('ar', 'EG'),
          supportedLocales: const [Locale('ar', 'EG'), Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
