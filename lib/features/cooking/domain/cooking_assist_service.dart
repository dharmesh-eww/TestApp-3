import 'package:flutter/services.dart';

/// Optional Android cooking helpers. Unsupported platforms fail closed and
/// leave the in-app timer/cooking flow fully usable.
class CookingAssistService {
  CookingAssistService._();
  static const MethodChannel _channel = MethodChannel('gather/cooking_assist');

  static Future<bool> speak(String text) async {
    if (text.trim().isEmpty) return false;
    try { return await _channel.invokeMethod<bool>('speak', {'text': text}) ?? false; }
    on PlatformException { return false; }
    on MissingPluginException { return false; }
  }

  static Future<void> stopSpeaking() async {
    try { await _channel.invokeMethod<void>('stopSpeaking'); } on PlatformException { } on MissingPluginException { }
  }

  static Future<bool> setKeepScreenOn(bool enabled) async {
    try { return await _channel.invokeMethod<bool>('setKeepScreenOn', {'enabled': enabled}) ?? false; }
    on PlatformException { return false; }
    on MissingPluginException { return false; }
  }

  static Future<bool> requestNotificationPermission() async {
    try { return await _channel.invokeMethod<bool>('requestNotificationPermission') ?? false; }
    on PlatformException { return false; }
    on MissingPluginException { return false; }
  }

  static Future<bool> scheduleTimerNotification({required String id, required String title, required String body, required DateTime fireAt}) async {
    try {
      return await _channel.invokeMethod<bool>('scheduleTimerNotification', {
        'id': id.hashCode, 'title': title, 'body': body, 'fireAt': fireAt.millisecondsSinceEpoch,
      }) ?? false;
    } on PlatformException { return false; }
      on MissingPluginException { return false; }
  }

  static Future<void> cancelTimerNotification(String id) async {
    try { await _channel.invokeMethod<void>('cancelTimerNotification', {'id': id.hashCode}); }
    on PlatformException { } on MissingPluginException { }
  }
}
