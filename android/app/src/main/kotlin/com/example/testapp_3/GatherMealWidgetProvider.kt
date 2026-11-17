package com.example.testapp_3

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class GatherMealWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.gather_meal_widget).apply {
                setTextViewText(R.id.widget_title, widgetData.getString("today_title", "Today in Gather") ?: "Today in Gather")
                setTextViewText(R.id.widget_date, widgetData.getString("today_date", "") ?: "")
                setTextViewText(
                    R.id.widget_meals,
                    widgetData.getString("today_meals", "Open Gather to plan your meals.")
                        ?: "Open Gather to plan your meals."
                )
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
