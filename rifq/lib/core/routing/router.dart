import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/fatigue/fatigue_screen.dart';
import '../../features/focus/focus_setup_screen.dart';
import '../../features/focus/focus_timer_screen.dart';
import '../../features/focus/retrieval_review_screen.dart';
import '../../features/focus/study_archive_screen.dart';
import '../../features/harvest/harvest_archive_screen.dart';
import '../../features/harvest/harvest_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/system_hub.dart';
import '../../features/intentional_entry/intentional_entry_screen.dart';
import '../../features/intentional_entry/usage_monitor_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/quiet_creator/creator_studio_screen.dart';
import '../../features/quiet_creator/preview_screen.dart';
import '../../features/reset/reset_flow_screen.dart';
import '../../features/settings/notification_settings_screen.dart';
import '../../features/settings/safety_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/weekly_review/weekly_review_screen.dart';
import '../db/models.dart';
import '../providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // read وليس watch: إعادة بناء الـ Router عند كل تغيير في الإعدادات
  // كانت سترجع المستخدم للشاشة الرئيسية وتفقد مكانه في التنقل.
  final settings = ref.read(settingsProvider).valueOrNull;
  return GoRouter(
    initialLocation:
        (settings != null && !settings.onboardingDone) ? '/onboarding' : '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/mirror', builder: (_, __) => const MirrorHubScreen()),
      GoRoute(path: '/compass', builder: (_, __) => const CompassHubScreen()),
      GoRoute(
          path: '/sanctuary', builder: (_, __) => const SanctuaryHubScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/reset', builder: (_, __) => const ResetFlowScreen()),
      GoRoute(path: '/focus', builder: (_, __) => const FocusSetupScreen()),
      GoRoute(
        path: '/focus/timer',
        builder: (_, state) =>
            FocusTimerScreen(session: state.extra! as FocusSession),
      ),
      GoRoute(
        path: '/focus/review',
        builder: (_, state) =>
            RetrievalReviewScreen(session: state.extra! as FocusSession),
      ),
      GoRoute(
        path: '/focus/archive',
        builder: (_, __) => const StudyArchiveScreen(),
      ),
      GoRoute(path: '/harvest', builder: (_, __) => const HarvestScreen()),
      GoRoute(
        path: '/harvest/archive',
        builder: (_, __) => const HarvestArchiveScreen(),
      ),
      GoRoute(path: '/creator', builder: (_, __) => const CreatorStudioScreen()),
      GoRoute(
        path: '/creator/preview',
        builder: (_, state) =>
            PreviewScreen(draft: state.extra! as ContentDraft),
      ),
      GoRoute(
        path: '/instagram',
        builder: (_, __) => const IntentionalEntryScreen(),
      ),
      GoRoute(
        path: '/usage',
        builder: (_, __) => const UsageMonitorScreen(),
      ),
      GoRoute(path: '/weekly', builder: (_, __) => const WeeklyReviewScreen()),
      GoRoute(path: '/fatigue', builder: (_, __) => const FatigueScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(
        path: '/settings/notifications',
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
      GoRoute(path: '/safety', builder: (_, __) => const SafetyScreen()),
    ],
  );
});
