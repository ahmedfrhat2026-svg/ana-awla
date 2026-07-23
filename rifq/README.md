# رِفْق | RIFQ

**ارجع لنفسك على مهل.**

رِفْق تطبيق أندرويد بواجهة عربية (RTL) بالكامل، هدفه إنه يكون رفيق هادئ يساعدك ترجع لحياتك الحقيقية: تقلل السكرول اللي مالوش نهاية، تذاكر بهدوء من غير ضغط، توثّق إنجازاتك الصغيرة، وتنشر على إنستجرام بنية واضحة بدل ما تدخل تفتح التطبيق وتلاقي نفسك بعد ساعة لسه بتسكرول.

مفيش فيه Feed ولا إعلانات ولا Leaderboard ولا "streaks" بشعلة نار بتخوّفك لو فوّت يوم. البيانات كلها على جهازك، والتطبيق شغّال حتى من غير إنترنت.

> **باب ترجع منه لحياتك** — مش تطبيق تاني تضيع فيه وقتك، لكنه باب صغير بيفتحلك على الحياة الحقيقية اللي برا الشاشة.

---

## الفلسفة

- **الرفق مش الحماس المؤقت.** خطوة صغيرة كل يوم أفضل من خطة مثالية بتتنفّذ مرة وتتوقف.
- **بدون لوم.** لا التطبيق يشحنك بالذنب لو فوّت يوم، ولا النصوص فيها كلمات تخويف أو تحقير.
- **الخصوصية أولاً.** أي حاجة حساسة (عبادة، صدقة، أسرة، صحة، مال) خاصة افتراضيًا، ومحدش هيشوفها إلا لو انت قررت صراحة.
- **الدين حاضر برفق لا بتكلّف.** أي نص ديني في التطبيق منقول حرفيًا من مصدر موثّق (تفسير/حديث) — لا اجتهاد ولا نص مُختلَق.
- **التطبيق مش بديل عن مختص.** فيه صفحة أمان واضحة بتقول: "ليس علاجًا"، ومفيش فتاوى ولا تشخيصات.

---

## الأنظمة الثلاثة

من نسخة v0.4.0، رِفْق بقى متبني حوالين **ثلاث مساحات متصلة**، بتظهر على شاشة رئيسية جديدة: حديقة حيّة (Living Garden) — مشهد مرسوم بالكامل بـ `CustomPainter` أصلي، مش صورة جاهزة: بركة ماء عاكسة (المرآة)، طريق حجارة (البوصلة)، وشجرة زيتون تحت مأوى (الملجأ)، مع إضاءة بتتغيّر حسب وقت اليوم، وحركة سكونية خفيفة جدًا بتتوقف تلقائيًا لما التطبيق يبقى في الخلفية أو لو المستخدم مفعّل "تقليل الحركة" (Reduced Motion). كل وجهة على الشاشة عندها تسمية عربية + تلميح، ومساحة لمس دلالية (Semantic tap target) لا تقل عن 48px.

### 🪞 المرآة — تأمل ما عشته
- **متحف العودة (Museum of Returning)**: كل جلسة عودة مكتملة بتتحول لحجر جنب مياه ساكنة، ووصفها جملة نوعية (مش رقم أو Score).
- **أوثّق لحظتي** — حصاد اللحظة.
- **حصاد رحلتك** — أرشيف أسبوعي/شهري.
- **سكينة الأسبوع** — مراجعة أسبوعية نوعية.
- **أرشيف المذاكرة**.

### 🧭 البوصلة — اختر اتجاهك
- **حديقة القيم (Value Garden)**: كل قيمة تختارها نبتة بتكبر من أفعال ذات معنى، وبترتاح (Rest) لما تُهمَل لكن **ما بتموتش ولا بتترّاجع أبدًا** — ملاحظة نوعية بدون أي نسب مئوية.
- **غرفة القرار (Decision Room)**: سؤال واحد في كل شاشة — "اختيار أم هروب؟" — والمُخرَج تأمل، مش حُكم.
- بالإضافة لـ: أذاكر، المؤثر الهادئ، وقتك على السوشيال، دخول إنستجرام بنية.

### 🏡 الملجأ — افهم ما تحتاجه الآن
- دخول خافت بسؤال واحد: **"ماذا يحدث داخلك الآن؟"** مع 8 مشاعر: مرهق، حزين، خائف، مشتت، زهقان، محبط، مجهد ذهنيًا، لا أعرف — وكل مشاعر عندها استجابة مختلفة قليلة الاحتكاك (تعب → راحة لا إنتاجية، حزن → دعم + ملاحظة صوتية، خوف → فصل الحقيقة عن التوقع، وهكذا)، خطوة واحدة ثم خروج للحياة.
- **وضع الخلوة (Retreat Mode)**: اترك الموبايل وعيش، بتلميح زمني غير مخيف، وينتهي بسؤال "ماذا حدث خارج الهاتف؟".

كل مساحة من التلاتة دي مبنية على مبدأ واحد: **"كل جلسة داخل رِفْق يجب أن تنتهي بفهم أو قرار أو خروج إلى الحياة. إن لم تفعل، فهي مجرد استهلاك رقمي بلغة هادئة."** ومن هنا: مفيش Feed لا نهائي، مفيش إعلانات، مفيش Leaderboard، مفيش Streaks ولا شعلات نار، ومفيش نبتة بتموت لو غبت — كل البيانات محليّة فقط، والتطبيق شغّال حتى من غير إنترنت.

---

## المزايا المنفَّذة

### الشاشة الرئيسية — الحديقة الحيّة + 3 محاور
شاشة حديقة حيّة (Living Garden) بمشهد أصلي مرسوم (بركة/طريق/شجرة) بيوصلك للمرآة والبوصلة والملجأ، بالإضافة لقسم هادئ اسمه **"أدوات هادئة"** بيجمّع كل الأدوات الأصلية (العودة، التركيز، الحصاد، صانع المحتوى، الدخول الواعي...) في مكان واحد سهل الوصول.

### 🌙 "أنا تايه دلوقتي" — جلسة العودة الموجّهة
- النظر بعيدًا 5 ثوانٍ.
- تنفّس (90 ثانية / 3 دقائق / 5 دقائق) بإيقاع شهيق 4 ثوانٍ - زفير 6 ثوانٍ، مع إمكانية إيقاف الحركة (Animation) لمن يفضّل السكون.
- آية أو ذكر موثّق المصدر.
- سؤال "محتاج إيه دلوقتي؟".
- خطوة صغيرة جدًا للخروج من الجلسة.

### 🎯 "افتح بس" — جلسات التركيز
- مدد جاهزة: 10 / 25 / 45 / 20 دقيقة.
- جملة "إذا-فسوف" (Implementation Intention) قبل البدء.
- إمكانية الإيقاف المؤقت أو الإنهاء المبكر من غير أي رسالة لوم.
- مراجعة استرجاع (Retrieval Practice) بثلاثة أسئلة بعد الجلسة.

### 🌾 حصاد اليوم
- تسجيل إنجازات صغيرة بفئات (دراسة، عادة، حياة أبطأ، معنى، عبادة، صدقة، أسرة، صحة، مالية، أخرى).
- الفئات الخمس الحساسة (عبادة/صدقة/أسرة/صحة/مالية) **خاصة دائمًا افتراضيًا**.
- تأمل مسائي قصير.
- فحص محلي (على الجهاز فقط) لإشارات إيذاء النفس في النص الحر، يعرض رسالة داعمة عامة — من غير تشخيص ومن غير إرسال أي شيء لأي خادم.

### 📝 استوديو صانع المحتوى الهادئ
- بوابة نية وخصوصية: سؤالان + 4 اختيارات قبل توليد أي محتوى.
- محرك قوالب **deterministic بالكامل** (بدون أي ذكاء اصطناعي): Story، Caption، Carousel، سكريبت Reel، حصاد أسبوعي.
- "Value Check" — تأمل صادق (5 أسئلة)، مش Score تنافسي.
- مشاركة عبر Android Share Sheet، حتى 5 هاشتاجات، نسخ النص، حفظ كمسودة، أو "ليس الآن".

### 📲 الدخول الواعي لإنستجرام
- تحديد النية + المدة (5/10/15/20 دقيقة) قبل الدخول.
- فتح `instagram://` أو الموقع كبديل.
- جدولة تنبيه عودة تلقائي.

### 🔔 نظام التنبيهات
- 3 تنبيهات يوميًا كحد أقصى (افتراضيًا).
- احترام كامل لساعات الصمت (حتى العابرة لمنتصف الليل).
- تجاهل 3 مرات متتالية → تقليل الوتيرة تلقائيًا.
- بدون أي كلمة لوم أو تخويف.
- إذن `POST_NOTIFICATIONS` يُطلب في سياقه، مش عند أول فتح للتطبيق.

### 📊 المراجعة الأسبوعية
لغة "ماذا لاحظت؟" بدل الأرقام والمقارنات، اقتراح واحد فقط، ومقياس "سرعة العودة" بدل الـ Streaks.

### 🍂 وضع الفتور — "دخلت في الفتور"
وضع تعاطف لمدة 3 أيام: تنبيه واحد يوميًا، نسخ مختصرة من كل شيء، وتفريق بين فتور طبيعي واستنزاف حقيقي وتجنّب عاطفي — مع نصيحة صريحة بطلب مساعدة مختص لو الأعراض استمرت أسابيع.

### ⚙️ الإعدادات وصفحة الأمان
جدولة التنبيهات، وصفحة أمان واضحة تقول: "ليس علاجًا"، بلا فتاوى وبلا تشخيصات.

### 🎨 نظام التصميم المركزي (Design System)
مكتبة تصميم موحّدة في `lib/design_system/`: ألوان مُرمَّزة (Tokenized) — عاجي دافئ للخلفية (`#F5F1E8`)، أخضر سيچ (`#708A72`)، أخضر غابة عميق (`#365646`)، طيني (Clay، `#C78668`)، رملي، ذهبي، ماء هادئ — بالإضافة لمقياس تباعد (Spacing scale)، أشكال عضوية (Organic shapes)، رموز حركة (Motion tokens)، وتايبوغرافيا مُعايَرة للعربي (خط Cairo، ارتفاع سطر سخي، عناوين بايرة عبر `FontVariation`). فيه كمان `RifqPalette` كـ `ThemeExtension` بيحمل ألوان الحديقة الدلالية، ثيمين (فاتح/داكن) بظلال خضراء ناعمة، مساعد لتفعيل "تقليل الحركة"، ومكوّنات مشتركة جاهزة: `RifqScaffold`, `RifqPageHeader`, `RifqOrganicSurface`, `RifqSection`, `RifqEmptyState`.

---

## لقطات الشاشة

*(لسه معملناش Screenshots رسمية للتطبيق — لو حابب تضيفها، حطها هنا في `docs/screenshots/` واربطها في هذا القسم.)*

---

## تنزيل الـ APK

### الأسهل: من صفحة Releases (v0.4.0)

أحدث نسخة منشورة رسميًا هي **v0.4.0**، ومتاحة مباشرة كـ Release على GitHub:

```
https://github.com/ahmedfrhat2026-svg/ana-awla/releases/download/rifq-v0.4.0/app-arm64-v8a-release.apk
```

نزّل الملف على موبايلك مباشرة، فعّل "التثبيت من مصادر غير معروفة" لو طُلب منك، وثبّته (Sideload).

### أو من GitHub Actions (أحدث بناء تلقائي)

لو عايز آخر تعديل حتى لو لسه ماتعملوش Release رسمي، كل بناء بيتعمل تلقائي عند أي Push على `rifq/**`، أو ممكن تشغّله يدويًا. اتبع الخطوات دي بالظبط:

1. افتح الريبو على GitHub، وادخل تبويب **Actions**.
2. من قائمة الـ Workflows على الشمال، اختر **Build RIFQ APK**.
3. اختر آخر تشغيل ناجح (أعلى القائمة، علامة ✅ خضراء) — أو اضغط **Run workflow** لو عايز تشغّله يدويًا (workflow_dispatch متاح).
4. انزل لقسم **Artifacts** في أسفل صفحة التشغيل، هتلاقي ملف اسمه **rifq-apk**.
5. حمّل الملف (سيبقى بصيغة `.zip`) وفكّه (Unzip) على جهازك.
6. جوّه هتلاقي أكتر من APK:
   - `rifq-debug.apk` — نسخة تصحيح (Debug)، أسرع في التثبيت للتجربة السريعة.
   - نسخ Release مقسّمة حسب المعمارية (split-per-abi)، زي `app-arm64-v8a-release.apk` — دي الأنسب لمعظم أجهزة أندرويد الحديثة (64-bit).
7. انقل الملف لموبايلك، وفعّل "التثبيت من مصادر غير معروفة" (Install unknown apps) لو طُلب منك، وثبّت الـ APK يدويًا (Sideload).

> الأرشفة (Artifact retention) مدتها 90 يوم من تاريخ البناء — لو الرابط قديم، ارجع لتبويب Actions واختر تشغيل أحدث.

---

## البناء والتشغيل محليًا

المتطلبات: Flutter 3.44.7 (أو متوافق)، Android SDK مثبت ومهيّأ (`flutter doctor` نظيف).

```bash
cd rifq
flutter pub get
flutter test
flutter build apk --split-per-abi
```

الـ APK الناتج هيكون في:
`build/app/outputs/flutter-apk/`

> ملاحظة: مجلد `android/` مش موجود بشكل دائم في الريبو — الـ workflow بيولّده تلقائيًا بـ `flutter create --platforms=android` ثم بينسخ `android_overlay/app/` فوقه (الـ AndroidManifest.xml المعدَّل بصلاحيات قليلة، و `build.gradle.kts` بـ `minSdk 23` و core library desugaring). لو بتبني محليًا وميعملش `android/` عندك، شغّل نفس الأمر:
> ```bash
> flutter create --platforms=android --org=com.frhat --project-name=rifq .
> cp -r android_overlay/app/. android/app/
> ```

### تشغيل الاختبارات فقط

```bash
flutter test
```

### فحص الكود

```bash
flutter analyze
```

---

## هيكل المشروع

```
rifq/
├── lib/
│   ├── main.dart
│   ├── design_system/          # ألوان مُرمَّزة، تايبوغرافيا، مكوّنات مشتركة (RifqScaffold...)
│   ├── core/
│   │   ├── theme/            # Material 3 theme + RifqPalette ThemeExtension
│   │   ├── db/                # sqflite: app_database (v4), models, repositories
│   │   ├── notifications/     # NotificationScheduler + NotificationRulesEngine
│   │   ├── content/           # ContentTemplateEngine + sacred_texts + seed_texts
│   │   ├── instagram/         # InstagramLauncher + UsageStatsGateway (flag off)
│   │   ├── privacy/           # PrivacyGate + safety_check (self-harm signal, محلي)
│   │   ├── routing/           # GoRouter
│   │   └── providers.dart     # Riverpod providers (manual، بدون codegen)
│   ├── features/
│   │   ├── onboarding/
│   │   ├── home/               # الحديقة الحيّة (Living Garden) + أدوات هادئة
│   │   ├── mirror/              # المرآة — متحف العودة، حصاد الرحلة، سكينة الأسبوع
│   │   ├── compass/             # البوصلة — حديقة القيم، غرفة القرار
│   │   ├── sanctuary/           # الملجأ — مسارات المشاعر، وضع الخلوة
│   │   ├── reset/              # "أنا تايه دلوقتي"
│   │   ├── focus/               # "افتح بس"
│   │   ├── harvest/             # حصاد اليوم
│   │   ├── quiet_creator/       # استوديو المحتوى الهادئ
│   │   ├── intentional_entry/   # الدخول الواعي لإنستجرام
│   │   ├── weekly_review/
│   │   ├── fatigue/             # وضع الفتور
│   │   └── settings/
│   └── shared/                  # Widgets مشتركة
├── test/                         # 84 اختبار (unit + widget) + fakes.dart
├── android_overlay/              # AndroidManifest.xml + build.gradle.kts المخصّصة
└── docs/
    ├── architecture.md
    └── privacy.md
```

---

## ما تم تنفيذه vs ما تبقى

| الحالة | العنصر |
|---|---|
| ✅ تم | Onboarding (5 صفحات، بدون طلب أي صلاحية) |
| ✅ تم | الشاشة الرئيسية — الحديقة الحيّة (Living Garden) + الأنظمة الثلاثة (المرآة، البوصلة، الملجأ) + "أدوات هادئة" |
| ✅ تم | نظام التصميم المركزي `lib/design_system/` (ألوان مُرمَّزة، تايبوغرافيا عربية، مكوّنات مشتركة، ثيم فاتح/داكن) |
| ✅ تم | المرآة: متحف العودة، أوثّق لحظتي، حصاد رحلتك، سكينة الأسبوع، أرشيف المذاكرة |
| ✅ تم | البوصلة: حديقة القيم (قيم لا تموت ولا تتراجع)، غرفة القرار ("اختيار أم هروب؟") |
| ✅ تم | الملجأ: مسارات المشاعر الثمانية بخطوة واحدة، وضع الخلوة |
| ✅ تم | جلسة العودة الموجّهة الكاملة (نظر بعيد، تنفّس، ذكر/آية، سؤال، خطوة صغيرة) |
| ✅ تم | جلسات التركيز (presets، implementation intention، مراجعة استرجاع) |
| ✅ تم | حصاد اليوم + التأمل المسائي + فحص إيذاء النفس المحلي |
| ✅ تم | استوديو صانع المحتوى (قوالب deterministic، بوابة خصوصية، Value Check) |
| ✅ تم | الدخول الواعي لإنستجرام (نية + مدة + تنبيه عودة) |
| ✅ تم | نظام التنبيهات (حد يومي، ساعات صمت، تقليل وتيرة عند التجاهل) |
| ✅ تم | المراجعة الأسبوعية (لغة "ماذا لاحظت؟"، بدون Streaks) |
| ✅ تم | وضع الفتور (3 أيام رحمة) |
| ✅ تم | الإعدادات + جدولة التنبيهات + صفحة الأمان |
| ✅ تم | قاعدة البيانات schema v4 (جدول `life_value` جديد للبوصلة) |
| ✅ تم | 84 اختبار (unit + widget) و `flutter analyze` نظيف |
| ✅ تم | بناء APK تلقائي عبر GitHub Actions (debug + release split-per-abi) + Release رسمي v0.4.0 |
| ❌ لسه لأ | Calm Day Designer |
| ❌ لسه لأ | كبسولات الوقت (Time capsules) |
| ❌ لسه لأ | نمو تلقائي لقيم البوصلة من أفعال التركيز/العودة (حاليًا النمو يدوي حسب الأفعال المسجَّلة) |
| ❌ لسه لأ | الملاحظات الصوتية (Voice notes) |
| ❌ لسه لأ | ضوضاء بيضاء (White noise audio) |
| ❌ لسه لأ | تكامل UsageStatsManager الفعلي (الواجهة موجودة، الـ Feature Flag مقفول) |
| ❌ لسه لأ | نشر تلقائي عبر Instagram API (المشاركة حاليًا عبر Share Sheet فقط) |
| ❌ لسه لأ | نسخة iOS |
| ❌ لسه لأ | مزامنة سحابية مشفّرة (Supabase) |
| ❌ لسه لأ | أي مساعدة نصية بالذكاء الاصطناعي (LLM) |
| ❌ لسه لأ | ربط تجاهل التنبيهات الفعلي من نظام أندرويد (منطق العداد موجود ومُختبَر، لكن مفيش ربط حقيقي مع OS tap callbacks) |
| ❌ لسه لأ | واجهة جدولة تذكير حصاد يوم الجمعة لكل فئة — حاليًا أساسية فقط |

---

## تنبيه أمان وحدود التطبيق

رِفْق **ليس علاجًا نفسيًا ولا بديلاً عن مختص**. لا يقدّم فتاوى ولا تشخيصات طبية أو نفسية. لو ظهرت إشارات جدّية في أي نص (مثل إيذاء النفس)، التطبيق بيعرض رسالة داعمة عامة بس، وبيحثّك تتواصل فورًا مع شخص تثق فيه أو خدمة طوارئ محلية. راجع `docs/privacy.md` وصفحة "الأمان" داخل التطبيق لمزيد من التفاصيل.

## ملخص الخصوصية

كل البيانات محفوظة محليًا على جهازك فقط (قاعدة sqflite). لا حسابات، لا تتبّع، لا إعلانات، لا مزامنة سحابية. التطبيق يعمل بالكامل من غير إنترنت. التفاصيل الكاملة في [`docs/privacy.md`](docs/privacy.md).

---
---

# English

**Come back to yourself, gently.**

RIFQ is a fully Arabic-first, RTL Android companion app that helps you step away from endless scrolling, study with calm focus, log small daily wins, and create Instagram content intentionally — instead of opening the app "just to check" and losing an hour.

No infinite feed, no ads, no leaderboards, no shame-inducing streak flames. All data stays local on your device, and the app works fully offline.

## v0.4.0: three connected spaces

As of v0.4.0, RIFQ is reorganized around **three connected spaces**, surfaced on a new living-garden home screen — an original `CustomPainter` scene (reflective pool, stone path, sheltered olive tree) with time-of-day light and barely-there ambient motion that pauses on background and under reduced-motion:

- **المرآة (Mirror)** — reflect on what you've lived: Museum of Returning (each completed reset becomes a stone by still water, described in a qualitative sentence, never a score), moment harvesting, weekly/monthly journey archive, weekly qualitative review, study archive.
- **البوصلة (Compass)** — choose your direction: Value Garden (each chosen value is a plant that grows from meaningful actions and rests but never dies or regresses when neglected — qualitative observation, no percentages), Decision Room (one question per screen, "choice or escape?", output is a reflection, not a verdict), plus focus sessions, the calm influencer tool, social-time awareness, and intentional Instagram entry.
- **الملجأ (Sanctuary)** — understand what you need right now: a dim one-question entry ("what's happening inside you right now?") across 8 emotions, each with a different low-friction response, one step then exit to life; Retreat Mode (put the phone down and go live, ending with "what happened outside the phone?").

Product principle: *"Every session inside RIFQ must end in understanding, a decision, or a return to life. If it doesn't, it's just digital consumption in a calm voice."* No infinite feed, no ads, no leaderboards, no streaks, no plant ever dies from being away, all data local-only, fully offline.

A new centralized design system lives in `lib/design_system/`: tokenized colors, spacing, organic shapes, motion tokens, Arabic-tuned typography, a `RifqPalette` theme extension, light/dark themes, and shared components.

## Stack

Flutter 3.44.7, Dart null-safety, Material 3, Riverpod (manual providers, no codegen), GoRouter, sqflite (chosen deliberately over Drift to avoid build_runner codegen — a proven pattern in this repo, now at schema v4), flutter_local_notifications (inexact alarms only), timezone, share_plus, image_picker, url_launcher, permission_handler, intl.

## Feature summary

Home (living-garden scene + the three spaces + a quiet "أدوات هادئة" tools section), onboarding, guided reset flow ("أنا تايه دلوقتي" — look-away, breathing, verified dhikr/ayah, tiny action), focus sessions ("افتح بس" — presets, implementation intentions, retrieval practice), daily harvest (small wins with sensitive-by-default categories, evening reflection, local-only self-harm signal check), quiet content creator studio (deterministic templates, privacy gate, value check, Share Sheet), intentional Instagram entry, a considerate notification system (max 3/day, quiet hours, ignore-based frequency reduction), weekly review (no streaks), and a 3-day fatigue/compassion mode. All prior features remain implemented and reachable.

## Getting the APK

Latest official release, **v0.4.0**: download directly from GitHub Releases —
```
https://github.com/ahmedfrhat2026-svg/ana-awla/releases/download/rifq-v0.4.0/app-arm64-v8a-release.apk
```
Or for the latest CI build: GitHub Actions → **Build RIFQ APK** workflow → latest successful run → **Artifacts** section → download **rifq-apk** → unzip → sideload `rifq-debug.apk` (quick) or the `arm64-v8a` release APK (recommended for most modern Android phones).

## Local build

```bash
cd rifq
flutter pub get
flutter test
flutter build apk --split-per-abi
```

Requires Android SDK configured (`flutter doctor` clean). See the Arabic section above for the one-time `android/` scaffolding step if building outside CI.

## Tests

84 passing tests (unit + widget, including the new Mirror/Compass/Sanctuary logic and accessibility/large-text checks). `flutter analyze` is clean.

## Honest status

Implemented: everything listed above, end to end, with local sqflite persistence (schema v4) and a working GitHub Actions build pipeline producing both debug and release (split-per-ABI) APKs, plus an official v0.4.0 GitHub Release.

Not implemented yet: Calm Day Designer, time capsules, auto-growth of Compass values from focus/reset actions (growth is currently driven by explicitly logged actions), voice notes, white noise audio, real UsageStatsManager integration (interface exists, feature flag off), auto-posting via the Instagram API (sharing is via the Android Share Sheet only), iOS, encrypted cloud sync, any LLM/AI-assisted text generation, wiring the notification-ignore counter to real OS-level notification tap callbacks (the counting logic exists and is tested, just not wired to the OS), and a richer per-category Friday harvest reminder scheduling UI (currently basic).

## Safety and privacy

Not a substitute for therapy, medical, or religious guidance — no diagnoses, no fatwas. All data is local-only, no accounts, no telemetry, no ads. See [`docs/privacy.md`](docs/privacy.md) for full details.
