import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: android, iOS: DarwinInitializationSettings());
    await _plugin.initialize(init);
  }

  static Future<void> show({required int id, required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'sacco_channel', 'SaccoSecure Alerts', importance: Importance.max, priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _plugin.show(id, title, body, details);
  }
}