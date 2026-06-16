import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'db/database.dart';
import 'screens/insights_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/today_screen.dart';
import 'services/notifications.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppDb.instance.db;
  } catch (e, st) {
    debugPrint('DB init failed: $e\n$st');
  }
  runApp(const AnaAwlaApp());
  _initNotificationsLazy();
}

Future<void> _initNotificationsLazy() async {
  try {
    await NotificationService.instance.init();
    await NotificationService.instance.scheduleAllReminders();
  } catch (e, st) {
    debugPrint('Notifications init failed: $e\n$st');
  }
}

class AnaAwlaApp extends StatelessWidget {
  const AnaAwlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أنا أولى',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;

  static const _titles = ['اليوم', 'تحليلات', 'قواعد', 'الإعدادات'];

  Widget _body() {
    switch (_idx) {
      case 0:
        return const TodayScreen();
      case 1:
        return const InsightsScreen();
      case 2:
        return const RulesScreen();
      case 3:
        return const SettingsScreen();
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_idx])),
      body: _body(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            activeIcon: Icon(Icons.today),
            label: 'اليوم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'تحليلات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rule_folder_outlined),
            activeIcon: Icon(Icons.rule_folder),
            label: 'قواعد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
