package com.movereai.movere_ai

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

// Movere usage-stats platform kanali:
// Dart tarafindaki UsageStatsService bu kanalla konusur.
class MainActivity : FlutterActivity() {
    private val channelName = "movere/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasUsagePermission())
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(true)
                    }
                    "getTopApps" ->
                        result.success(getTopApps(call.argument<Int>("count") ?: 10))
                    else -> result.notImplemented()
                }
            }
    }

    // Kullanim erisimi izni verilmis mi? (AppOps uzerinden kontrol edilir)
    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    // Bugun gece yarisindan simdiye: uygulama basina on-plan suresi,
    // cok kullanilandan aza sirali ilk [count] kayit.
    private fun getTopApps(count: Int): List<Map<String, Any>> {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
        }
        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, cal.timeInMillis, System.currentTimeMillis()
        ) ?: return emptyList()

        // Uygulama basina: toplam on-plan suresi + en son kullanim zamani.
        data class Agg(var ms: Long = 0L, var lastUsed: Long = 0L)
        val agg = HashMap<String, Agg>()
        for (s in stats) {
            val a = agg.getOrPut(s.packageName) { Agg() }
            a.ms += s.totalTimeInForeground
            if (s.lastTimeUsed > a.lastUsed) a.lastUsed = s.lastTimeUsed
        }
        // Haydar'in istegi birebir: SON KULLANILAN 10 uygulama
        // (en yeni kullanim zamanina gore sirali), sureleriyle birlikte.
        return agg.filter { it.value.ms > 60_000 }
            .toList()
            .sortedByDescending { it.second.lastUsed }
            .take(count)
            .map { (pkg, a) ->
                val ms = a.ms
                val label = try {
                    packageManager
                        .getApplicationLabel(packageManager.getApplicationInfo(pkg, 0))
                        .toString()
                } catch (e: Exception) {
                    pkg.substringAfterLast('.')
                }
                val c = Calendar.getInstance().apply { timeInMillis = a.lastUsed }
                val hh = c.get(Calendar.HOUR_OF_DAY).toString().padStart(2, '0')
                val mm = c.get(Calendar.MINUTE).toString().padStart(2, '0')
                mapOf(
                    "package" to pkg, "name" to label,
                    "minutes" to (ms / 60_000).toInt(),
                    "lastUsed" to "$hh:$mm"
                )
            }
    }
}
