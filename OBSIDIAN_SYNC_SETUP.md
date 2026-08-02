# Obsidian ↔ Google Drive Sync

أداة مزامنة تلقائية بين ملفات Obsidian على موبايلك واللابتوب عبر Google Drive.

## المميزات

- ✅ **مزامنة ثنائية الاتجاه**: كل ما تضيفه على الموبايل ينتقل للابتوب والعكس
- ✅ **تلقائية تماماً**: كل 15 دقيقة
- ✅ **آمنة**: بيانات محلية فقط، بدون سيرفرات وسيطة
- ✅ **ذكية**: تتتبع التغييرات فقط (بدون تحميل الملفات بلا فائدة)
- ✅ **سهلة الإعداد**: 5 خطوات فقط

## المتطلبات

- Python 3.8+
- حساب Google Drive
- Obsidian على الموبايل واللابتوب
- الإنترنت

## خطوات الإعداد

### 1️⃣ تثبيت Python والمتطلبات

**Windows:**
```powershell
# افتح PowerShell كـ Admin
python --version  # تأكد من أن Python مثبت

# انتقل لمجلد المشروع
cd path/to/ana-awla
pip install -r requirements.txt
```

**macOS/Linux:**
```bash
python3 --version
cd path/to/ana-awla
pip3 install -r requirements.txt
```

### 2️⃣ إنشاء Google Cloud Project

1. اذهب إلى: https://console.cloud.google.com/
2. اضغط **Create Project** (أعلى يسار)
3. اسم المشروع: `Obsidian Sync`
4. اضغط **Create**

### 3️⃣ تفعيل Google Drive API

1. اذهب إلى: https://console.cloud.google.com/apis/library
2. ابحث عن **Google Drive API**
3. اضغط عليها ثم **Enable**

### 4️⃣ إنشاء OAuth Credentials

1. اذهب إلى: https://console.cloud.google.com/apis/credentials
2. اضغط **+ Create Credentials** (أعلى)
3. اختر **OAuth client ID**
4. في الـ warning، اضغط **Configure Consent Screen**
5. اختر **External** وضغط **Create**

**في شاشة Consent Screen:**
- Fill App name: `Obsidian Sync`
- User support email: ايميلك
- Developer contact: ايميلك
- اضغط **Save and Continue**

**في Scopes:**
- اضغط **Add or Remove Scopes**
- ابحث عن: `drive.file`
- اختره وضغط **Update**
- اضغط **Save and Continue** مرتين

**في Test Users:**
- اضغط **Add Users**
- أضف ايميلك (ايميل Gmail الخاص بـ Google Drive)
- اضغط **Save and Continue**

### 5️⃣ تحميل Credentials

1. اذهب لـ: https://console.cloud.google.com/apis/credentials
2. تحت **OAuth 2.0 Client IDs**، اضغط على Desktop app اللي أنشأته للتو
3. اضغط **Download as JSON** (آخر الصفحة)
4. حفظ الملف باسم `credentials.json`
5. انقل الملف إلى مجلد المشروع (نفس المستوى مع `obsidian_sync.py`)

### 6️⃣ الإعداد الأول

**Windows:**
```powershell
python obsidian_sync.py --setup
```

**macOS/Linux:**
```bash
python3 obsidian_sync.py --setup
```

سيطلب منك:
- مسار مجلد Obsidian (مثل: `C:\Users\YourName\Obsidian`)
- ثم سيفتح متصفح لتسجيل دخول Google
- اضغط **Allow** عند الطلب

### 7️⃣ ابدأ المزامنة

**خيار أ: مزامنة واحدة الآن**
```powershell
python obsidian_sync.py --sync
```

**خيار ب: تشغيل المزامنة التلقائية**
```powershell
python obsidian_sync.py --daemon
```
سيبقى يعمل في الخلفية ويزامن كل 15 دقيقة.

**خيار ج: عرض حالة المزامنة**
```powershell
python obsidian_sync.py --status
```

## تشغيل تلقائي عند بدء Windows

**الطريقة 1: Task Scheduler (موصى به)**

1. اضغط `Windows + R`
2. اكتب: `taskschd.msc` واضغط Enter
3. على اليمين: **Create Basic Task**
4. الاسم: `Obsidian Sync`
5. الوصف: `Automatic sync between Obsidian and Google Drive`
6. **Trigger**: اختر **At log on**
7. **Action**: اختر **Start a program**
   - Program: `C:\Windows\System32\python.exe` (أو مسار Python عندك)
   - Arguments: `"C:\path\to\obsidian_sync.py" --daemon`
   - Start in: `C:\path\to\ana-awla`
8. ✅ اضغط Finish

**الطريقة 2: Batch Script**

أنشئ ملف `start_sync.bat` في مجلد المشروع:

```batch
@echo off
cd /d "C:\path\to\ana-awla"
python obsidian_sync.py --daemon
```

ثم:
1. اضغط `Windows + R`
2. اكتب: `shell:startup`
3. انقل اختصار `start_sync.bat` هناك

## تشغيل تلقائي على macOS

أنشئ ملف `~/Library/LaunchAgents/com.obsidian.sync.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.obsidian.sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/python3</string>
        <string>/path/to/obsidian_sync.py</string>
        <string>--daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

ثم:
```bash
launchctl load ~/Library/LaunchAgents/com.obsidian.sync.plist
```

## تشغيل تلقائي على Linux

أنشئ ملف `~/.config/systemd/user/obsidian-sync.service`:

```ini
[Unit]
Description=Obsidian Google Drive Sync
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /path/to/obsidian_sync.py --daemon
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

ثم:
```bash
systemctl --user enable obsidian-sync
systemctl --user start obsidian-sync
```

## الملفات والمجلدات

بعد الإعداد، ستجد:

```
~/.obsidian_sync/
  ├── config.json      # إعدادات المزامنة
  ├── token.pickle     # رمز Google OAuth (خاص)
  ├── manifest.json    # سجل الملفات والـ hashes
  └── sync.log         # ملف السجل
```

على Google Drive:
```
My Drive/
  └── Obsidian-Sync/   # المجلد الرئيسي
      └── [نفس هيكل Obsidian الخاص بك]
```

## استكشاف الأخطاء

### خطأ: "Credentials file not found"
- تأكد من حفظ `credentials.json` في مجلد المشروع
- أعد تحميل الملف من Google Cloud Console

### خطأ: "Invalid grant"
- احذف ملف `~/.obsidian_sync/token.pickle`
- شغّل البرنامج مرة أخرى (سيطلب تسجيل الدخول)

### لم تظهر الملفات على Google Drive
- تأكد من مسار مجلد Obsidian الصحيح
- افتح `~/.obsidian_sync/sync.log` لرؤية تفاصيل الأخطاء
- شغّل `python obsidian_sync.py --status` لرؤية الحالة

### الأداء بطيء جداً
- قلل عدد الملفات في Obsidian (نقل الملفات القديمة)
- زيادة `SYNC_INTERVAL` من 15 دقيقة لـ 30 أو 60 دقيقة
  - عدّل في `obsidian_sync.py`، غير السطر: `SYNC_INTERVAL = 15 * 60`

## الأوامر السريعة

```powershell
# التحقق من الإعداد
python obsidian_sync.py --status

# مزامنة واحدة الآن
python obsidian_sync.py --sync

# تشغيل المزامنة المستمرة
python obsidian_sync.py --daemon

# عرض آخر 50 سطر من السجل
Get-Content $env:USERPROFILE\.obsidian_sync\sync.log -Tail 50
```

## التحقق من المزامنة

1. أضف ملف جديد في Obsidian على الموبايل
2. انتظر 15 دقيقة (أو شغّل `--sync`)
3. تحقق من Google Drive: يجب أن تراه في `Obsidian-Sync/`
4. تحقق من اللابتوب: يجب أن يظهر الملف في مجلد Obsidian

## الأمان والخصوصية

- ✅ كل البيانات مشفرة بين جهازك و Google Drive (HTTPS)
- ✅ لا توجد نسخة عند طرف ثالث أو server وسيط
- ✅ رمز الوصول (token) محفوظ محلياً فقط
- ✅ يمكنك سحب الوصول أي وقت من Google Account Settings

## تحديثات مستقبلية

يمكن إضافة:
- Sync المحذوفات (حالياً يتم sync الإضافات والتعديلات فقط)
- Conflict resolution (في حالة تعديل نفس الملف في نفس الوقت)
- Selective sync (اختيار مجلدات محددة للمزامنة)

## الدعم

للمساعدة:
1. تحقق من `~/.obsidian_sync/sync.log`
2. نسخ رسالة الخطأ
3. تأكد من:
   - الإنترنت متصل
   - Google Drive متاح
   - Python مثبت بشكل صحيح

---

**ملاحظة أخيرة**: البرنامج آمن تماماً ولن يحذف أي ملفات إذا لم تطلب ذلك. كل ملف له نسخة احتياطية على Google Drive و الجهاز الآخر.
