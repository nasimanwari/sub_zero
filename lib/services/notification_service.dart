import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(initializationSettings);
  }


  Future<void> scheduleNotification(int id, String title, DateTime scheduledDate) async {
    try {
      await notificationsPlugin.zonedSchedule(
        id, 
        title,
        "Payment reminder!",
        tz.TZDateTime.from(scheduledDate, tz.local), 
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sub_channel', 
            'Subscriptions', 
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print("Notification Error: $e");
    }
  }
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}