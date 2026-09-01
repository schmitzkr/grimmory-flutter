package `is`.schmitzkr.grimmory

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.FileProvider
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

// AudioServiceActivity (not plain FlutterActivity) reuses the FlutterEngine
// that audio_service's background service manages, so playback survives
// this activity being destroyed/recreated (e.g. backgrounding the app).
class MainActivity : AudioServiceActivity() {
    private var isInForeground = false

    companion object {
        private const val INSTALL_CHANNEL_ID = "grimmory_install"
        private const val INSTALL_NOTIFICATION_ID = 1001
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "is.schmitzkr.grimmory/download")
            .setMethodCallHandler { call, result ->
                if (call.method == "installApk") {
                    val path = call.argument<String>("path") ?: run {
                        result.error("INVALID_ARG", "path is required", null)
                        return@setMethodCallHandler
                    }
                    result.success(installApk(path))
                } else {
                    result.notImplemented()
                }
            }
        createInstallNotificationChannel()
    }

    override fun onResume() {
        super.onResume()
        isInForeground = true
    }

    override fun onPause() {
        super.onPause()
        isInForeground = false
    }

    private fun createInstallNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                INSTALL_CHANNEL_ID,
                "App Updates",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Tap to install downloaded app updates"
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    /// Returns "ok", "permission_required", or throws on file error.
    private fun installApk(path: String): String {
        // Android 8+: user must grant "Install unknown apps" for this app
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            !packageManager.canRequestPackageInstalls()
        ) {
            startActivity(
                Intent(
                    android.provider.Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                    Uri.parse("package:$packageName")
                ).apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK }
            )
            return "permission_required"
        }

        val apkFile = File(path)
        check(apkFile.exists()) { "APK file not found: $path" }

        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.provider",
            apkFile
        )
        val installIntent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION
        }

        if (isInForeground) {
            startActivity(installIntent)
        } else {
            showInstallNotification(installIntent, uri)
        }
        return "ok"
    }

    private fun showInstallNotification(installIntent: Intent, uri: Uri) {
        // Grant URI read permission to every activity that can handle the intent,
        // so the installer can read the file when launched from the notification.
        val resolvedActivities = packageManager.queryIntentActivities(installIntent, 0)
        for (info in resolvedActivities) {
            grantUriPermission(
                info.activityInfo.packageName,
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        else
            PendingIntent.FLAG_UPDATE_CURRENT

        val pendingIntent = PendingIntent.getActivity(this, 0, installIntent, flags)

        val notification = NotificationCompat.Builder(this, INSTALL_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setContentTitle("Grimmory update ready")
            .setContentText("Tap to install")
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(INSTALL_NOTIFICATION_ID, notification)
    }
}
