import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Begär tillstånd på Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTap(NotificationResponse response) {
    // Hantera klick på notifikation
    // payload innehåller mealId
  }

  Future<void> scheduleSatietyReminder({
    required String mealId,
    required String mealName,
    int delayMinutes = 25,
  }) async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: delayMinutes));

    await _notifications.zonedSchedule(
      mealId.hashCode,
      'Dags att logga mättnad',
      mealName.isNotEmpty 
          ? 'Hur känns det efter "$mealName"?' 
          : 'Hur känns det efter måltiden?',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'satiety_reminder',
          'Mättnadspåminnelser',
          channelDescription: 'Påminnelser om att logga mättnad efter måltid',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: mealId,
    );
  }

  Future<void> cancelReminder(String mealId) async {
    await _notifications.cancel(mealId.hashCode);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}
