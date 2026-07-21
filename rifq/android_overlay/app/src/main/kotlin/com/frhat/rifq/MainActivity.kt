package com.frhat.rifq

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

/// جسر أصلي بسيط لقياس وقت استخدام التطبيقات عبر UsageStatsManager.
/// لا يستخدم أي مكتبة خارجية، ولا يقرأ محتوى أي تطبيق — فقط مدة الاستخدام،
/// وبعد أن يمنح المستخدم صلاحية Usage Access يدويًا من إعدادات أندرويد.
class MainActivity : FlutterActivity() {
    private val channel = "rifq/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasUsagePermission())
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(true)
                    }
                    "usageTodayMinutes" -> {
                        val pkg = call.argument<String>("package") ?: ""
                        result.success(usageTodayMinutes(pkg))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.unsafeCheckOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /// إجمالي دقائق استخدام حزمة معيّنة منذ منتصف الليل.
    private fun usageTodayMinutes(targetPackage: String): Int {
        if (!hasUsagePermission() || targetPackage.isEmpty()) return -1
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val start = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
        val now = System.currentTimeMillis()
        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, start, now
        ) ?: return 0
        val totalMs = stats
            .filter { it.packageName == targetPackage }
            .sumOf { it.totalTimeInForeground }
        return (totalMs / 60000L).toInt()
    }
}
