// lib/services/core/cheque_service.dart
import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/models/cheque.dart';
import 'package:auditlab/phase_three_support/notification_model.dart';
import 'package:auditlab/phase_three_support/notification_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audit_log_service.dart';
import 'folder_service.dart';

class ChequeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();
  final FolderService _folderService = FolderService();
  final NotificationRepository _notificationRepo = NotificationRepository();

  /// Create a new cheque
  Future<String> createCheque({
    required String districtId,
    required String periodId,
    required String folderId,
    required String chequeNumber,
    required String sectorCode,
    required String createdBy,
    required String userName,
    required String userRole,
    String? assignedTo,
    String? payee,
    double? amount,
    String? description,
  }) async {
    print('═══════════════════════════════════════════');
    print('📝 CREATING CHEQUE');
    print('═══════════════════════════════════════════');
    print('Cheque number: $chequeNumber');
    print('Created by: $userName');
    print('Assigned to: ${assignedTo ?? "Unassigned"}');

    final docRef = _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .collection('cheques')
        .doc();

    final cheque = Cheque(
      id: docRef.id,
      folderId: folderId,
      periodId: periodId,
      chequeNumber: chequeNumber,
      sectorCode: sectorCode,
      assignedTo: assignedTo,
      lastUpdatedBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'Pending',
      issues: [],
      payee: payee,
      amount: amount,
      description: description,
    );

    await docRef.set(cheque.toJson());
    print('✅ Cheque created');

    await _auditLogService.logAction(
      districtId: districtId,
      userId: createdBy,
      userName: userName,
      userRole: userRole,
      action: AuditAction.created,
      targetType: TargetType.cheque,
      targetId: docRef.id,
      targetName: 'Cheque $chequeNumber',
    );

    // ============= NOTIFICATION FOR INITIAL ASSIGNMENT =============
    if (assignedTo != null && assignedTo != createdBy) {
      print('═══════════════════════════════════════════');
      print('📬 SENDING ASSIGNMENT NOTIFICATION');
      print('═══════════════════════════════════════════');
      print('Target user: $assignedTo');

      try {
        // Get assigned user's role
        final userDoc = await _db.collection('users').doc(assignedTo).get();
        final userRole = userDoc.data()?['role'] as String? ?? 'Team Member';

        await _notificationRepo.notifyChequeAssignment(
          userId: assignedTo,
          chequeNumber: chequeNumber,
          role: userRole,
          assignedByName: userName,
        );
        print('✅ Assignment notification sent');
      } catch (e) {
        print('❌ Error sending assignment notification: $e');
        // Don't rethrow - cheque was created successfully
      }
      print('═══════════════════════════════════════════');
    }

    // Update folder progress
    await _folderService.updateFolderProgress(
      districtId: districtId,
      periodId: periodId,
      folderId: folderId,
    );

    return docRef.id;
  }

  /// Get cheques for a folder
  Stream<List<Cheque>> streamCheques(
    String districtId,
    String periodId,
    String folderId,
  ) {
    return _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .collection('cheques')
        .orderBy('chequeNumber')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Cheque.fromJson(doc.data())).toList(),
        );
  }

  /// Get cheques assigned to a user
  Stream<List<Cheque>> streamUserCheques(String districtId, String userId) {
    return _db
        .collectionGroup('cheques')
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final cheques = <Cheque>[];
          for (var doc in snapshot.docs) {
            // Verify district by checking parent path
            final path = doc.reference.path;
            if (path.contains(districtId)) {
              cheques.add(Cheque.fromJson(doc.data()));
            }
          }
          return cheques;
        });
  }

  /// Get a single cheque
  Future<Cheque?> getCheque(
    String districtId,
    String periodId,
    String folderId,
    String chequeId,
  ) async {
    final doc = await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .collection('cheques')
        .doc(chequeId)
        .get();

    if (!doc.exists) return null;
    return Cheque.fromJson(doc.data()!);
  }

  /// Assign cheque to user with notification
  Future<void> assignCheque({
    required String districtId,
    required String periodId,
    required String folderId,
    required String chequeId,
    required String assignedTo,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    print('═══════════════════════════════════════════');
    print('👤 ASSIGNING CHEQUE');
    print('═══════════════════════════════════════════');
    print('Cheque ID: $chequeId');
    print('Assigned to: $assignedTo');
    print('Assigned by: $userName');

    await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .collection('cheques')
        .doc(chequeId)
        .update({
      'assignedTo': assignedTo,
      'lastUpdatedBy': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('✅ Cheque assigned');

    await _auditLogService.logAction(
      districtId: districtId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.assigned,
      targetType: TargetType.cheque,
      targetId: chequeId,
      metadata: {'assignedTo': assignedTo},
    );

    // ============= NOTIFICATION INTEGRATION =============
    // Only notify if assigning to someone else
    if (assignedTo != userId) {
      print('═══════════════════════════════════════════');
      print('📬 SENDING ASSIGNMENT NOTIFICATION');
      print('═══════════════════════════════════════════');

      try {
        // Get cheque details
        final chequeDoc = await _db
            .collection('districts')
            .doc(districtId)
            .collection('periods')
            .doc(periodId)
            .collection('folders')
            .doc(folderId)
            .collection('cheques')
            .doc(chequeId)
            .get();

        final chequeNumber = chequeDoc.data()?['chequeNumber'] as String?;

        if (chequeNumber != null) {
          // Get assigned user's role
          final userDoc = await _db.collection('users').doc(assignedTo).get();
          final assignedUserRole = userDoc.data()?['role'] as String? ?? 'Team Member';

          await _notificationRepo.notifyChequeAssignment(
            userId: assignedTo,
            chequeNumber: chequeNumber,
            role: assignedUserRole,
            assignedByName: userName,
          );
          print('✅ Assignment notification sent');
        }
      } catch (e, stackTrace) {
        print('❌ Error sending notification: $e');
        print('Stack trace: $stackTrace');
        // Don't rethrow - assignment succeeded
      }
      print('═══════════════════════════════════════════');
    } else {
      print('ℹ️ Self-assignment - no notification sent');
    }
  }

  /// Bulk assign cheques to user with notification
  Future<void> bulkAssignCheques({
    required String districtId,
    required String periodId,
    required String folderId,
    required List<String> chequeIds,
    required String assignedTo,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    print('═══════════════════════════════════════════');
    print('👥 BULK ASSIGNING CHEQUES');
    print('═══════════════════════════════════════════');
    print('Number of cheques: ${chequeIds.length}');
    print('Assigned to: $assignedTo');
    print('Assigned by: $userName');

    final batch = _db.batch();
    final List<String> chequeNumbers = [];

    for (final chequeId in chequeIds) {
      final chequeRef = _db
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(periodId)
          .collection('folders')
          .doc(folderId)
          .collection('cheques')
          .doc(chequeId);

      batch.update(chequeRef, {
        'assignedTo': assignedTo,
        'lastUpdatedBy': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Collect cheque numbers for notification
      final chequeDoc = await chequeRef.get();
      if (chequeDoc.exists) {
        final chequeNumber = chequeDoc.data()?['chequeNumber'] as String?;
        if (chequeNumber != null) {
          chequeNumbers.add(chequeNumber);
        }
      }
    }

    await batch.commit();
    print('✅ ${chequeIds.length} cheques assigned');

    // ============= NOTIFICATION INTEGRATION =============
    // Only notify if assigning to someone else
    if (assignedTo != userId && chequeNumbers.isNotEmpty) {
      print('═══════════════════════════════════════════');
      print('📬 SENDING BULK ASSIGNMENT NOTIFICATION');
      print('═══════════════════════════════════════════');

      try {
        // Get assigned user's role
        final userDoc = await _db.collection('users').doc(assignedTo).get();
        final assignedUserRole = userDoc.data()?['role'] as String? ?? 'Team Member';

        final count = chequeNumbers.length;
        final message = count == 1
            ? 'You have been assigned to cheque ${chequeNumbers.first} as $assignedUserRole by $userName'
            : 'You have been assigned to $count cheques as $assignedUserRole by $userName';

        await _notificationRepo.createNotification(
          userId: assignedTo,
          type: NotificationType.chequeAssignment,
          title: 'New Cheque Assignment${count > 1 ? 's' : ''}',
          message: message,
          data: {
            'chequeNumbers': chequeNumbers,
            'role': assignedUserRole,
            'assignedBy': userName,
            'count': count,
            'districtId': districtId,
            'periodId': periodId,
            'folderId': folderId,
          },
        );
        print('✅ Bulk assignment notification sent');
      } catch (e, stackTrace) {
        print('❌ Error sending notification: $e');
        print('Stack trace: $stackTrace');
        // Don't rethrow - assignments succeeded
      }
      print('═══════════════════════════════════════════');
    }
  }

  /// Update cheque status with notification
  Future<void> updateChequeStatus({
    required String districtId,
    required String periodId,
    required String folderId,
    required String chequeId,
    required String status,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    print('═══════════════════════════════════════════');
    print('🔄 UPDATING CHEQUE STATUS');
    print('═══════════════════════════════════════════');
    print('Cheque ID: $chequeId');
    print('New status: $status');
    print('Updated by: $userName');

    await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .collection('cheques')
        .doc(chequeId)
        .update({
      'status': status,
      'lastUpdatedBy': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('✅ Status updated');

    await _auditLogService.logAction(
      districtId: districtId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.statusChanged,
      targetType: TargetType.cheque,
      targetId: chequeId,
      metadata: {'newStatus': status},
    );

    // ============= NOTIFICATION INTEGRATION =============
    print('═══════════════════════════════════════════');
    print('📬 SENDING STATUS UPDATE NOTIFICATION');
    print('═══════════════════════════════════════════');

    try {
      // Get cheque details
      final chequeDoc = await _db
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(periodId)
          .collection('folders')
          .doc(folderId)
          .collection('cheques')
          .doc(chequeId)
          .get();

      final assignedTo = chequeDoc.data()?['assignedTo'] as String?;
      final chequeNumber = chequeDoc.data()?['chequeNumber'] as String?;

      print('👤 Assigned to: $assignedTo');
      print('📄 Cheque number: $chequeNumber');

      // Notify assigned user if they didn't make the change
      if (assignedTo != null && assignedTo != userId && chequeNumber != null) {
        await _notificationRepo.createNotification(
          userId: assignedTo,
          type: NotificationType.statusUpdate,
          title: 'Cheque Status Updated',
          message: 'Cheque $chequeNumber status changed to $status by $userName',
          data: {
            'chequeId': chequeId,
            'chequeNumber': chequeNumber,
            'status': status,
            'updatedBy': userName,
            'districtId': districtId,
            'periodId': periodId,
            'folderId': folderId,
          },
        );
        print('✅ Status notification sent to assigned user');
      } else {
        if (assignedTo == null) {
          print('ℹ️ No assigned user - skipping notification');
        } else if (assignedTo == userId) {
          print('ℹ️ User updated their own cheque - skipping self-notification');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error sending notification: $e');
      print('Stack trace: $stackTrace');
      // Don't rethrow - status update succeeded
    }
    print('═══════════════════════════════════════════');

    // Update folder progress
    await _folderService.checkAndUpdateFolderStatus(
      districtId: districtId,
      periodId: periodId,
      folderId: folderId,
      userId: userId,
      userName: userName,
      userRole: userRole,
    );
  }

}
