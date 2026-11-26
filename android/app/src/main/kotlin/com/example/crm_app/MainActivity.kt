package com.vtindex.crm

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.Display
import android.view.WindowManager
import androidx.core.content.ContextCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.vtindex.crm.R
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val LIVE_CHANNEL = "com.vtindex.crm/live_updates"
    private val DISPLAY_CHANNEL = "com.vtindex.crm/display_mode"
    private val HAPTICS_CHANNEL = "com.vtindex.crm/haptics"
    private val LIVE_CHANNEL_ID = "vt_live_updates_channel"

    override fun onResume() {
        super.onResume()
        // Automatically adapt to the highest refresh rate supported by device settings when app resumes
        adaptToHighestRefreshRate()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createLiveNotificationChannel()
        adaptToHighestRefreshRate()

        // Display refresh rate adaptation channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DISPLAY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAvailableModes" -> {
                    result.success(getSupportedDisplayModes())
                }
                "getActiveMode" -> {
                    result.success(getActiveDisplayMode())
                }
                "setHighRefreshRate" -> {
                    val applied = adaptToHighestRefreshRate()
                    result.success(applied)
                }
                "setPreferredMode" -> {
                    val modeId = call.argument<Int>("modeId")
                    if (modeId != null) {
                        val applied = setDisplayMode(modeId)
                        result.success(applied)
                    } else {
                        result.error("INVALID_ARG", "modeId is required", null)
                    }
                }
                "setDeviceDefault" -> {
                    val applied = resetToDefaultDisplayMode()
                    result.success(applied)
                }
                else -> result.notImplemented()
            }
        }

        // Tactile vibration channel backed by Android Vibrator service
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HAPTICS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibrate" -> {
                    val durationMs = (call.argument<Number>("durationMs")?.toLong() ?: 18L).coerceIn(5L, 120L)
                    val amplitude = (call.argument<Number>("amplitude")?.toInt() ?: 140).coerceIn(1, 255)
                    result.success(triggerHapticPulse(durationMs, amplitude))
                }
                else -> result.notImplemented()
            }
        }

        // Live notification channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LIVE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLiveUpdate", "updateLiveUpdate" -> {
                    val id = call.argument<Int>("id") ?: 7777
                    val title = call.argument<String>("title") ?: "VT Index Live"
                    val body = call.argument<String>("body") ?: "Live update active"
                    val subText = call.argument<String>("subText") ?: "LIVE"
                    val shortText = call.argument<String>("shortText") ?: "LIVE"
                    val colorHex = call.argument<String>("colorHex") ?: "#10B981"
                    val iconType = call.argument<String>("iconType") ?: "trade"
                    val usesChronometer = call.argument<Boolean>("usesChronometer") ?: false
                    val startedAtMillis = call.argument<Long>("startedAtMillis")

                    val posted = postPromotedNotification(
                        id, title, body, subText, shortText, colorHex, iconType,
                        usesChronometer, startedAtMillis
                    )
                    result.success(posted)
                }
                "stopLiveUpdate" -> {
                    val id = call.argument<Int>("id") ?: 7777
                    cancelLiveNotification(id)
                    result.success(true)
                }
                "startPositionService" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            val permissionCheck = ContextCompat.checkSelfPermission(
                                this,
                                android.Manifest.permission.POST_NOTIFICATIONS
                            )
                            if (permissionCheck != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                                result.success(false)
                                return@setMethodCallHandler
                            }
                        }
                        val serviceIntent = Intent(this, TradeLiveUpdateService::class.java).apply {
                            putExtra("url", call.argument<String>("url"))
                            putExtra("host", call.argument<String>("host"))
                            putExtra("accountId", call.argument<String>("accountId"))
                            putExtra("positionId", call.argument<String>("positionId"))
                            putExtra("accountsJson", call.argument<String>("accountsJson"))
                            putExtra("symbol", call.argument<String>("symbol"))
                            putExtra("side", call.argument<String>("side"))
                            putExtra("lots", call.argument<String>("lots"))
                            putExtra("startedAt", call.argument<Long>("startedAt") ?: System.currentTimeMillis())
                        }
                        ContextCompat.startForegroundService(this, serviceIntent)
                        result.success(true)
                    } catch (error: Exception) {
                        result.error("POSITION_SERVICE_START_FAILED", error.message, null)
                    }
                }
                "stopPositionService" -> {
                    stopService(Intent(this, TradeLiveUpdateService::class.java))
                    // Clear persisted tracking metadata even if Android already
                    // stopped the service and therefore will not call onDestroy().
                    getSharedPreferences("vt_trade_live_service", Context.MODE_PRIVATE)
                        .edit()
                        .clear()
                        .apply()
                    cancelLiveNotification(7777)
                    result.success(true)
                }
                "getPositionServiceState" -> {
                    val state = getSharedPreferences("vt_trade_live_service", Context.MODE_PRIVATE)
                    val accountsJson = state.getString("accountsJson", null)
                    if (accountsJson.isNullOrBlank()) {
                        result.success(null)
                    } else {
                        result.success(mapOf(
                            "accountsJson" to accountsJson,
                            "startedAt" to state.getLong("startedAt", System.currentTimeMillis())
                        ))
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getWindowDisplay(): Display? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                display
            } catch (_: Exception) {
                @Suppress("DEPRECATION")
                windowManager.defaultDisplay
            }
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay
        }
    }

    private fun getSupportedDisplayModes(): List<Map<String, Any>> {
        val result = mutableListOf<Map<String, Any>>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val display = getWindowDisplay() ?: return result
            val modes = display.supportedModes ?: return result
            for (mode in modes) {
                result.add(
                    mapOf(
                        "id" to mode.modeId,
                        "width" to mode.physicalWidth,
                        "height" to mode.physicalHeight,
                        "refreshRate" to mode.refreshRate.toDouble()
                    )
                )
            }
        }
        return result
    }

    private fun getActiveDisplayMode(): Map<String, Any>? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val display = getWindowDisplay() ?: return null
            val mode = display.mode ?: return null
            return mapOf(
                "id" to mode.modeId,
                "width" to mode.physicalWidth,
                "height" to mode.physicalHeight,
                "refreshRate" to mode.refreshRate.toDouble()
            )
        }
        return null
    }

    private fun adaptToHighestRefreshRate(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val display = getWindowDisplay() ?: return false
                val modes = display.supportedModes
                if (!modes.isNullOrEmpty()) {
                    val currentMode = display.mode
                    var bestMode: Display.Mode? = null
                    var maxRate = 0f

                    val currentWidth = currentMode?.physicalWidth ?: 0
                    val currentHeight = currentMode?.physicalHeight ?: 0

                    // First pass: match current physical resolution with highest refresh rate
                    for (m in modes) {
                        val matchesResolution = (currentWidth == 0 && currentHeight == 0) ||
                                (m.physicalWidth == currentWidth && m.physicalHeight == currentHeight)
                        if (matchesResolution && m.refreshRate > maxRate) {
                            maxRate = m.refreshRate
                            bestMode = m
                        }
                    }

                    // Fallback pass: any mode with highest refresh rate
                    if (bestMode == null) {
                        for (m in modes) {
                            if (m.refreshRate > maxRate) {
                                maxRate = m.refreshRate
                                bestMode = m
                            }
                        }
                    }

                    if (bestMode != null) {
                        val layoutParams = window.attributes
                        layoutParams.preferredDisplayModeId = bestMode.modeId
                        @Suppress("DEPRECATION")
                        layoutParams.preferredRefreshRate = bestMode.refreshRate
                        window.attributes = layoutParams
                        return true
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        return false
    }

    private fun setDisplayMode(modeId: Int): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val layoutParams = window.attributes
                layoutParams.preferredDisplayModeId = modeId
                window.attributes = layoutParams
                return true
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        return false
    }

    private fun resetToDefaultDisplayMode(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val layoutParams = window.attributes
                layoutParams.preferredDisplayModeId = 0
                @Suppress("DEPRECATION")
                layoutParams.preferredRefreshRate = 0f
                window.attributes = layoutParams
                return true
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        return false
    }

    private fun createLiveNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "VT Index Live Updates"
            val descriptionText = "Promoted ongoing live status updates for open trades and orders"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(LIVE_CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableVibration(false)
                enableLights(true)
                setShowBadge(true)
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun postPromotedNotification(
        id: Int,
        title: String,
        body: String,
        subText: String,
        shortText: String,
        colorHex: String?,
        iconType: String?,
        usesChronometer: Boolean,
        startedAtMillis: Long?
    ): Boolean {
        if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) {
            return false
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) !=
            android.content.pm.PackageManager.PERMISSION_GRANTED
        ) {
            return false
        }

        val iconRes = if (iconType == "vt") R.drawable.ic_stat_vt else R.drawable.ic_stat_live
        val colorInt = try {
            if (!colorHex.isNullOrEmpty()) android.graphics.Color.parseColor(colorHex)
            else android.graphics.Color.parseColor("#10B981")
        } catch (_: Exception) {
            android.graphics.Color.parseColor("#10B981")
        }
        val largeIcon = try {
            android.graphics.BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher)
        } catch (_: Exception) {
            null
        }

        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val contentPendingIntent = PendingIntent.getActivity(
            this,
            id,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val displayBody = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            android.text.Html.fromHtml(body, android.text.Html.FROM_HTML_MODE_LEGACY)
        } else {
            @Suppress("DEPRECATION")
            android.text.Html.fromHtml(body)
        }

        val notification = NotificationCompat.Builder(this, LIVE_CHANNEL_ID)
            .setSmallIcon(iconRes)
            .setContentTitle(title)
            .setContentText(displayBody)
            .setStyle(NotificationCompat.BigTextStyle().bigText(displayBody))
            .setSubText(subText)
            .setColor(colorInt)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setShowWhen(usesChronometer)
            .setWhen(startedAtMillis ?: System.currentTimeMillis())
            .setUsesChronometer(usesChronometer)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(contentPendingIntent)
            .setRequestPromotedOngoing(true)
            .setShortCriticalText(shortText.trim().take(7))
            .apply {
                if (largeIcon != null) setLargeIcon(largeIcon)
            }
            .build()

        return try {
            NotificationManagerCompat.from(this).notify(id, notification)
            true
        } catch (e: SecurityException) {
            e.printStackTrace()
            false
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun cancelLiveNotification(id: Int) {
        try {
            NotificationManagerCompat.from(this).cancel(id)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun triggerHapticPulse(durationMs: Long, amplitude: Int): Boolean {
        return try {
            val vibrator: Vibrator? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val manager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                manager?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            }
            if (vibrator == null || !vibrator.hasVibrator()) {
                return false
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val effectiveAmplitude = if (vibrator.hasAmplitudeControl()) {
                    amplitude
                } else {
                    VibrationEffect.DEFAULT_AMPLITUDE
                }
                vibrator.vibrate(VibrationEffect.createOneShot(durationMs, effectiveAmplitude))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(durationMs)
            }
            true
        } catch (_: Exception) {
            false
        }
    }
}
