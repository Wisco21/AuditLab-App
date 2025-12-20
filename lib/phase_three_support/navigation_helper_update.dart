// Add these utility classes to help with notifications throughout your app

// lib/helpers/notification_helper.dart
import 'package:auditlab/phase_three_support/notification_model.dart';
import 'package:auditlab/phase_three_support/notification_repository.dart';
import 'package:auditlab/phase_two_core_features/pages/notification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationHelper {
  static final NotificationRepository _notificationRepo =
      NotificationRepository();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get current user's name
  static Future<String> getCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Unknown User';

    try {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      return userDoc.data()?['name'] as String? ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  /// Get user's name by ID
  static Future<String> getUserName(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      return userDoc.data()?['name'] as String? ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  /// Send notification when assigning supervisor
  static Future<void> notifySupervisorAssignment({
    required String supervisorId,
    required String periodName,
    required String assignedByName,
  }) async {
    await _notificationRepo.createNotification(
      userId: supervisorId,
      type: NotificationType.supervisorAssignment,
      title: 'New Supervisor Assignment',
      message:
          'You have been assigned as supervisor for period $periodName by $assignedByName',
      data: {'periodName': periodName, 'assignedBy': assignedByName},
    );
  }

  /// Send notification when assigning cheque
  static Future<void> notifyChequeAssignment({
    required String userId,
    required String chequeNumber,
    required String assignedByName,
  }) async {
    // Get user's role
    final userDoc = await _db.collection('users').doc(userId).get();
    final role = userDoc.data()?['role'] as String? ?? 'Team Member';

    await _notificationRepo.notifyChequeAssignment(
      userId: userId,
      chequeNumber: chequeNumber,
      role: role,
      assignedByName: assignedByName,
    );
  }

  /// Send notification when issue is reported
  static Future<void> notifyIssueReported({
    required List<String> recipientIds,
    required String chequeNumber,
    required String issueType,
    required String reportedByName,
  }) async {
    await _notificationRepo.notifyIssueReported(
      recipientIds: recipientIds,
      chequeNumber: chequeNumber,
      issueType: issueType,
      reportedByName: reportedByName,
    );
  }

  /// Send notification when issue is resolved
  static Future<void> notifyIssueResolved({
    required List<String> recipientIds,
    required String chequeNumber,
    required String issueType,
    required String resolvedByName,
  }) async {
    await _notificationRepo.notifyIssueResolved(
      recipientIds: recipientIds,
      chequeNumber: chequeNumber,
      issueType: issueType,
      resolvedByName: resolvedByName,
    );
  }

  /// Schedule reminder for cheque due date
  static Future<void> scheduleChequeDueReminder({
    required String userId,
    required String chequeNumber,
    required DateTime dueDate,
  }) async {
    await _notificationRepo.scheduleDueDateReminder(
      userId: userId,
      chequeNumber: chequeNumber,
      dueDate: dueDate,
    );
  }
}


class NotificationBadgeButton extends StatelessWidget {
  const NotificationBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: NotificationRepository().getUnreadCount(user.uid),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        return badges.Badge(
          showBadge: unreadCount > 0,
          badgeContent: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const NotificationsScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
