// lib/phase_two_core_features/core_services/cheque_service.dart
// Add this method to your existing ChequeService class

import 'package:auditlab/phase_three_support/notification_model.dart';
import 'package:auditlab/phase_three_support/notification_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/cheque.dart';
// import '../../repositories/notification_repository.dart';

class ChequeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationRepository _notificationRepo = NotificationRepository();

  // ... your existing methods ...

  /// Assign cheque to a user
  Future<void> assignCheque({
    required String districtId,
    required String periodId,
    required String folderId,
    required String chequeId,
    required String assignedToUserId,
    required String assignedByUserId,
    required String assignedByName,
    required String assignedToName,
  }) async {
    final chequeRef = _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .collection('cheques')
        .doc(chequeId);

    // Update cheque with assignment
    await chequeRef.update({
      'assignedTo': assignedToUserId,
      'lastUpdatedBy': assignedByUserId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Get cheque details for notification
    final chequeDoc = await chequeRef.get();
    if (chequeDoc.exists) {
      final chequeData = chequeDoc.data()!;
      final chequeNumber = chequeData['chequeNumber'] as String?;

      // ============= NOTIFICATION INTEGRATION =============
      if (chequeNumber != null) {
        // Get user's role from Firestore
        final userDoc = await _db
            .collection('users')
            .doc(assignedToUserId)
            .get();
        final userRole = userDoc.data()?['role'] as String? ?? 'Team Member';

        await _notificationRepo.notifyChequeAssignment(
          userId: assignedToUserId,
          chequeNumber: chequeNumber,
          role: userRole,
          assignedByName: assignedByName,
        );
      }
      // ============= END NOTIFICATION INTEGRATION =============
    }
  }

  /// Bulk assign cheques to multiple users
  Future<void> bulkAssignCheques({
    required String districtId,
    required String periodId,
    required String folderId,
    required List<String> chequeIds,
    required String assignedToUserId,
    required String assignedByUserId,
    required String assignedByName,
  }) async {
    final batch = _db.batch();

    // Get user details
    final userDoc = await _db.collection('users').doc(assignedToUserId).get();
    final userRole = userDoc.data()?['role'] as String? ?? 'Team Member';

    List<String> chequeNumbers = [];

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
        'assignedTo': assignedToUserId,
        'lastUpdatedBy': assignedByUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get cheque number for notifications
      final chequeDoc = await chequeRef.get();
      if (chequeDoc.exists) {
        final chequeNumber = chequeDoc.data()?['chequeNumber'] as String?;
        if (chequeNumber != null) {
          chequeNumbers.add(chequeNumber);
        }
      }
    }

    await batch.commit();

    // ============= NOTIFICATION INTEGRATION =============
    // Send a single notification for bulk assignment
    if (chequeNumbers.isNotEmpty) {
      final count = chequeNumbers.length;
      final message = count == 1
          ? 'You have been assigned to cheque ${chequeNumbers.first} as $userRole by $assignedByName'
          : 'You have been assigned to $count cheques as $userRole by $assignedByName';

      await _notificationRepo.createNotification(
        userId: assignedToUserId,
        type: NotificationType.chequeAssignment,
        title: 'New Cheque Assignment${count > 1 ? 's' : ''}',
        message: message,
        data: {
          'chequeNumbers': chequeNumbers,
          'role': userRole,
          'assignedBy': assignedByName,
          'count': count,
        },
      );
    }
    // ============= END NOTIFICATION INTEGRATION =============
  }

  /// Update cheque status
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

    // ============= NOTIFICATION INTEGRATION =============
    // Notify assigned user about status change
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

    if (chequeDoc.exists) {
      final chequeData = chequeDoc.data()!;
      final assignedTo = chequeData['assignedTo'] as String?;
      final chequeNumber = chequeData['chequeNumber'] as String?;

      if (assignedTo != null && assignedTo != userId && chequeNumber != null) {
        await _notificationRepo.createNotification(
          userId: assignedTo,
          type: NotificationType.statusUpdate,
          title: 'Cheque Status Updated',
          message:
              'Cheque $chequeNumber status changed to $status by $userName',
          data: {
            'chequeNumber': chequeNumber,
            'status': status,
            'updatedBy': userName,
          },
        );
      }
    }
    // ============= END NOTIFICATION INTEGRATION =============
  }

  // ... rest of your existing methods ...

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

  /// Stream cheques for a folder
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
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Cheque.fromJson(doc.data())).toList(),
        );
  }

  /// Stream cheques assigned to a user
  Stream<List<Cheque>> streamUserCheques(String districtId, String userId) {
    return _db
        .collectionGroup('cheques')
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Cheque> cheques = [];

          for (var doc in snapshot.docs) {
            // Verify the cheque belongs to the correct district
            final path = doc.reference.path;
            if (path.contains('districts/$districtId/')) {
              cheques.add(Cheque.fromJson(doc.data()));
            }
          }

          // Sort by updated date
          cheques.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return cheques;
        });
  }
}
