// lib/repositories/notification_repository.dart
import 'package:auditlab/phase_three_support/notification_model.dart';
import 'package:auditlab/phase_three_support/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Create notification in Firestore and send local notification
  Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic> data = const {},
  }) async {
    final notification = AppNotification(
      id: '',
      userId: userId,
      type: type,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: data,
    );

    await _firestore
        .collection('notifications')
        .add(notification.toFirestore());

    // Send local notification based on type
    await _sendLocalNotification(notification);
  }

  Future<void> _sendLocalNotification(AppNotification notification) async {
    switch (notification.type) {
      case NotificationType.supervisorAssignment:
        await _notificationService.notifySupervisorAssignment(
          supervisorId: notification.userId,
          chequeNumber: notification.data['chequeNumber'] ?? '',
          assignedBy: notification.data['assignedBy'] ?? 'Admin',
        );
        break;
      case NotificationType.chequeAssignment:
        await _notificationService.notifyChequeAssignment(
          userId: notification.userId,
          chequeNumber: notification.data['chequeNumber'] ?? '',
          assignedBy: notification.data['assignedBy'] ?? 'Admin',
          role: notification.data['role'] ?? 'Team Member',
        );
        break;
      case NotificationType.issueReported:
        await _notificationService.notifyIssueReported(
          recipientId: notification.userId,
          chequeNumber: notification.data['chequeNumber'] ?? '',
          issueType: notification.data['issueType'] ?? 'Issue',
          reportedBy: notification.data['reportedBy'] ?? 'User',
        );
        break;
      case NotificationType.issueResolved:
        await _notificationService.notifyIssueResolved(
          recipientId: notification.userId,
          chequeNumber: notification.data['chequeNumber'] ?? '',
          issueType: notification.data['issueType'] ?? 'Issue',
          resolvedBy: notification.data['resolvedBy'] ?? 'User',
        );
        break;
      default:
        // Generic notification
        break;
    }
  }

  // Get notifications for a user
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromFirestore(doc))
              .toList(),
        );
  }

  // Get unread notification count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Clear all notifications
  Future<void> clearAllNotifications(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Get/Set notification preferences
  Future<NotificationPreferences> getPreferences(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications')
        .get();

    if (doc.exists) {
      return NotificationPreferences.fromFirestore(
        doc.data() as Map<String, dynamic>,
      );
    }
    return NotificationPreferences();
  }

  Future<void> updatePreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications')
        .set(preferences.toFirestore());
  }

  // Helper methods for creating specific notifications
  Future<void> notifySupervisorAssignment({
    required String supervisorId,
    required String chequeNumber,
    required String assignedByName,
  }) async {
    await createNotification(
      userId: supervisorId,
      type: NotificationType.supervisorAssignment,
      title: 'New Supervisor Assignment',
      message: 'You have been assigned as supervisor for cheque $chequeNumber',
      data: {'chequeNumber': chequeNumber, 'assignedBy': assignedByName},
    );
  }

  Future<void> notifyChequeAssignment({
    required String userId,
    required String chequeNumber,
    required String role,
    required String assignedByName,
  }) async {
    await createNotification(
      userId: userId,
      type: NotificationType.chequeAssignment,
      title: 'New Cheque Assignment',
      message: 'You have been assigned to cheque $chequeNumber as $role',
      data: {
        'chequeNumber': chequeNumber,
        'role': role,
        'assignedBy': assignedByName,
      },
    );
  }

  Future<void> notifyIssueReported({
    required List<String> recipientIds,
    required String chequeNumber,
    required String issueType,
    required String reportedByName,
  }) async {
    for (final recipientId in recipientIds) {
      await createNotification(
        userId: recipientId,
        type: NotificationType.issueReported,
        title: 'Issue Reported',
        message: 'An issue has been reported on cheque $chequeNumber',
        data: {
          'chequeNumber': chequeNumber,
          'issueType': issueType,
          'reportedBy': reportedByName,
        },
      );
    }
  }

  Future<void> notifyIssueResolved({
    required List<String> recipientIds,
    required String chequeNumber,
    required String issueType,
    required String resolvedByName,
  }) async {
    for (final recipientId in recipientIds) {
      await createNotification(
        userId: recipientId,
        type: NotificationType.issueResolved,
        title: 'Issue Resolved',
        message: 'An issue on cheque $chequeNumber has been resolved',
        data: {
          'chequeNumber': chequeNumber,
          'issueType': issueType,
          'resolvedBy': resolvedByName,
        },
      );
    }
  }

  Future<void> scheduleDueDateReminder({
    required String userId,
    required String chequeNumber,
    required DateTime dueDate,
  }) async {
    await _notificationService.scheduleDueDateReminder(
      chequeNumber: chequeNumber,
      dueDate: dueDate,
    );
  }
}
