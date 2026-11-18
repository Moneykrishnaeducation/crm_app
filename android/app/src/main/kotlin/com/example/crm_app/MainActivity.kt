package com.example.crm_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.example.crm_app.R
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.crm_app/live_updates"
    private val LIVE_CHANNEL_ID = "vt_live_updates_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createLiveNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLiveUpdate" -> {
                    val id = call.argument<Int>("id") ?: 7777
                    val title = call.argument<String>("title") ?: "VT Index Live"
                    val body = call.argument<String>("body") ?: "Live update active"
                    val subText = call.argument<String>("subText") ?: "LIVE"
                    val shortText = call.argument<String>("shortText") ?: "LIVE"

                    postPromotedNotification(id, title, body, subText, shortText)
                    result.success(true)
                }
                "updateLiveUpdate" -> {
                    val id = call.argument<Int>("id") ?: 7777
                    val title = call.argument<String>("title") ?: "VT Index Live"
                    val body = call.argument<String>("body") ?: "Live update active"
                    val subText = call.argument<String>("subText") ?: "LIVE"
                    val shortText = call.argument<String>("shortText") ?: "LIVE"

                    postPromotedNotification(id, title, body, subText, shortText)
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
        shortText: String
    ) {
        val builder = NotificationCompat.Builder(this, LIVE_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setSubText(subText)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(true)
            .setUsesChronometer(true)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setPriority(NotificationCompat.PRIORITY_MAX)

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
