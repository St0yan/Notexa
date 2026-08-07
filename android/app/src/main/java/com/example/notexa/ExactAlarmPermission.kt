package com.example.notexa

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.provider.Settings

object ExactAlarmPermission {
    fun requestExactAlarmPermission(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        if (!alarmManager.canScheduleExactAlarms()) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
        }
    }
}