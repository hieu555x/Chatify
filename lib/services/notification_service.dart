import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationTapCallback = Future<void> Function(String roomID);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static NotificationTapCallback? _onNotificationTap;
  static GlobalKey<NavigatorState>? _navigatorKey;

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static void setNotificationTapCallback(NotificationTapCallback callback) {
    _onNotificationTap = callback;
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
      onDidReceiveNotificationResponse: _onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveNotification,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static void _onDidReceiveNotification(
    NotificationResponse notificationResponse,
  ) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');

    if (notificationResponse.payload != null && _onNotificationTap != null) {
      _onNotificationTap!(notificationResponse.payload!);
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required String roomID,
    String? senderName,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'chat_channel',
          'Chat Notifications',
          channelDescription: 'Notifications for new chat messages',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      roomID.hashCode,
      title,
      body,
      notificationDetails,
      payload: roomID,
    );
  }

  Future<void> cancelNotification(String roomID) async {
    await _flutterLocalNotificationsPlugin.cancel(roomID.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
