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

/// واجهة مستقبلية اختيارية لقياس استخدام التطبيقات عبر UsageStatsManager.
/// متروكة خلف Feature Flag مغلق في الـ MVP — لا تُستخدم أي صلاحيات حساسة.
abstract interface class UsageStatsGateway {
  Future<bool> get hasPermission;
  Future<Duration> usageToday(String packageName);
}

/// Feature flag — مغلق في الـ MVP عمدًا.
const bool usageStatsEnabled = false;
