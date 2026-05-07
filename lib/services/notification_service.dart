import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    print('🔄 Initializing notifications...');

    // Initialize timezone
    tzdata.initializeTimeZones();

    try {
      // Request permission
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      print('✅ Firebase Messaging permissions requested');

      // Android initialization
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iosInitializationSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: androidInitializationSettings,
            iOS: iosInitializationSettings,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          print('📱 Notification tapped: ${response.payload}');
        },
      );

      print('✅ Local notifications initialized');

      // Create Android notification channel
      await _createNotificationChannel();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📬 Foreground message: ${message.notification?.title}');
      });

      print('✅ Notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  static Future<void> _createNotificationChannel() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'event_reminder_channel',
            'Event Reminders',
            description: 'Notifications for event reminders',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );

        print('✅ Notification channel created');
      }
    } catch (e) {
      print('❌ Error creating channel: $e');
    }
  }

  static Future<void> scheduleEventReminder({
    required int eventId,
    required String title,
    required DateTime eventTime,
    required Map<String, bool> reminderSettings,
  }) async {
    final now = DateTime.now();

    print('⏱️ Scheduling reminders for: $title at $eventTime');

    try {
      // Schedule 5 minutes before
      if (reminderSettings['5min'] == true) {
        final scheduledTime = eventTime.subtract(const Duration(minutes: 5));
        if (scheduledTime.isAfter(now)) {
          await _scheduleLocalNotification(
            id: eventId + 1,
            title: '⏰ $title',
            body: 'Starts in 5 minutes',
            scheduledDateTime: scheduledTime,
          );
        }
      }

      // Schedule 30 minutes before
      if (reminderSettings['30min'] == true) {
        final scheduledTime = eventTime.subtract(const Duration(minutes: 30));
        if (scheduledTime.isAfter(now)) {
          await _scheduleLocalNotification(
            id: eventId + 2,
            title: '⏰ $title',
            body: 'Starts in 30 minutes',
            scheduledDateTime: scheduledTime,
          );
        }
      }

      // Schedule 1 day before
      if (reminderSettings['1day'] == true) {
        final scheduledTime = eventTime.subtract(const Duration(days: 1));
        if (scheduledTime.isAfter(now)) {
          await _scheduleLocalNotification(
            id: eventId + 3,
            title: '📅 $title',
            body: 'Reminder: Event is tomorrow',
            scheduledDateTime: scheduledTime,
          );
        }
      }
    } catch (e) {
      print('❌ Error scheduling reminders: $e');
    }
  }

  static Future<void> _scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'event_reminder_channel',
            'Event Reminders',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDateTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('✅ Scheduled at: $scheduledDateTime');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  static Future<String?> getDeviceToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('🔐 Device Token: $token');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('✅ Notification $id cancelled');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}
