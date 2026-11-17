package com.example.testapp_3

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class GatherMealWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val todayKey = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val friendlyDate = SimpleDateFormat("EEE, MMM d", Locale.getDefault()).format(Date())
        val mealsForToday = try {
            val calendar = widgetData.getString("meal_calendar", null)
            if (calendar.isNullOrBlank()) null else JSONObject(calendar).optString(todayKey, null)
        } catch (_: Exception) {
            null
        }
        val mealText = mealsForToday?.takeIf { it.isNotBlank() }
            ?: if (widgetData.getString("today_date", "") == todayKey) {
                widgetData.getString("today_meals", "Open Gather to plan your meals.")
            } else {
                "No meals planned. Open Gather to plan your day."
            }

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.gather_meal_widget).apply {
                setTextViewText(R.id.widget_title, widgetData.getString("today_title", "Today in Gather") ?: "Today in Gather")
                setTextViewText(R.id.widget_date, friendlyDate)
                setTextViewText(R.id.widget_meals, mealText)
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                if (launchIntent != null) {
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        7001,
                        launchIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    )
                    setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
