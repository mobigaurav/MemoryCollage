package com.playingview.mobigaurav.memory_book

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class WeeklyReminder : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "memory_book",
                "Exports",
                NotificationManager.IMPORTANCE_DEFAULT,
            )
            context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
        val notification = NotificationCompat.Builder(context, "memory_book")
            .setSmallIcon(android.R.drawable.ic_menu_gallery)
            .setContentTitle(intent.getStringExtra("title") ?: "Photos from this week")
            .setContentText(intent.getStringExtra("body") ?: "Open the shelf and start a book from the last few days.")
            .setAutoCancel(true)
            .build()
        try {
            NotificationManagerCompat.from(context).notify(77, notification)
        } catch (_: SecurityException) {
        }
    }
}
