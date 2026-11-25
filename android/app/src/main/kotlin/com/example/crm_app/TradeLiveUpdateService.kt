package com.vtindex.crm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Base64
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.spec.MGF1ParameterSpec
import java.text.DecimalFormat
import java.util.Locale
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.OAEPParameterSpec
import javax.crypto.spec.PSource
import javax.crypto.spec.SecretKeySpec

/**
 * Portfolio-wide foreground monitor. Every owned account is polled and positions
 * are grouped into Demo and Live totals for one native ongoing notification.
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
                .putString("accountsJson", incoming.getStringExtra("accountsJson"))
                .putLong("startedAt", incoming.getLongExtra("startedAt", System.currentTimeMillis()))
                .apply()
        }

        val accountsJson = prefs.getString("accountsJson", null)
        if (accountsJson.isNullOrBlank()) {
            stopSelf()
            return START_NOT_STICKY
        }

        try {
            val initial = buildNotification(
                "VT Index · Portfolio Live",
                "Connecting to demo and live account positions…",
                "D+0 L+0",
                prefs.getLong("startedAt", System.currentTimeMillis()),
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
            Log.e("VTTradeLive", "Unable to start portfolio foreground notification", error)
            stopSelf()
            return START_NOT_STICKY
        }

        if (executor == null || executor?.isShutdown == true) {
            executor = Executors.newSingleThreadScheduledExecutor()
            executor?.scheduleWithFixedDelay({ refreshPortfolio() }, 0, 15, TimeUnit.SECONDS)
        }
        return START_STICKY
    }

    private fun refreshPortfolio() {
        val accountsJson = prefs.getString("accountsJson", null) ?: return
        val accessToken = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getString("flutter.vtindex_client_access_token", null)
        if (accessToken.isNullOrBlank()) {
            updateBody("Reopen VTIndex to restore secure portfolio synchronization")
            return
        }

        var demoPnl = 0.0
        var livePnl = 0.0
        var demoCount = 0
        var liveCount = 0
        var successCount = 0
        var demoAccountCount = 0
        var liveAccountCount = 0
        val demoDetails = mutableListOf<String>()
        val liveDetails = mutableListOf<String>()

        try {
            val accounts = JSONArray(accountsJson)
            for (index in 0 until accounts.length()) {
                val account = accounts.optJSONObject(index) ?: continue
                val accountId = account.optString("accountId")
                val endpoint = account.optString("url")
                if (accountId.isBlank() || endpoint.isBlank()) continue
                try {
                    val positions = fetchPositions(endpoint, accessToken)
                    successCount++
                    val isDemo = account.optBoolean("isDemo", false)
                    if (isDemo) demoAccountCount++ else liveAccountCount++
                    val accountName = account.optString("accountName", accountId)
                    for (positionIndex in 0 until positions.length()) {
                        val position = positions.optJSONObject(positionIndex) ?: continue
                        val profit = number(position, "profit")
                        val ticket = firstString(position, "ticket", "position_ticket", "position_id", "id")
                        val symbol = firstString(position, "symbol").ifBlank { "Trade" }
                        val type = firstString(position, "type", "side", "position_type").uppercase(Locale.US)
                        val side = if (type.contains("SELL")) "SELL" else "BUY"
                        val volume = number(position, "volume", "lots")
                        val pnlText = money(profit)
                        val detail = "#$ticket · $symbol $side ${DecimalFormat("0.00").format(volume)} · $pnlText · $accountName"
                        if (isDemo) {
                            demoPnl += profit
                            demoCount++
                            demoDetails.add(detail)
                        } else {
                            livePnl += profit
                            liveCount++
                            liveDetails.add(detail)
                        }
                    }
                } catch (error: Exception) {
                    Log.w("VTTradeLive", "Account $accountId portfolio refresh failed", error)
                }
            }

            if (successCount == 0 && accounts.length() > 0) {
                updateBody("Account data temporarily unavailable · retrying")
                return
            }

            val totalPnl = demoPnl + livePnl
            val body = buildString {
                if (demoCount > 0) {
                    append("DEMO · $demoAccountCount accounts · $demoCount positions · P/L ${money(demoPnl)}")
                    demoDetails.forEach { append("\n  ").append(it) }
                }
                if (liveCount > 0) {
                    if (isNotEmpty()) append("\n\n")
                    append("LIVE · $liveAccountCount accounts · $liveCount positions · P/L ${money(livePnl)}")
                    liveDetails.forEach { append("\n  ").append(it) }
                }
            }
            val short = "D${if (demoPnl >= 0) "+" else "-"}${DecimalFormat("0").format(kotlin.math.abs(demoPnl))} L${if (livePnl >= 0) "+" else "-"}${DecimalFormat("0").format(kotlin.math.abs(livePnl))}"
            val notification = buildNotification(
                "VT Index · Portfolio Live",
                body,
                short,
                prefs.getLong("startedAt", System.currentTimeMillis()),
                false,
                if (totalPnl >= 0) 0xFF10B981.toInt() else 0xFFEF4444.toInt()
            )
            NotificationManagerCompat.from(this).notify(notificationId, notification)
        } catch (error: Exception) {
            Log.e("VTTradeLive", "Portfolio refresh failed", error)
            updateBody("Portfolio synchronization interrupted · retrying")
        }
    }

    private fun fetchPositions(endpoint: String, accessToken: String): JSONArray {
        var connection: HttpURLConnection? = null
        try {
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
                prefs.getString("host", null)?.takeIf { it.isNotBlank() }
                    ?.let { setRequestProperty("Host", it) }
            }
            val code = connection.responseCode
            val responseStream = if (code in 200..299) {
                connection.inputStream
            } else {
                connection.errorStream ?: connection.inputStream
            }
            val responseBody = responseStream.bufferedReader().use { it.readText() }
            if (responseBody.isBlank()) {
                throw IllegalStateException("HTTP $code: empty response body")
            }

            // API error responses are encrypted by the same middleware as successful
            // responses. Decrypt before extracting diagnostics; never disable encryption.
            val payload = try {
                decryptResponse(JSONObject(responseBody), responseKeyPair)
            } catch (decryptError: Exception) {
                if (code in 200..299) throw decryptError
                throw IllegalStateException(
                    "HTTP $code: encrypted error response could not be decrypted",
                    decryptError
                )
            }

            if (code !in 200..299) {
                val message = payload.optString("message")
                    .ifBlank { payload.optString("detail") }
                    .ifBlank { payload.optString("error") }
                    .ifBlank { "Request failed" }
                val technical = payload.optString("technical_details")
                val details = payload.opt("details")?.toString().orEmpty()
                val diagnostic = listOf(message, technical, details)
                    .filter { it.isNotBlank() }
                    .joinToString(" | ")
                throw IllegalStateException("HTTP $code: $diagnostic")
            }

            return findPositions(payload)
        } finally {
            connection?.disconnect()
        }
    }

    private fun findPositions(root: JSONObject): JSONArray {
        root.optJSONArray("positions")?.let { return it }
        root.optJSONArray("results")?.let { return it }
        root.optJSONObject("data")?.let { return findPositions(it) }
        root.optJSONObject("result")?.let { return findPositions(it) }
        root.optJSONObject("payload")?.let { return findPositions(it) }
        return JSONArray()
    }

    private fun createResponseKeyPair(): KeyPair {
        return KeyPairGenerator.getInstance("RSA").apply { initialize(2048) }.generateKeyPair()
    }

    /** Decrypts the backend vtindex:user-info:v1 RSA-OAEP + AES-GCM envelope. */
    private fun decryptResponse(envelope: JSONObject, keyPair: KeyPair): JSONObject {
        if (!envelope.optBoolean("encrypted", false) ||
            envelope.optInt("version", -1) != 1 ||
            envelope.optString("algorithm") != "RSA-OAEP-256+A256GCM"
        ) throw IllegalStateException("Unexpected open-positions response format")

        val aad = "vtindex:user-info:v1".toByteArray(Charsets.UTF_8)
        val decode = { field: String -> Base64.decode(envelope.getString(field), Base64.DEFAULT) }
        val rsa = Cipher.getInstance("RSA/ECB/OAEPPadding")
        rsa.init(
            Cipher.DECRYPT_MODE,
            keyPair.private,
            OAEPParameterSpec("SHA-256", "MGF1", MGF1ParameterSpec.SHA256, PSource.PSpecified(aad))
        )
        val aesKey = rsa.doFinal(decode("wrapped_key"))
        val aes = Cipher.getInstance("AES/GCM/NoPadding")
        aes.init(
            Cipher.DECRYPT_MODE,
            SecretKeySpec(aesKey, "AES"),
            GCMParameterSpec(128, decode("nonce"))
        )
        aes.updateAAD(aad)
        return JSONObject(String(aes.doFinal(decode("ciphertext")), Charsets.UTF_8))
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

    private fun money(value: Double): String {
        val sign = if (value >= 0) "+" else "-"
        return sign + "$" + DecimalFormat("0.00").format(kotlin.math.abs(value))
    }

    private fun updateBody(body: String) {
        val notification = buildNotification(
            "VT Index · Portfolio Live",
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
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val contentPendingIntent = PendingIntent.getActivity(
            this,
            notificationId,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_stat_live)
            .setContentIntent(contentPendingIntent)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setSubText("OPEN POSITIONS")
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
                description = "Portfolio-wide ongoing P/L updates for demo and live accounts"
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
