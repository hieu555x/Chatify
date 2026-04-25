import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Function(String roomId, String otherUserId)? _onNotificationTapCallback;

  Future<void> initialize({
    Function(String roomId, String otherUserId)? onNotificationTap,
  }) async {
    if (_isInitialized) return;

    _onNotificationTapCallback = onNotificationTap;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    // Initialize settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  Future<void> showNewMessageNotification({
    required String title,
    required String body,
    required String roomId,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'new_message_channel',
      'New Messages',
      channelDescription: 'Notifications for new messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload ?? roomId,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelRoomNotifications(String roomId) async {
    // Cancel all notifications for a specific room
    // This would require tracking notification IDs per room
    await cancelAllNotifications();
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // Parse the payload to extract room and user information
    if (response.payload != null && _onNotificationTapCallback != null) {
      final payload = response.payload!;
      if (payload.startsWith('room:')) {
        // Parse format: "room:roomId|user:otherUserId"
        final parts = payload.split('|');
        if (parts.length == 2) {
          final roomId = parts[0].replaceFirst('room:', '');
          final otherUserId = parts[1].replaceFirst('user:', '');
          _onNotificationTapCallback!(roomId, otherUserId);
        }
      }
    }
  }

  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // iOS foreground notification handling
  }

  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final isEnabled = await androidPlugin?.areNotificationsEnabled() ?? false;
      return isEnabled;
    } else if (Platform.isIOS) {
      final iOSPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final permissions = await iOSPlugin?.checkPermissions();
      final isEnabled = permissions?.isEnabled ?? false;
      return isEnabled;
    }

    return false;
  }

  Future<void> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final iOSPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await iOSPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Test method to verify notifications work
  Future<void> showTestNotification() async {
    await showNewMessageNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Chatify!',
      roomId: 'test-room',
    );
  }
}