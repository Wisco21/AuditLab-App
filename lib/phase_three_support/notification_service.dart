// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle navigation based on payload
      // You can use a global navigator key or callback
      print('Notification tapped with payload: $payload');
    }
  }

  // Supervisor Assignment Notification
  Future<void> notifySupervisorAssignment({
    required String supervisorId,
    required String chequeNumber,
    required String assignedBy,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'supervisor_assignments',
      'Supervisor Assignments',
      channelDescription: 'Notifications for supervisor assignments',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'New Supervisor Assignment',
      'You have been assigned as supervisor for cheque $chequeNumber by $assignedBy',
      details,
      payload: 'supervisor_assignment:$chequeNumber',
    );
  }

  // Cheque Assignment Notification
  Future<void> notifyChequeAssignment({
    required String userId,
    required String chequeNumber,
    required String assignedBy,
    required String role,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'cheque_assignments',
      'Cheque Assignments',
      channelDescription: 'Notifications for cheque assignments',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'New Cheque Assignment',
      'You have been assigned to cheque $chequeNumber as $role by $assignedBy',
      details,
      payload: 'cheque_assignment:$chequeNumber',
    );
  }

  // Issue Reported Notification
  Future<void> notifyIssueReported({
    required String recipientId,
    required String chequeNumber,
    required String issueType,
    required String reportedBy,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'cheque_issues',
      'Cheque Issues',
      channelDescription: 'Notifications for cheque issues',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Issue Reported',
      'An issue ($issueType) has been reported on cheque $chequeNumber by $reportedBy',
      details,
      payload: 'issue_reported:$chequeNumber',
    );
  }

  // Issue Resolved Notification
  Future<void> notifyIssueResolved({
    required String recipientId,
    required String chequeNumber,
    required String issueType,
    required String resolvedBy,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'cheque_issues',
      'Cheque Issues',
      channelDescription: 'Notifications for cheque issues',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Issue Resolved',
      'The issue ($issueType) on cheque $chequeNumber has been resolved by $resolvedBy',
      details,
      payload: 'issue_resolved:$chequeNumber',
    );
  }

  // Scheduled Reminder
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Scheduled reminders for cheques',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  // Due Date Reminder (1 day before)
  Future<void> scheduleDueDateReminder({
    required String chequeNumber,
    required DateTime dueDate,
  }) async {
    final reminderDate = dueDate.subtract(const Duration(days: 1));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleReminder(
        id: chequeNumber.hashCode,
        title: 'Cheque Due Tomorrow',
        body:
            'Cheque $chequeNumber is due tomorrow on ${dueDate.toString().split(' ')[0]}',
        scheduledDate: reminderDate,
        payload: 'due_reminder:$chequeNumber',
      );
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
