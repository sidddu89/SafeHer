package com.example.safeher

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import java.util.UUID
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import android.util.Log
import kotlinx.coroutines.*
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.safeher/sms"
    private val TAG = "SafeHer_SMS"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "sendSms") {
                    val phone = call.argument<String>("phone")
                    val message = call.argument<String>("message")

                    if (phone.isNullOrBlank() || message.isNullOrBlank()) {
                        result.error("BAD_ARGS", "phone or message missing", null)
                        return@setMethodCallHandler
                    }

                    // Run SMS sending on background thread to avoid blocking UI
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            Log.d(TAG, "sendSms called for: $phone")
                            if (ActivityCompat.checkSelfPermission(
                                    this@MainActivity,
                                    Manifest.permission.SEND_SMS
                                ) != PackageManager.PERMISSION_GRANTED
                            ) {
                                Log.e(TAG, "SMS permission not granted")
                                withContext(Dispatchers.Main) {
                                    result.error("NO_PERMISSION", "SEND_SMS permission not granted", null)
                                }
                                return@launch
                            }

                            val smsManager: SmsManager = getBestSmsManager(this@MainActivity)

                            val (success, errorMsg) = sendWithResult(this@MainActivity, smsManager, phone, message)
                            withContext(Dispatchers.Main) {
                                if (success) {
                                    Log.d(TAG, "SMS sent successfully to $phone")
                                    result.success(true)
                                } else {
                                    Log.e(TAG, "SMS failed to $phone: $errorMsg")
                                    result.error("SEND_FAIL", errorMsg ?: "SMS send failed", null)
                                }
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "Exception in sendSms: ${e.message}", e)
                            withContext(Dispatchers.Main) {
                                result.error("SEND_FAIL", e.localizedMessage ?: "Unknown error", null)
                            }
                        }
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    /**
     * Returns the most appropriate SmsManager.
     * - If default SMS subscription is valid, uses that.
     * - Otherwise, attempts to use the first active subscription (dual-SIM devices).
     * - Falls back to default SmsManager if subscriptions cannot be queried (permission or API limits).
     */
    private fun getBestSmsManager(context: Context): SmsManager {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                val subMgr = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager

                // On Android 13+, need READ_PHONE_STATE to access active subscriptions reliably
                val hasPhoneState = ActivityCompat.checkSelfPermission(
                    context,
                    Manifest.permission.READ_PHONE_STATE
                ) == PackageManager.PERMISSION_GRANTED

                val defaultSubId = SubscriptionManager.getDefaultSmsSubscriptionId()
                if (SubscriptionManager.isValidSubscriptionId(defaultSubId)) {
                    Log.d(TAG, "Using default SMS subscriptionId: $defaultSubId")
                    return SmsManager.getSmsManagerForSubscriptionId(defaultSubId)
                }

                if (hasPhoneState) {
                    val activeSubs: List<SubscriptionInfo>? = try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            subMgr.activeSubscriptionInfoList
                        } else {
                            @Suppress("DEPRECATION")
                            subMgr.activeSubscriptionInfoList
                        }
                    } catch (e: SecurityException) {
                        Log.w(TAG, "SecurityException reading active subscriptions: ${e.message}")
                        null
                    }

                    if (!activeSubs.isNullOrEmpty()) {
                        val chosen = activeSubs.first()
                        Log.d(TAG, "Using first active subscriptionId: ${chosen.subscriptionId}")
                        return SmsManager.getSmsManagerForSubscriptionId(chosen.subscriptionId)
                    } else {
                        Log.w(TAG, "No active subscriptions found or permission denied; falling back")
                    }
                } else {
                    Log.w(TAG, "READ_PHONE_STATE not granted; using default SmsManager")
                }

                // Fall back paths
                return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    context.getSystemService(SmsManager::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    SmsManager.getDefault()
                }
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error selecting SmsManager, using fallback: ${e.message}", e)
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                context.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
        }
    }

    private fun sendWithResult(
        context: Context,
        smsManager: SmsManager,
        phone: String,
        message: String,
        timeoutSeconds: Long = 10
    ): Pair<Boolean, String?> {
        val actionSent = "SMS_SENT_${UUID.randomUUID()}"
        val actionDelivered = "SMS_DELIVERED_${UUID.randomUUID()}"

        val sentLatch = CountDownLatch(1)
        val sentOk = AtomicBoolean(false)
        val errorMessage = arrayOf<String?>(null)

        val sentReceiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                try {
                    val code = resultCode
                    Log.d(TAG, "SMS SENT broadcast received with code: $code")
                    when (code) {
                        android.app.Activity.RESULT_OK -> {
                            sentOk.set(true)
                            Log.d(TAG, "SMS sent successfully")
                        }
                        SmsManager.RESULT_ERROR_GENERIC_FAILURE -> {
                            errorMessage[0] = "Generic failure"
                            Log.e(TAG, "SMS failed: Generic failure")
                        }
                        SmsManager.RESULT_ERROR_NO_SERVICE -> {
                            errorMessage[0] = "No service (check cellular signal)"
                            Log.e(TAG, "SMS failed: No service")
                        }
                        SmsManager.RESULT_ERROR_NULL_PDU -> {
                            errorMessage[0] = "Null PDU"
                            Log.e(TAG, "SMS failed: Null PDU")
                        }
                        SmsManager.RESULT_ERROR_RADIO_OFF -> {
                            errorMessage[0] = "Radio off (enable airplane mode off)"
                            Log.e(TAG, "SMS failed: Radio off")
                        }
                        16 -> {
                            // MIUI/Xiaomi specific: SMS blocked by system security
                            errorMessage[0] = "MIUI blocked SMS. Go to Settings > Apps > SafeHer > Permissions > SMS > Allow. Also check Settings > Privacy > Special Permissions > Send SMS"
                            Log.e(TAG, "SMS failed: MIUI security blocked (code 16)")
                        }
                        else -> {
                            errorMessage[0] = "Unknown error code: $code"
                            Log.e(TAG, "SMS failed: Unknown code $code")
                        }
                    }
                } finally {
                    sentLatch.countDown()
                    try { context.unregisterReceiver(this) } catch (_: Exception) {}
                }
            }
        }

        // Register SENT receiver with proper flags for Android 13+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(sentReceiver, IntentFilter(actionSent), Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(sentReceiver, IntentFilter(actionSent))
        }

        val sentPi = PendingIntent.getBroadcast(
            context,
            0,
            Intent(actionSent).setPackage(context.packageName),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            else
                PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Delivery receipt is optional; create but we won't block on it
        val deliveredPi = PendingIntent.getBroadcast(
            context,
            0,
            Intent(actionDelivered).setPackage(context.packageName),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            else
                PendingIntent.FLAG_UPDATE_CURRENT
        )

        return try {
            Log.d(TAG, "Attempting to send SMS to $phone, message length: ${message.length}")
            if (message.length > 160) {
                val parts = smsManager.divideMessage(message)
                Log.d(TAG, "Sending multipart SMS with ${parts.size} parts")
                val sentIntents = parts.map { sentPi }
                val deliveredIntents = parts.map { deliveredPi }
                smsManager.sendMultipartTextMessage(phone, null, parts, ArrayList(sentIntents), ArrayList(deliveredIntents))
            } else {
                Log.d(TAG, "Sending single SMS")
                smsManager.sendTextMessage(phone, null, message, sentPi, deliveredPi)
            }

            // Wait for SENT result (success or fail) up to timeoutSeconds
            Log.d(TAG, "Waiting for SMS result (timeout: ${timeoutSeconds}s)...")
            val completed = sentLatch.await(timeoutSeconds, TimeUnit.SECONDS)
            
            if (!completed) {
                Log.w(TAG, "SMS send timed out after ${timeoutSeconds}s - SMS may have been sent but callback blocked")
                Pair(true, "SMS sent (timeout - callback may be blocked by system)")
            } else if (sentOk.get()) {
                Pair(true, null)
            } else {
                Pair(false, errorMessage[0] ?: "SMS send failed")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception during SMS send: ${e.message}", e)
            try { context.unregisterReceiver(sentReceiver) } catch (_: Exception) {}
            Pair(false, e.localizedMessage ?: "Exception: ${e.javaClass.simpleName}")
        }
    }
}
