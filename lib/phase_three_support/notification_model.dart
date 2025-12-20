// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  supervisorAssignment,
  chequeAssignment,
  issueReported,
  issueResolved,
  dueReminder,
  statusUpdate,
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> data;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.data = const {},
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.statusUpdate,
      ),
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      data: data['data'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'data': data,
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

class NotificationPreferences {
  final bool supervisorAssignments;
  final bool chequeAssignments;
  final bool issueAlerts;
  final bool dueReminders;
  final bool statusUpdates;

  NotificationPreferences({
    this.supervisorAssignments = true,
    this.chequeAssignments = true,
    this.issueAlerts = true,
    this.dueReminders = true,
    this.statusUpdates = true,
  });

  factory NotificationPreferences.fromFirestore(Map<String, dynamic> data) {
    return NotificationPreferences(
      supervisorAssignments: data['supervisorAssignments'] ?? true,
      chequeAssignments: data['chequeAssignments'] ?? true,
      issueAlerts: data['issueAlerts'] ?? true,
      dueReminders: data['dueReminders'] ?? true,
      statusUpdates: data['statusUpdates'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'supervisorAssignments': supervisorAssignments,
      'chequeAssignments': chequeAssignments,
      'issueAlerts': issueAlerts,
      'dueReminders': dueReminders,
      'statusUpdates': statusUpdates,
    };
  }

  NotificationPreferences copyWith({
    bool? supervisorAssignments,
    bool? chequeAssignments,
    bool? issueAlerts,
    bool? dueReminders,
    bool? statusUpdates,
  }) {
    return NotificationPreferences(
      supervisorAssignments: supervisorAssignments ?? this.supervisorAssignments,
      chequeAssignments: chequeAssignments ?? this.chequeAssignments,
      issueAlerts: issueAlerts ?? this.issueAlerts,
      dueReminders: dueReminders ?? this.dueReminders,
      statusUpdates: statusUpdates ?? this.statusUpdates,
    );
  }
}