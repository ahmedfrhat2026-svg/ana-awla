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
├── design_system/       # طبقة تصميم مركزية (tokens + theme + components) — راجع قسم 2.1
├── core/              # كل حاجة مشتركة بين الميزات
│   ├── theme/          # Material 3 ThemeData + RifqPalette ThemeExtension
│   ├── db/              # AppDatabase (schema v4) + models.dart + repositories.dart
│   ├── notifications/   # NotificationScheduler + NotificationRulesEngine
│   ├── content/         # ContentTemplateEngine + sacred_texts + seed_texts
│   ├── instagram/        # InstagramLauncher + UsageStatsGateway
│   ├── privacy/          # PrivacyGate + safety_check
│   ├── routing/           # GoRouter (router.dart)
│   └── providers.dart     # نقطة تجميع كل الـ Providers
├── features/
│   ├── onboarding/
│   ├── home/               # شاشة الحديقة الحيّة (Living Garden) — راجع قسم 2.2
│   ├── mirror/              # المرآة — متحف العودة، حصاد الرحلة، سكينة الأسبوع، أرشيف المذاكرة
│   ├── compass/             # البوصلة — حديقة القيم، غرفة القرار، أذاكر، المؤثر الهادئ...
│   ├── sanctuary/           # الملجأ — مسارات المشاعر، وضع الخلوة
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

كل مجلد جوّه `features/` بيحتوي الشاشات (screens) الخاصة بيه فقط، وبيستهلك من `core/` و `design_system/` أي منطق أو بيانات أو مكوّنات محتاجها. مفيش تبعية بين مجلدين features مع بعض مباشرة — أي تواصل بينهم بيمر عبر `core/routing/router.dart` (التنقل) أو `core/providers.dart` (الحالة المشتركة، زي `settingsProvider`).

---

### 2.1 طبقة نظام التصميم (`lib/design_system/`)

مع إعادة تنظيم التطبيق حوالين المرآة والبوصلة والملجأ، اتضاف مجلد `lib/design_system/` كطبقة مستقلة تحت `lib/` (مش جوّه `core/`) عشان تبقى قابلة للاستهلاك من أي `feature` أو من `core/theme/` نفسه من غير أي علاقة دائرية (Circular dependency):

- **Tokens**: ألوان مُرمَّزة (عاجي دافئ `#F5F1E8`، سيچ `#708A72`، أخضر غابة عميق `#365646`، طيني `#C78668`، رملي، ذهبي، ماء هادئ)، مقياس تباعد (Spacing scale)، أشكال عضوية (Organic shapes)، ورموز حركة (Motion tokens) بما فيها مدة الحركة الافتراضية ومنحنياتها.
- **Typography**: خط Cairo مُعايَر للعربي — ارتفاع سطر سخي (Generous line height) وعناوين بايرة عبر `FontVariation` بدل أوزان خطوط منفصلة.
- **Theme**: `RifqPalette` — كلاس `ThemeExtension<RifqPalette>` بيحمل الألوان الدلالية الخاصة بمشهد الحديقة (بركة، حجر، ورقة...) بحيث أي Widget يقدر يوصلها عبر `Theme.of(context).extension<RifqPalette>()` من غير Hardcoding. فيه ثيمين كاملين (فاتح وداكن) بظلال خضراء ناعمة مشتقة من نفس لوحة الألوان (بدل الظل الرمادي الافتراضي).
- **Motion helper**: دالة/مزوّد بيقرأ إعداد "تقليل الحركة" (Reduced Motion) من نظام التشغيل أو من إعدادات المستخدم، وبيستخدمها أي Widget فيه حركة (خصوصًا مشهد الحديقة الحيّة) عشان يوقف الحركة تمامًا لو مفعّل.
- **مكوّنات مشتركة (Shared components)**: `RifqScaffold`, `RifqPageHeader`, `RifqOrganicSurface`, `RifqSection`, `RifqEmptyState` — بديل موحّد لعناصر الواجهة المتكررة (Scaffold، عنوان صفحة، سطح بحواف عضوية، قسم محتوى، حالة فارغة)، بحيث أي شاشة جديدة في أي `feature` بتاخد نفس الشكل البصري تلقائيًا من غير إعادة كتابة.

---

### 2.2 الشاشة الرئيسية: الحديقة الحيّة (Living Garden)

`lib/features/home/` بقى فيه مشهد `CustomPainter` أصلي (مش صورة أو Asset جاهز) بيرسم: بركة ماء عاكسة (بوابة المرآة)، طريق حجارة (بوابة البوصلة)، وشجرة زيتون تحت مأوى (بوابة الملجأ) — مع إضاءة بتتغيّر حسب وقت اليوم الحالي، وحركة خلفية خفيفة جدًا (Ambient motion) بتتوقف تلقائيًا في حالتين: التطبيق في الخلفية، أو المستخدم مفعّل "تقليل الحركة". فوق الرسمة، كل بوابة (Mirror/Compass/Sanctuary) عندها `Semantics` بتسمية عربية + تلميح (hint)، ومنطقة لمس لا تقل عن 48px بصرف النظر عن حجم الرسمة تحتها — عشان تفضل الشاشة قابلة للاستخدام مع قارئات الشاشة وبدون الاعتماد على الرؤية فقط للتنقل.

---

### 2.3 نمط تعيين العرض (Presentation-Mapping Pattern)

المميزات الجديدة (المرآة والبوصلة والملجأ) بتتبع نمط ثابت لفصل المنطق عن الرسم، بحيث الـ `CustomPainter` أو الـ Widget البصري **بيرسم فقط ولا يحسب أي حاجة**:

1. **Domain model**: نموذج بيانات خام من قاعدة البيانات (مثلاً `ReturnMoment` لجلسة عودة مكتملة، أو `LifeValue` لقيمة في حديقة القيم).
2. **Mapper/logic نقي (Pure)**: دالة أو كلاس بيحوّل الـ Domain model لتمثيل بصري جاهز — بدون أي `BuildContext` أو استدعاء رسم، وبالتالي قابل للاختبار بـ unit test عادي. أمثلة:
   - `buildReturnsSummary()` (متحف العودة، المرآة) — بياخد قائمة `ReturnMoment` ويرجّع وصف نوعي (جملة، مش رقم) + مواقع الحجارة على المشهد.
   - منطق نمو `LifeValue` (حديقة القيم، البوصلة) — بيحدد حالة النبتة (نمو/راحة) بناءً على تاريخ آخر فعل مرتبط بالقيمة، من غير أي نسبة مئوية أو Score.
   - `emotion_paths` (الملجأ) — خريطة نقية بتربط كل مشاعر من الثمانية (مرهق/حزين/خائف/مشتت/زهقان/محبط/مجهد ذهنيًا/لا أعرف) بمسار الاستجابة الخاص بيه (تعب→راحة، حزن→دعم، خوف→فصل الحقيقة عن التوقع...).
3. **Visual widget**: الـ Widget أو الـ `CustomPainter` بياخد ناتج الخطوة السابقة (تمثيل بصري جاهز) ويرسمه بس — بدون أي منطق عمل (Business logic) جوّه دالة الرسم نفسها.

الفايدة: أي تغيير في "إزاي تتحسب حالة القيمة" أو "إزاي توصف لحظة العودة" بيتاختبر بـ unit test بسيط بدون تشغيل Widget أو Painter، وأي تعديل بصري (لون، شكل، حركة) ما بيلمسش منطق العمل خالص.

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

القاعدة `sqflite`، الملف `rifq.db`، تُنشأ بـ `AppDatabase.createSchema()` في `lib/core/db/app_database.dart` (**الآن schema v4**، جدول واحد لكل نوع بيانات، مفاتيح `AUTOINCREMENT` عدا `user_settings`).

| الجدول | الغرض | ملاحظات مهمة |
|---|---|---|
| `user_settings` | صف واحد ثابت (`id = 1`) بإعدادات المستخدم: اللغة، الثيم، اسم الرفيق، شخصيته، عدد التنبيهات اليومي، ساعات الصمت، حالة الـ onboarding، `fatigueModeUntil` | يُدرج تلقائيًا صف افتراضي عند إنشاء القاعدة |
| `daily_checkin` | تسجيل مزاجي/طاقة يومي بسيط | `mood`, `energy` (1-5)، `note` حرة |
| `small_win` | الإنجازات الصغيرة | `category` + `privacyLevel` — الفئات الحساسة (`worship`, `charity`, `privateFamily`, `health`, `financial`) تُفرض عليها `PrivacyLevel.private` افتراضيًا عبر `SmallWin.create()` |
| `focus_session` | جلسات التركيز | يحفظ `plannedMinutes`/`actualMinutes`، حالة `FocusStatus` (planned/running/paused/completed/endedEarly)، وأسئلة المراجعة (`retrievalAnswer`, `unclearPoint`, `examQuestion`, `nextStep`) |
| `reset_session` | جلسات "أنا تايه دلوقتي" | `selectedNeed`, `breathingDurationSeconds` (90/180/300)، `tinyAction`، `completed` — والمصدر الخام لمتحف العودة في المرآة |
| `reflection` | التأمل المسائي | `learned`, `gratitude`, `releaseThought`, `moodAfter` |
| `content_draft` | مسودات صانع المحتوى | `sourceWinIds` (نصّ مفصول بفواصل)، `format` (`ContentFormat`)، `privacyLevel`، `status` (`DraftStatus`: draft/keptPrivate/shared/notNow) |
| `intent_session` | جلسات الدخول الواعي لإنستجرام | `targetApp`, `intention`, `plannedMinutes`, `startedAt`/`returnedAt`, `extraMinutes`, `outcome` |
| `notification_rule` | قواعد كل فئة تنبيه | `category` (`NotificationCategory`)، `enabled`، `preferredHour/Minute`، `ignoredCount` (يُصفَّر عند التفاعل، يزيد عند التجاهل) |
| `life_value` | **جديد (schema v4)** — قيم حديقة القيم في البوصلة | `name`, `createdAt`، وتاريخ آخر فعل مرتبط بيها. مفيش عمود "نسبة نمو" أو Score — حالة النمو/الراحة بتتحسب وقت العرض عبر منطق نقي (Pure logic)، مش بتتخزّن كرقم جاهز. الصف **ما بيتحذفش تلقائيًا ولا بيترّاجع** — بيفضل موجود حتى لو اتأهملت القيمة لفترة طويلة |

عند إنشاء القاعدة لأول مرة، يُدرج صف `user_settings` افتراضي وستة صفوف `notification_rule` (واحد لكل `NotificationCategory`)، لكن **ثلاث فئات فقط مفعّلة افتراضيًا** (`morningGrounding`, `studyStart`, `eveningHarvest`) احترامًا لحد الثلاثة تنبيهات يوميًا.

### 5.1 الترقية لـ schema v4 (`life_value`)

مع إضافة البوصلة، ارتفع رقم نسخة القاعدة عبر `onUpgrade` في `AppDatabase` لإنشاء جدول `life_value` الجديد فقط، بدون التأثير على أي جدول موجود — نفس نمط الـ Migration المتّبع في الإصدارات السابقة: كل ترقية بتضيف جدول/عمود جديد فقط، ومفيش أي `DROP` أو إعادة بناء لجدول قائم، فبكده بيانات المستخدم القديمة (حصاد، جلسات تركيز، جلسات عودة... إلخ) بتفضل سليمة تمامًا بعد أي تحديث للتطبيق.

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
- **حجم البيانات بسيط**: عشر جداول بسيطة (بعد إضافة `life_value` في schema v4)، مفيش حاجة لـ Type-safe query builder معقّد — SQL خام واضح كفاية.
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

هذا التسلسل هو نفسه اللي اتّبع في بناء كل الميزات الموجودة حاليًا في التطبيق، بما فيها المرآة والبوصلة والملجأ.
