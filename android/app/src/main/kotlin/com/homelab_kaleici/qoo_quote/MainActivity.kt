package com.homelab_kaleici.qoo_quote
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app/deep_links"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    // Deep link'ten gelen URI'yi al
                    val uri = intent?.data?.toString()
                    result.success(uri)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Uygulama açıkken gelen deep link'i Flutter'a ilet
        val uri = intent.data?.toString()
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
            .invokeMethod("onDeepLink", uri)
    }
}