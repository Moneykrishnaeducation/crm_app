package com.example.crm_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.view.Display
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.example.crm_app.R
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val LIVE_CHANNEL = "com.example.crm_app/live_updates"
    private val DISPLAY_CHANNEL = "com.example.crm_app/display_mode"
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

                    postPromotedNotification(id, title, body, subText, shortText, colorHex, iconType)
                    result.success(true)
                }
                "stopLiveUpdate" -> {
                    val id = call.argument<Int>("id") ?: 7777
                    cancelLiveNotification(id)
                    result.success(true)
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
        iconType: String?
    ) {
        val iconRes = if (iconType == "vt") R.drawable.ic_stat_vt else R.drawable.ic_stat_live

        val colorInt = try {
            if (!colorHex.isNullOrEmpty()) android.graphics.Color.parseColor(colorHex)
            else android.graphics.Color.parseColor("#10B981")
        } catch (e: Exception) {
            android.graphics.Color.parseColor("#10B981")
        }

        val largeIcon = try {
            android.graphics.BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher)
        } catch (e: Exception) {
            null
        }

        val builder = NotificationCompat.Builder(this, LIVE_CHANNEL_ID)
            .setSmallIcon(iconRes)
            .setContentTitle(title)
            .setSubText(subText)
            .setColor(colorInt)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(true)
            .setUsesChronometer(true)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setPriority(NotificationCompat.PRIORITY_MAX)

        if (largeIcon != null) {
            builder.setLargeIcon(largeIcon)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            builder.setContentText(android.text.Html.fromHtml(body, android.text.Html.FROM_HTML_MODE_LEGACY))
        } else {
            builder.setContentText(body)
        }

        // Android 16/17 + Moto Live Updates Promoted Ongoing Request
        builder.extras.putBoolean("android.requestPromotedOngoing", true)
        builder.extras.putCharSequence("android.shortCriticalText", shortText)

        try {
            NotificationManagerCompat.from(this).notify(id, builder.build())
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }

    private fun cancelLiveNotification(id: Int) {
        try {
            NotificationManagerCompat.from(this).cancel(id)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
