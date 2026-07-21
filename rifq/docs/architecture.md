# معمارية رِفْق (Architecture)

هذا المستند يشرح التنظيم الداخلي لكود رِفْق: الطبقات، الأنماط (Patterns) المستخدمة، وليه اتاخدت بعض القرارات التقنية. المصطلحات التقنية بالإنجليزي عشان تفضل واضحة ودقيقة، والشرح بالعربي.

---

## 1. الطبقات (Layers) — نظرة عامة

```
┌─────────────────────────────────────────────┐
│  UI (Widgets)                                │
│  lib/features/*/                             │
│  — شاشات وواجهات، كل feature في مجلده          │
└───────────────────┬───────────────────────────┘
                    │ يقرأ/يكتب عبر
┌───────────────────▼───────────────────────────┐
│  State (Riverpod Providers)                  │
│  lib/core/providers.dart                     │
│  — Provider لكل Repository + Notifier للحالة  │
└───────────────────┬───────────────────────────┘
                    │ يعتمد على Interfaces
┌───────────────────▼───────────────────────────┐
│  Domain / Abstractions                       │
│  NotificationScheduler · ContentTemplateEngine│
│  InstagramLauncher · UsageStatsGateway        │
│  NotificationRulesEngine · PrivacyGate        │
└───────────────────┬───────────────────────────┘
                    │ implemented by
┌───────────────────▼───────────────────────────┐
│  Data (Repository implementations)           │
│  lib/core/db/repositories.dart (Local*Repository)│
│  lib/core/db/app_database.dart (sqflite)     │
└───────────────────────────────────────────────┘
```

النقطة الأساسية: **الطبقة اللي فوق ماتعرفش حاجة عن التنفيذ اللي تحتها**. الشاشات (Widgets) بتتكلم مع Providers، والـ Providers بترجع Interfaces (abstract interface class)، مش تنفيذات حقيقية. ده اللي بيخلي الاختبارات ممكنة من غير قاعدة بيانات حقيقية أو Android APIs حقيقية.

---

## 2. التنظيم على أساس الميزة (Feature-First)

بدل ما يتقسم الكود لـ "كل الشاشات هنا، كل الـ models هنا، كل الـ logic هنا" (Layer-first)، رِفْق منظّم Feature-First:

```
lib/
├── core/              # كل حاجة مشتركة بين الميزات
│   ├── theme/          # Material 3 ThemeData
│   ├── db/              # AppDatabase + models.dart + repositories.dart
│   ├── notifications/   # NotificationScheduler + NotificationRulesEngine
│   ├── content/         # ContentTemplateEngine + sacred_texts + seed_texts
│   ├── instagram/        # InstagramLauncher + UsageStatsGateway
│   ├── privacy/          # PrivacyGate + safety_check
│   ├── routing/           # GoRouter (router.dart)
│   └── providers.dart     # نقطة تجميع كل الـ Providers
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── reset/            # "أنا تايه دلوقتي"
│   ├── focus/             # "افتح بس"
│   ├── harvest/
│   ├── quiet_creator/
│   ├── intentional_entry/
│   ├── weekly_review/
│   ├── fatigue/
│   └── settings/
└── shared/                # Widgets عامة يُعاد استخدامها بين الميزات
```

كل مجلد جوّه `features/` بيحتوي الشاشات (screens) الخاصة بيه فقط، وبيستهلك من `core/` أي منطق أو بيانات محتاجها. مفيش تبعية بين مجلدين features مع بعض مباشرة — أي تواصل بينهم بيمر عبر `core/routing/router.dart` (التنقل) أو `core/providers.dart` (الحالة المشتركة، زي `settingsProvider`).

---

## 3. نمط الـ Repository + الـ Fakes

كل جدول أو مصدر بيانات له:

1. **Interface مجرّد** (`abstract interface class`) في `lib/core/db/repositories.dart` — مثلاً `SettingsRepository`, `WinsRepository`, `FocusRepository`, `ResetRepository`, `ReflectionRepository`, `DraftsRepository`, `IntentRepository`, `NotificationRulesRepository`, `CheckInRepository`.
2. **تنفيذ محلي حقيقي** (`Local*Repository implements *Repository`) بيستخدم `sqflite` فعليًا — بنفس الملف.
3. **Fake للاختبارات** في `test/fakes.dart` — بيحاكي نفس الـ Interface بقوائم في الذاكرة (In-memory)، بدون أي احتكاك بقاعدة بيانات حقيقية.

الـ Providers في `lib/core/providers.dart` بترجع الـ Interface مش التنفيذ:

```dart
final winsRepoProvider = Provider<WinsRepository>((_) => LocalWinsRepository());
```

في الاختبارات، بيتم عمل `ProviderScope` override بـ Fake بدل التنفيذ الحقيقي — فبكده أي Widget أو منطق بيُختبر من غير قاعدة بيانات فعلية ومن غير أي I/O بطيء.

---

## 4. الأربع Abstractions الأساسية

هذول هما نقاط التجريد (Abstraction) الحقيقية في التطبيق — كل واحدة عندها تنفيذ حقيقي (production) وتنفيذ وهمي (fake) للاختبار:

| Interface | الملف | الغرض | التنفيذ الحقيقي |
|---|---|---|---|
| `NotificationScheduler` | `core/notifications/notification_scheduler.dart` | جدولة/إلغاء التنبيهات | `LocalNotificationScheduler` عبر `flutter_local_notifications` + `timezone`، تنبيهات inexact فقط |
| `ContentTemplateEngine` | `core/content/content_template_engine.dart` | تحويل الإنجازات لصيغ نشر | `LocalContentTemplateEngine` — deterministic 100%، بدون أي AI |
| `InstagramLauncher` | `core/instagram/instagram_launcher.dart` | فتح إنستجرام أو المتصفح | `UrlInstagramLauncher` عبر `url_launcher` (`instagram://app` ثم fallback لموقع الويب) |
| `UsageStatsGateway` | `core/instagram/instagram_launcher.dart` | قياس وقت استخدام تطبيقات مستقبلاً | **لا يوجد تنفيذ حقيقي بعد** — خلف `const bool usageStatsEnabled = false;` |

كل واحدة من التلاتة الأولى ليها Fake مقابل في `test/fakes.dart` بيُستخدم في الاختبارات (Widget tests والـ unit tests اللي محتاجة تتحقق من السلوك بدون Side Effects حقيقية زي إرسال تنبيه فعلي أو فتح تطبيق فعلي).

---

## 5. مخطط قاعدة البيانات (DB Schema) — جدول بجدول

القاعدة `sqflite`، الملف `rifq.db`، تُنشأ بـ `AppDatabase.createSchema()` في `lib/core/db/app_database.dart` (version 1، جدول واحد لكل نوع بيانات، مفاتيح `AUTOINCREMENT` عدا `user_settings`).

| الجدول | الغرض | ملاحظات مهمة |
|---|---|---|
| `user_settings` | صف واحد ثابت (`id = 1`) بإعدادات المستخدم: اللغة، الثيم، اسم الرفيق، شخصيته، عدد التنبيهات اليومي، ساعات الصمت، حالة الـ onboarding، `fatigueModeUntil` | يُدرج تلقائيًا صف افتراضي عند إنشاء القاعدة |
| `daily_checkin` | تسجيل مزاجي/طاقة يومي بسيط | `mood`, `energy` (1-5)، `note` حرة |
| `small_win` | الإنجازات الصغيرة | `category` + `privacyLevel` — الفئات الحساسة (`worship`, `charity`, `privateFamily`, `health`, `financial`) تُفرض عليها `PrivacyLevel.private` افتراضيًا عبر `SmallWin.create()` |
| `focus_session` | جلسات التركيز | يحفظ `plannedMinutes`/`actualMinutes`، حالة `FocusStatus` (planned/running/paused/completed/endedEarly)، وأسئلة المراجعة (`retrievalAnswer`, `unclearPoint`, `examQuestion`, `nextStep`) |
| `reset_session` | جلسات "أنا تايه دلوقتي" | `selectedNeed`, `breathingDurationSeconds` (90/180/300)، `tinyAction`، `completed` |
| `reflection` | التأمل المسائي | `learned`, `gratitude`, `releaseThought`, `moodAfter` |
| `content_draft` | مسودات صانع المحتوى | `sourceWinIds` (نصّ مفصول بفواصل)، `format` (`ContentFormat`)، `privacyLevel`، `status` (`DraftStatus`: draft/keptPrivate/shared/notNow) |
| `intent_session` | جلسات الدخول الواعي لإنستجرام | `targetApp`, `intention`, `plannedMinutes`, `startedAt`/`returnedAt`, `extraMinutes`, `outcome` |
| `notification_rule` | قواعد كل فئة تنبيه | `category` (`NotificationCategory`)، `enabled`، `preferredHour/Minute`، `ignoredCount` (يُصفَّر عند التفاعل، يزيد عند التجاهل) |

عند إنشاء القاعدة لأول مرة، يُدرج صف `user_settings` افتراضي وستة صفوف `notification_rule` (واحد لكل `NotificationCategory`)، لكن **ثلاث فئات فقط مفعّلة افتراضيًا** (`morningGrounding`, `studyStart`, `eveningHarvest`) احترامًا لحد الثلاثة تنبيهات يوميًا.

---

## 6. سلوك محرك قواعد التنبيهات (NotificationRulesEngine)

الملف: `lib/core/notifications/notification_rules_engine.dart` — كلاس بمنطق بحت (Pure logic)، بدون أي اعتماد على Flutter أو Android APIs، وده اللي بيخليه سهل الاختبار بشكل كامل (unit tests في `test/notification_rules_test.dart`).

القواعد:

1. **ساعات الصمت (`isQuietHour`)**: يدعم النطاق العابر لمنتصف الليل (مثلاً من 22 لـ 8) — لو `start < end` فحص عادي، ولو `start > end` (عابر لمنتصف الليل) الفحص بيبقى `hour >= start || hour < end`.
2. **اختيار تنبيهات اليوم (`selectForDay`)**: يفلتر القواعد المفعّلة فقط، برّه ساعات الصمت، وبيستبعد الفئات اللي وصلت لـ `reducedFrequency` (تجاهل ≥ 3 مرات) في نص الأيام (الأيام الزوجية فقط `day.day.isEven`) — تقليل فعلي للوتيرة بدل الإلغاء الكامل.
3. **التباعد الزمني (`_spaced`)**: مفيش تنبيهان في أقل من 90 دقيقة من بعض.
4. **الحد الأقصى اليومي**: `maxPerDay` (افتراضيًا 3، أو 1 فقط في وضع الفتور).
5. **اختيار النص (`pickText`)**: اختيار deterministic من قائمة نصوص بناءً على عدد الأيام منذ `DateTime(2026)` — نفس اليوم بيدّي نفس النص دايمًا، وده يخلي الاختبار ممكن بدون Randomness.
6. **تتبّع التفاعل**: `markIgnored` يزيد العداد، `markEngaged` يصفّره.

> ملاحظة صدق: منطق العداد ده **مُختبر بالكامل** لكنه **مش مربوط فعليًا** بأحداث النقر الحقيقية على التنبيه من نظام أندرويد (OS-level notification tap callback) — الربط ده لسه ما اتعملش.

---

## 7. حتمية محرك القوالب (ContentTemplateEngine Determinism)

الملف: `lib/core/content/content_template_engine.dart`.

`LocalContentTemplateEngine.build()` بياخد `ContentFormat` (story/caption/carousel/reelScript/weeklyHarvest) و`ContentInput` (الإنجازات، التأمل، الدرس، الجمهور)، ويرجّع `ContentDraft` **بدون أي استدعاء شبكة أو أي عشوائية أو أي نموذج لغوي**. كل صيغة (Story، Caption، إلخ) دالة نصّية بحتة (Pure function) بتجمع نصوص المستخدم في قالب ثابت.

نقطتين مهمّتين جوّه المحرك:

- **`ContentInput.shareableWins`**: بيستبعد أي إنجاز `PrivacyLevel.private` أو `PrivacyLevel.draft` تلقائيًا — بس `public` و`lessonOnly` بيدخلوا في المحتوى المُولَّد.
- **`PrivacyGate`**: كلاس منفصل تمامًا مسؤول عن قرار "هل أشارك؟" (`GateDecision`: keepPrivate/shareLessonOnly/sharePublic/saveDraft) — منطق التوليد ومنطق قرار المشاركة مفصولين عمدًا.

الحتمية دي بالذات هي اللي خلّت اختبار `content_template_engine_test.dart` ممكن: نفس المدخلات = نفس المخرجات، كل مرة.

---

## 8. ليه sqflite بدل Drift؟

قرار متعمّد. الأسباب:

- **بدون build_runner / codegen**: Drift بيحتاج جيل كود (`.g.dart` files) قبل أي build، وده بيضيف خطوة ومصدر أعطال (خصوصًا في CI). `sqflite` مباشر وواضح.
- **نمط مُثبَت في هذا الريبو**: التعامل اليدوي مع SQL + Repository interfaces + Fakes هو نمط معروف ومُختبر هنا، مش شيء جديد بيحتاج تعلّم.
- **حجم البيانات بسيط**: تسع جداول بسيطة، مفيش حاجة لـ Type-safe query builder معقّد — SQL خام واضح كفاية.
- **التكلفة الإدراكية أقل**: أي حد يفتح `app_database.dart` يقرأ الـ Schema كامل في نظرة واحدة، بدون طبقة تجريد إضافية.

الثمن المقابل: كتابة الـ `toMap()`/`fromMap()` يدويًا لكل Model (موجودة في `lib/core/db/models.dart`) — تكلفة صغيرة مقابل بساطة الـ build.

---

## 9. إزاي تضيف ميزة جديدة

خطوات مقترحة لإضافة feature جديد بنفس الأسلوب المتّبع في الريبو:

1. **مجلد جديد** تحت `lib/features/اسم_الميزة/`.
2. لو الميزة محتاجة بيانات جديدة: أضف Model في `lib/core/db/models.dart` (مع `toMap`/`fromMap`)، وجدول جديد في `AppDatabase.createSchema()`، وInterface + تنفيذ محلي في `lib/core/db/repositories.dart`.
3. أضف Fake مطابق في `test/fakes.dart`.
4. أضف `Provider` في `lib/core/providers.dart` يرجّع الـ Interface.
5. ابنِ الشاشات في مجلد الميزة، واستهلك الـ Provider عبر `ref.watch`/`ref.read`.
6. أضف Route جديد في `lib/core/routing/router.dart` لو الميزة محتاجة شاشة مستقلة.
7. لو فيه محتوى نصي: أضفه في `seed_texts.dart` (نصوص عامة) أو `sacred_texts.dart` (نص ديني — **بمصدر موثّق فقط**، ولا يُضاف نص ديني في أي مكان تاني).
8. اكتب unit test للمنطق البحت (لو فيه)، وwidget test للشاشة باستخدام الـ Fakes.
9. تأكد `flutter analyze` و`flutter test` نضيفين قبل أي Commit.

هذا التسلسل هو نفسه اللي اتّبع في بناء كل الميزات التسعة الموجودة حاليًا في التطبيق.
