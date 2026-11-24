package com.vtindex.crm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import org.json.JSONArray
import org.json.JSONObject
import android.util.Base64
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.spec.MGF1ParameterSpec
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.OAEPParameterSpec
import javax.crypto.spec.PSource
import java.net.HttpURLConnection
import java.net.URL
import java.text.DecimalFormat
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

/**
 * User-started foreground service that keeps one selected position's native
 * ongoing notification synchronized while the Flutter activity is backgrounded.
 */
class TradeLiveUpdateService : Service() {
    private val notificationId = 7777
    private val channelId = "vt_live_updates_channel"
    private val prefs by lazy { getSharedPreferences("vt_trade_live_service", Context.MODE_PRIVATE) }
    private var executor: ScheduledExecutorService? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        ensureChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let { incoming ->
            prefs.edit()
                .putString("url", incoming.getStringExtra("url"))
                .putString("host", incoming.getStringExtra("host"))
                .putString("positionId", incoming.getStringExtra("positionId"))
                .putString("accountId", incoming.getStringExtra("accountId"))
                .putString("symbol", incoming.getStringExtra("symbol"))
                .putString("side", incoming.getStringExtra("side"))
                .putString("lots", incoming.getStringExtra("lots"))
                .putLong("startedAt", incoming.getLongExtra("startedAt", System.currentTimeMillis()))
                .apply()
        }

        val url = prefs.getString("url", null)
        val positionId = prefs.getString("positionId", null)
        if (url.isNullOrBlank() || positionId.isNullOrBlank()) {
            stopSelf()
            return START_NOT_STICKY
        }

        try {
            val initial = buildNotification(
                prefs.getString("symbol", "Trade") ?: "Trade",
                "Connecting to live position data…",
                "LIVE",
                System.currentTimeMillis(),
                false
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ServiceCompat.startForeground(
                    this,
                    notificationId,
                    initial,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                )
            } else {
                startForeground(notificationId, initial)
            }
        } catch (error: Exception) {
            Log.e("VTTradeLive", "Unable to start foreground notification", error)
            stopSelf()
            return START_NOT_STICKY
        }

        if (executor == null || executor?.isShutdown == true) {
            executor = Executors.newSingleThreadScheduledExecutor()
            executor?.scheduleWithFixedDelay({ refreshPosition() }, 0, 15, TimeUnit.SECONDS)
        }
        return START_STICKY
    }

    private fun refreshPosition() {
        val endpoint = prefs.getString("url", null) ?: return
        val positionId = prefs.getString("positionId", null) ?: return
        var connection: HttpURLConnection? = null
        try {
            val accessToken = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .getString("flutter.vtindex_client_access_token", null)
            if (accessToken.isNullOrBlank()) {
                updateBody("Reopen VTIndex to restore secure trade synchronization")
                return
            }

            // Client API responses are encrypted per request. Generate a one-use
            // RSA key pair and send its public key so the backend can encrypt this
            // response for the native service just as it does for Flutter requests.
            val responseKeyPair = createResponseKeyPair()
            connection = (URL(endpoint).openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = 10000
                readTimeout = 10000
                setRequestProperty("Accept", "application/json")
                setRequestProperty("Authorization", "Bearer $accessToken")
                setRequestProperty(
                    "X-Response-Encryption-Key",
                    Base64.encodeToString(responseKeyPair.public.encoded, Base64.NO_WRAP)
                )
                prefs.getString("host", null)?.takeIf { it.isNotBlank() }?.let { setRequestProperty("Host", it) }
            }
            val code = connection.responseCode
            if (code !in 200..299) {
                val errorBody = try {
                    (connection.errorStream ?: connection.inputStream)
                        .bufferedReader().use { it.readText() }
                } catch (_: Exception) {
                    ""
                }
                Log.w("VTTradeLive", "Position API returned HTTP $code: " + errorBody.take(300))
                updateBody("Trade data temporarily unavailable · HTTP $code")
                return
            }
            val encryptedPayload = connection.inputStream.bufferedReader().use { it.readText() }
            val payload = decryptResponse(JSONObject(encryptedPayload), responseKeyPair)
            val position = findPosition(payload, positionId)
            if (position == null) {
                stopSelf()
                return
            }

            val profit = number(position, "profit")
            val currentPrice = number(position, "current_price", "currentPrice", "price_current")
            val openPrice = number(position, "open_price", "openPrice", "price_open")
            val symbol = prefs.getString("symbol", "Trade") ?: "Trade"
            val side = prefs.getString("side", "BUY") ?: "BUY"
            val lots = prefs.getString("lots", "0.00") ?: "0.00"
            val account = prefs.getString("accountId", "") ?: ""
            val sign = if (profit >= 0) "+" else "-"
            val pnl = sign + 36.toChar() + DecimalFormat("0.00").format(kotlin.math.abs(profit))
            val body = "Account #$account · Ticket #$positionId · P/L $pnl · Price " +
                DecimalFormat("0.00000").format(currentPrice) +
                " (open " + DecimalFormat("0.00000").format(openPrice) + ")"
            val title = "$symbol $side $lots"
            val short = sign + DecimalFormat("0").format(kotlin.math.abs(profit)).take(5)
            val notification = buildNotification(
                title,
                body,
                short,
                prefs.getLong("startedAt", System.currentTimeMillis()),
                true,
                if (profit >= 0) 0xFF10B981.toInt() else 0xFFEF4444.toInt()
            )
            NotificationManagerCompat.from(this).notify(notificationId, notification)
        } catch (error: Exception) {
            Log.w("VTTradeLive", "Position refresh failed", error)
            updateBody("Live trade connection interrupted · retrying")
        } finally {
            connection?.disconnect()
        }
    }


    private fun createResponseKeyPair(): KeyPair {
        return KeyPairGenerator.getInstance("RSA").apply {
            initialize(2048)
        }.generateKeyPair()
    }

    /**
     * Decrypts the backend's vtindex:user-info:v1 response envelope.
     * Protocol: RSA-OAEP-SHA256 wraps an AES-256 key; AES-256-GCM protects JSON.
     */
    private fun decryptResponse(envelope: JSONObject, keyPair: KeyPair): JSONObject {
        if (!envelope.optBoolean("encrypted", false) ||
            envelope.optInt("version", -1) != 1 ||
            envelope.optString("algorithm") != "RSA-OAEP-256+A256GCM"
        ) {
            throw IllegalStateException("Unexpected open-positions response format")
        }

        val aad = "vtindex:user-info:v1".toByteArray(Charsets.UTF_8)
        val decode = { field: String ->
            Base64.decode(envelope.getString(field), Base64.DEFAULT)
        }

        val rsa = Cipher.getInstance("RSA/ECB/OAEPPadding")
        rsa.init(
            Cipher.DECRYPT_MODE,
            keyPair.private,
            OAEPParameterSpec(
                "SHA-256",
                "MGF1",
                MGF1ParameterSpec.SHA256,
                PSource.PSpecified(aad)
            )
        )
        val aesKey = rsa.doFinal(decode("wrapped_key"))

        val aes = Cipher.getInstance("AES/GCM/NoPadding")
        aes.init(
            Cipher.DECRYPT_MODE,
            javax.crypto.spec.SecretKeySpec(aesKey, "AES"),
            GCMParameterSpec(128, decode("nonce"))
        )
        aes.updateAAD(aad)
        val plaintext = aes.doFinal(decode("ciphertext"))
        return JSONObject(String(plaintext, Charsets.UTF_8))
    }

    private fun findPosition(root: JSONObject, targetId: String): JSONObject? {
        val direct = root.optJSONArray("positions")
            ?: root.optJSONObject("data")?.optJSONArray("positions")
            ?: root.optJSONArray("results")
        if (direct != null) {
            for (index in 0 until direct.length()) {
                val item = direct.optJSONObject(index) ?: continue
                val id = firstString(item, "ticket", "position_ticket", "position_id", "id")
                if (id == targetId) return item
            }
        }
        val data = root.optJSONObject("data")
        if (data != null && data !== root) return findPosition(data, targetId)
        val result = root.optJSONObject("result")
        if (result != null && result !== root) return findPosition(result, targetId)
        return null
    }

    private fun firstString(item: JSONObject, vararg keys: String): String {
        for (key in keys) {
            val value = item.opt(key)
            if (value != null && value != JSONObject.NULL) return value.toString()
        }
        return ""
    }

    private fun number(item: JSONObject, vararg keys: String): Double {
        for (key in keys) {
            val value = item.opt(key)
            if (value is Number) return value.toDouble()
            if (value is String) value.replace(",", "").toDoubleOrNull()?.let { return it }
        }
        return 0.0
    }

    private fun updateBody(body: String) {
        val title = prefs.getString("symbol", "Trade") ?: "Trade"
        val notification = buildNotification(
            title,
            body,
            "LIVE",
            prefs.getLong("startedAt", System.currentTimeMillis()),
            false
        )
        NotificationManagerCompat.from(this).notify(notificationId, notification)
    }

    private fun buildNotification(
        title: String,
        body: String,
        shortText: String,
        startedAt: Long,
        chronometer: Boolean,
        color: Int = 0xFF1658C9.toInt()
    ): Notification {
        return NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_stat_live)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setSubText("LIVE TRADE")
            .setColor(color)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setWhen(startedAt)
            .setShowWhen(chronometer)
            .setUsesChronometer(chronometer)
            .setRequestPromotedOngoing(true)
            .setShortCriticalText(shortText.trim().take(7))
            .build()
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "VT Index Live Updates",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Ongoing updates for a tracked open trading position"
                setShowBadge(true)
                enableVibration(false)
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        stopSelf(startId)
    }

    override fun onDestroy() {
        executor?.shutdownNow()
        executor = null
        prefs.edit().clear().apply()
        super.onDestroy()
    }
}
