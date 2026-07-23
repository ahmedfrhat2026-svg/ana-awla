import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// واجهة فتح إنستجرام — تُستبدل بتنفيذ وهمي في الاختبارات.
abstract interface class InstagramLauncher {
  /// يفتح تطبيق إنستجرام إن كان مثبتًا، وإلا يفتح الموقع في المتصفح.
  Future<bool> open();
}

class UrlInstagramLauncher implements InstagramLauncher {
  const UrlInstagramLauncher();

  @override
  Future<bool> open() async {
    final appUri = Uri.parse('instagram://app');
    if (await canLaunchUrl(appUri)) {
      return launchUrl(appUri, mode: LaunchMode.externalApplication);
    }
    return launchUrl(
      Uri.parse('https://www.instagram.com/'),
      mode: LaunchMode.externalApplication,
    );
  }
}

/// قياس استخدام التطبيقات عبر UsageStatsManager (أندرويد فقط).
/// كل الوصول اختياري بالكامل: يعمل فقط بعد أن يمنح المستخدم Usage Access
/// يدويًا من إعدادات أندرويد. لا يُقرأ أي محتوى — فقط مدة الاستخدام.
abstract interface class UsageStatsGateway {
  Future<bool> get hasPermission;

  /// يفتح شاشة إعدادات Usage Access ليمنح المستخدم الصلاحية بنفسه.
  Future<void> openPermissionSettings();

  /// دقائق استخدام حزمة معيّنة اليوم، أو null لو الصلاحية غير ممنوحة.
  Future<int?> usageTodayMinutes(String packageName);
}

/// حزمة إنستجرام على أندرويد.
const String instagramPackage = 'com.instagram.android';

class MethodChannelUsageStats implements UsageStatsGateway {
  const MethodChannelUsageStats();

  static const _channel = MethodChannel('rifq/usage');

  @override
  Future<bool> get hasPermission async {
    try {
      return await _channel.invokeMethod<bool>('hasPermission') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> openPermissionSettings() async {
    try {
      await _channel.invokeMethod('openSettings');
    } on PlatformException {
      // لا نكسر التطبيق لو الشاشة مش متاحة على جهاز معيّن.
    }
  }

  @override
  Future<int?> usageTodayMinutes(String packageName) async {
    try {
      final minutes = await _channel
          .invokeMethod<int>('usageTodayMinutes', {'package': packageName});
      // القناة تُعيد -1 عند غياب الصلاحية.
      if (minutes == null || minutes < 0) return null;
      return minutes;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
