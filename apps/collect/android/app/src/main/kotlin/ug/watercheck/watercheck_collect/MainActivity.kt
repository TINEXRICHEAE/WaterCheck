package ug.watercheck.watercheck_collect

import android.os.StatFs
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FragmentActivity: required by local_auth for the biometric prompt.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Free storage for the low-storage photo guard (SPEC P7).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "watercheck/storage")
            .setMethodCallHandler { call, result ->
                if (call.method == "freeBytes") {
                    result.success(StatFs(filesDir.path).availableBytes)
                } else {
                    result.notImplemented()
                }
            }
    }
}
