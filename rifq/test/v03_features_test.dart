import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/core/app_info.dart';
import 'package:rifq/core/db/models.dart';

import 'fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('رقم النسخة', () {
    test('appVersion متطابق مع pubspec.yaml', () {
      final line = File('pubspec.yaml')
          .readAsLinesSync()
          .firstWhere((l) => l.startsWith('version:'));
      final version = line.split(':')[1].trim().split('+').first;
      expect(appVersion, version,
          reason: 'حدّث appVersion في app_info.dart مع pubspec');
    });

    test('«ما الجديد» فيه إدخال للنسخة الحالية', () {
      expect(whatsNew.containsKey(appVersion), isTrue);
      expect(whatsNew[appVersion]!, isNotEmpty);
    });
  });

  group('إعدادات v3', () {
    test('roundtrip يحفظ النسخة المشاهدة وحد السوشيال', () {
      const s = UserSettings(
        lastSeenVersion: '0.3.0',
        socialLimitMinutes: 45,
      );
      final restored = UserSettings.fromMap(s.toMap());
      expect(restored.lastSeenVersion, '0.3.0');
      expect(restored.socialLimitMinutes, 45);
    });

    test('القيم الافتراضية آمنة', () {
      const s = UserSettings();
      expect(s.lastSeenVersion, '');
      expect(s.socialLimitMinutes, 60);
    });
  });

  group('نماذج الصوت', () {
    test('Reflection يحفظ مسار الصوت', () {
      const r = Reflection(date: '2026-07-21', voicePath: '/x/voice.m4a');
      expect(Reflection.fromMap(r.toMap()).voicePath, '/x/voice.m4a');
    });

    test('FocusSession يحفظ الصورة والصوت معًا', () {
      const s = FocusSession(
        subject: 'أحياء',
        task: '',
        tinyStep: 'صفحة',
        plannedMinutes: 10,
        notesImagePath: '/x/img.jpg',
        voiceNotePath: '/x/v.m4a',
      );
      final r = FocusSession.fromMap(s.toMap());
      expect(r.notesImagePath, '/x/img.jpg');
      expect(r.voiceNotePath, '/x/v.m4a');
    });
  });

  group('مراقبة الاستخدام (fake)', () {
    test('بلا صلاحية: الاستخدام null', () async {
      final gw = FakeUsageStatsGateway()..permission = false;
      expect(await gw.hasPermission, isFalse);
      expect(await gw.usageTodayMinutes('com.instagram.android'), isNull);
    });

    test('بصلاحية: يرجّع الدقائق', () async {
      final gw = FakeUsageStatsGateway()
        ..permission = true
        ..minutes = 73;
      expect(await gw.usageTodayMinutes('com.instagram.android'), 73);
    });
  });
}
