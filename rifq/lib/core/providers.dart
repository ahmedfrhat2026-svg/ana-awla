import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'content/content_template_engine.dart';
import 'db/models.dart';
import 'db/repositories.dart';
import 'instagram/instagram_launcher.dart';
import 'notifications/notification_rules_engine.dart';
import 'notifications/notification_scheduler.dart';

/// نقطة تجميع الاعتماديات — الاختبارات تستبدل أي Provider بتنفيذ وهمي.

final settingsRepoProvider =
    Provider<SettingsRepository>((_) => LocalSettingsRepository());
final winsRepoProvider = Provider<WinsRepository>((_) => LocalWinsRepository());
final focusRepoProvider =
    Provider<FocusRepository>((_) => LocalFocusRepository());
final resetRepoProvider =
    Provider<ResetRepository>((_) => LocalResetRepository());
final reflectionRepoProvider =
    Provider<ReflectionRepository>((_) => LocalReflectionRepository());
final draftsRepoProvider =
    Provider<DraftsRepository>((_) => LocalDraftsRepository());
final intentRepoProvider =
    Provider<IntentRepository>((_) => LocalIntentRepository());
final notificationRulesRepoProvider = Provider<NotificationRulesRepository>(
    (_) => LocalNotificationRulesRepository());
final checkInRepoProvider =
    Provider<CheckInRepository>((_) => LocalCheckInRepository());

final templateEngineProvider =
    Provider<ContentTemplateEngine>((_) => const LocalContentTemplateEngine());
final privacyGateProvider = Provider<PrivacyGate>((_) => const PrivacyGate());
final rulesEngineProvider =
    Provider<NotificationRulesEngine>((_) => const NotificationRulesEngine());
final schedulerProvider =
    Provider<NotificationScheduler>((_) => LocalNotificationScheduler());
final instagramLauncherProvider =
    Provider<InstagramLauncher>((_) => const UrlInstagramLauncher());

/// الإعدادات الحالية — تُحمَّل مرة وتُحدَّث عند أي تغيير.
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, UserSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() => ref.read(settingsRepoProvider).load();

  Future<void> save(UserSettings settings) async {
    await ref.read(settingsRepoProvider).save(settings);
    state = AsyncData(settings);
  }
}

/// إنجازات اليوم — للشاشة الرئيسية وحصاد اليوم.
final todayWinsProvider = FutureProvider.autoDispose((ref) {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return ref.watch(winsRepoProvider).byDate(today);
});

/// آخر جلسات التركيز.
final recentFocusProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(focusRepoProvider).recent(limit: 5));
