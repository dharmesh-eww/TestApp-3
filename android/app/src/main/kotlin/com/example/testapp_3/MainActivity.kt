package com.example.testapp_3

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private val channelName = "gather/cooking_assist"
    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private var permissionRequestInFlight = false
    private var pendingTimer: Triple<Int, String, String>? = null
    private var pendingFireAt: Long = 0L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tts = TextToSpeech(this, this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "speak" -> {
                    val text = call.argument<String>("text").orEmpty()
                    if (!ttsReady || text.isBlank()) result.success(false)
                    else result.success(tts?.speak(text, TextToSpeech.QUEUE_FLUSH, Bundle(), "gather-step") == TextToSpeech.SUCCESS)
                }
                "stopSpeaking" -> { tts?.stop(); result.success(null) }
                "setKeepScreenOn" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    if (enabled) window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    else window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    result.success(true)
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT < 33 || checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) result.success(true)
                    else { if (!permissionRequestInFlight) { permissionRequestInFlight = true; requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 8402) }; result.success(false) }
                }
                "scheduleTimerNotification" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val fireAt = call.argument<Long>("fireAt") ?: 0L
                    val title = call.argument<String>("title").orEmpty()
                    val body = call.argument<String>("body").orEmpty()
                    result.success(scheduleTimer(id, title, body, fireAt))
                }
                "cancelTimerNotification" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val intent = Intent(this, CookingTimerReceiver::class.java).setAction("com.example.testapp_3.COOKING_TIMER").putExtra("title", "Cooking timer").putExtra("body", "A timer has finished.")
                    val pending = PendingIntent.getBroadcast(this, id, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                    (getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pending)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleTimer(id: Int, title: String, body: String, fireAt: Long): Boolean {
        if (fireAt <= System.currentTimeMillis()) return false
        if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            pendingTimer = Triple(id, title, body)
            pendingFireAt = fireAt
            if (!permissionRequestInFlight) {
                permissionRequestInFlight = true
                requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 8402)
            }
            return false
        }
        val intent = Intent(this, CookingTimerReceiver::class.java).setAction("com.example.testapp_3.COOKING_TIMER")
            .putExtra("title", title).putExtra("body", body)
        val pending = PendingIntent.getBroadcast(this, id, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val alarm = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, fireAt, pending)
        return true
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 8402) {
            permissionRequestInFlight = false
            val pending = pendingTimer
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED && pending != null) {
                scheduleTimer(pending.first, pending.second, pending.third, pendingFireAt)
            }
            pendingTimer = null
        }
    }

    override fun onInit(status: Int) {
        ttsReady = status == TextToSpeech.SUCCESS
        if (ttsReady) tts?.language = Locale.getDefault()
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        super.onDestroy()
    }
}

class CookingTimerReceiver : BroadcastReceiver() {
    @Suppress("DEPRECATION")
    override fun onReceive(context: Context, intent: Intent) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "gather_cooking_timers"
        if (Build.VERSION.SDK_INT >= 26) manager.createNotificationChannel(
            NotificationChannel(channelId, "Cooking timers", NotificationManager.IMPORTANCE_HIGH)
        )
        val notification = if (Build.VERSION.SDK_INT >= 26) android.app.Notification.Builder(context, channelId)
            else android.app.Notification.Builder(context)
        notification.setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle(intent.getStringExtra("title") ?: "Cooking timer finished")
            .setContentText(intent.getStringExtra("body") ?: "Your timer is complete.")
            .setAutoCancel(true)
        manager.notify((System.currentTimeMillis() % Int.MAX_VALUE).toInt(), notification.build())
    }
}
