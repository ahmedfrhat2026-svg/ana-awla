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

/// منسّق التنبيهات: إعادة الجدولة مع محاسبة التجاهل، ومعالجة الضغطات.
final notificationCenterProvider =
    Provider<NotificationCenter>(NotificationCenter.new);

class NotificationCenter {
  NotificationCenter(this._ref);

  final Ref _ref;

  /// يربط معالج ضغطات التنبيهات — يُستدعى مرة عند إقلاع التطبيق.
  void bind() {
    _ref.read(schedulerProvider).onResponse = _handleResponse;
  }

  void _handleResponse(String? payload, String? actionId) {
    if (payload == null) return;
    if (payload.startsWith('cat:')) {
      _markEngaged(payload.substring(4));
    } else if (payload == 'intent_return' && actionId == 'more5') {
      _extendIntent();
    }
    // 'returned' أو الضغطة العادية: يكفي فتح التطبيق — بلا محاسبة.
  }

  Future<void> _markEngaged(String categoryName) async {
    final repo = _ref.read(notificationRulesRepoProvider);
    final engine = _ref.read(rulesEngineProvider);
    final rules = await repo.all();
    for (final rule in rules.where((r) => r.category.name == categoryName)) {
      await repo.update(engine.markEngaged(rule));
    }
  }

  Future<void> _extendIntent() async {
    final settings = await _ref.read(settingsRepoProvider).load();
    await _ref
        .read(schedulerProvider)
        .scheduleIntentReturn(5, settings.companionName);
  }

  /// إعادة جدولة اليوم كاملة: محاسبة الفئات المتجاهَلة ثم الجدولة.
  Future<void> rescheduleAll() async {
    final settings = await _ref.read(settingsRepoProvider).load();
    final repo = _ref.read(notificationRulesRepoProvider);
    final engine = _ref.read(rulesEngineProvider);
    final now = DateTime.now();
    final rules = await repo.all();
    final accounted = <NotificationRule>[];
    for (final rule in rules) {
      final updated =
          rule.enabled ? engine.accountOnSchedule(rule, now) : rule;
      if (updated.ignoredCount != rule.ignoredCount ||
          updated.lastTriggeredAt != rule.lastTriggeredAt) {
        await repo.update(updated);
      }
      accounted.add(updated);
    }
    await _ref.read(schedulerProvider).scheduleDaily(settings, accounted);
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
