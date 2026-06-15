# أنا أولى — متتبع المصروفات الشخصي

تطبيق Android شخصي ومحلي تماماً (local-first) لتتبّع المصروفات اليومية، يقلّل الصرف الاندفاعي ويبني عادة ادخار.

**المميزات الرئيسية:**
- إدخال سريع بالعربية: "قهوة 85 كاش" → يفهم المبلغ، التصنيف، وطريقة الدفع تلقائياً.
- ميزانية يومية مع شريط تقدم وتنبيه عند 80%.
- زر **كنت هاصرف** لتسجيل ادخار المقاومة (الحاجة اللي ماشتريتهاش).
- زر **قبل ما أدفع** بـ 3 أسئلة عقلانية وحُكم تلقائي.
- **قاعدة الـ 24 ساعة** لأي مبلغ فوق حدّ تختاره.
- **عداد الأيام النظيفة** (بدون صرف اندفاعي).
- صندوق **«أنا أولى»** يجمع كل المبالغ اللي وفّرتها.
- تنبيهات يومية (صباحاً، بعد الظهر، مساءً، قبل النوم) — أوقاتها قابلة للتعديل.
- تصدير CSV لكل البيانات.
- تخزين محلي بالكامل (SQLite) — لا حسابات، لا سحابة، لا مصادقة.

---

## 🚀 إزاي تحصل على ملف الـ APK بدون ما تنصّب أي حاجة

التطبيق يُبنى تلقائياً في السحابة عبر GitHub Actions. خطوة واحدة بس:

### 1) ارفع المجلد ده على GitHub

افتح [github.com/new](https://github.com/new) واعمل repo جديد فاضي (private لو حابب).

بعدها افتح PowerShell جوّا مجلد المشروع وشغّل:

```powershell
git init
git add .
git commit -m "أنا أولى v1"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/ana-awla.git
git push -u origin main
```

(لو git مش مثبت: نزّله من [git-scm.com/download/win](https://git-scm.com/download/win) — تثبيت عادي Next-Next.)

### 2) استنى البناء ينتهي

- ادخل على repo بتاعك في GitHub.
- روح تاب **Actions**.
- هتلاقي run بعنوان "Build APK" شغّال. بياخد حوالي **5–8 دقايق**.

### 3) نزّل الـ APK

- بعد ما الـ run يخلص (✅ أخضر)، افتحه.
- في آخر الصفحة قسم **Artifacts**.
- اضغط `ana-awla-apk` → ينزّل zip فيه الـ APK.

### 4) نصّب الـ APK على موبايلك

- انقل الملف للموبايل (واتساب لنفسك، USB، أو Google Drive).
- افتحه من File Manager.
- لو ظهرت رسالة "Install from unknown sources"، فعّلها من الإعدادات.
- اضغط Install. خلاص — التطبيق على موبايلك.

### 5) عند أول فتح

- اقبل صلاحية الإشعارات.
- ادخل على **الإعدادات** وعدّل: الدخل الشهري، هدف الادخار، ميزانية اليوم.
- جرّب اكتب أول مصروف من الشاشة الأولى.

---

## 🔁 لما تعدّل في الكود

أي تعديل تدفعه (push) لـ main → GitHub Actions يبني APK جديد تلقائياً. تنزّله من Actions زي أول مرة.

لو عاوز إصدار رسمي بـ tag:
```powershell
git tag v1.1
git push origin v1.1
```
هيتعمل Release في GitHub فيه الـ APK جاهز للتنزيل المباشر.

---

## 🧰 لو حابب تبني محلياً (اختياري)

لو نصّبت Flutter SDK، تقدر تبني بنفسك:

```powershell
flutter create --platforms=android --org=com.frhat --project-name=ana_awla .
Copy-Item android_overlay\app\src\main\AndroidManifest.xml android\app\src\main\AndroidManifest.xml -Force
flutter pub get
flutter build apk --release
```

الـ APK هيظهر في: `build\app\outputs\flutter-apk\app-release.apk`

---

## 🧪 اختبار الـ parser

```powershell
flutter test
```

---

## 📁 بنية المشروع

```
lib/
  main.dart                  # Shell + Bottom nav
  theme.dart                 # ألوان وخطوط
  db/
    models.dart              # Expense, Saving, WaitingItem, Rule
    database.dart            # SQLite + seed data
  services/
    parser.dart              # Arabic text → ParsedInput
    budget.dart              # حسابات الميزانية والإحصائيات
    notifications.dart       # flutter_local_notifications wrapper
  screens/
    today_screen.dart        # شاشة اليوم
    insights_screen.dart     # التحليلات
    rules_screen.dart        # قواعد التصنيف
    settings_screen.dart     # الإعدادات
  widgets/
    before_pay_sheet.dart    # «قبل ما أدفع»
    save_sheet.dart          # «كنت هاصرف»
    regret_picker.dart       # تقييم المصروف
    money.dart               # تنسيق العملة

test/
  parser_test.dart           # اختبارات الـ parser

android_overlay/             # ملف Manifest مخصص بصلاحيات الإشعارات
.github/workflows/
  build-apk.yml              # workflow بناء APK
```

---

## 🛠 تعديلات شخصية

- **عدّل الكلمات والتصنيفات**: من شاشة **قواعد** داخل التطبيق.
- **غيّر أوقات التنبيهات**: من شاشة **الإعدادات**.
- **عدّل التصاميم/الألوان**: في `lib/theme.dart`.
- **أضف تصنيفات مبدئية**: في `lib/db/database.dart` داخل دالة `_seed`.

---

## 🔐 الخصوصية

كل البيانات محفوظة محلياً على جهازك في SQLite. لا يوجد سيرفر، لا تليمتري، لا API خارجية. لو غيّرت الموبايل تقدر تعمل **تصدير CSV** من الإعدادات وتنقله.

---

صُمّم لشخص واحد. غيّر فيه براحتك.
