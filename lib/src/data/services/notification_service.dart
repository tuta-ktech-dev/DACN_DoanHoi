import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Notification Service để xử lý hiển thị thông báo local
/// Sử dụng Awesome Notifications package
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Khởi tạo Awesome Notifications
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // default icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Thông báo cơ bản',
          defaultColor: const Color(0xFF0057B8),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'event_channel',
          channelName: 'Event notifications',
          channelDescription: 'Thông báo sự kiện',
          defaultColor: const Color(0xFF0057B8),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'attendance_channel',
          channelName: 'Attendance notifications',
          channelDescription: 'Thông báo điểm danh',
          defaultColor: const Color(0xFF0057B8),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    // Yêu cầu quyền thông báo
    await requestPermission();
  }

  /// Yêu cầu quyền hiển thị thông báo
  Future<bool> requestPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      final result =
          await AwesomeNotifications().requestPermissionToSendNotifications();
      return result;
    }
    return true;
  }

  /// Hiển thị thông báo từ FCM message
  Future<void> showNotificationFromFCM(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    String channelKey = 'basic_channel';
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'event':
          channelKey = 'event_channel';
          break;
        case 'attendance':
          channelKey = 'attendance_channel';
          break;
      }
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: notification.title ?? 'Thông báo',
        body: notification.body ?? '',
        payload: data.map((key, value) => MapEntry(key, value.toString())),
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  /// Hiển thị thông báo local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? channelKey = 'basic_channel',
    Map<String, String>? payload,
    NotificationLayout layout = NotificationLayout.Default,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey ?? 'basic_channel',
        title: title,
        body: body,
        payload: payload,
        notificationLayout: layout,
      ),
    );
  }

  /// Hiển thị thông báo sự kiện
  Future<void> showEventNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      channelKey: 'event_channel',
      payload: payload,
    );
  }

  /// Hiển thị thông báo điểm danh
  Future<void> showAttendanceNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      channelKey: 'attendance_channel',
      payload: payload,
    );
  }

  /// Lắng nghe action khi user tap vào notification
  void setNotificationActionListener(
      Function(String? payload) onActionReceived) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        final payload = receivedAction.payload;
        if (payload != null && payload.isNotEmpty) {
          onActionReceived(payload['route']); // Hoặc key khác tùy nhu cầu
        }
      },
    );
  }

  /// Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Hủy thông báo theo ID
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Kiểm tra trạng thái permission
  Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }
}
