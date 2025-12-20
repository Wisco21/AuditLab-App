// lib/services/core/period_service.dart
import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/models/period.dart';
import 'package:auditlab/phase_three_support/notification_model.dart';
import 'package:auditlab/phase_three_support/notification_repository.dart';
import 'package:auditlab/phase_two_core_features/core_services/audit_log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();
  final NotificationRepository _notificationRepo = NotificationRepository();

  /// Create a new period with supervisor assignment and notification
  Future<void> createPeriod({
    required String districtId,
    required String year,
    required String range,
    required String createdBy,
    required String supervisorId,
    required String userName,
    required String userRole,
  }) async {
     print('🔵 Creating period...');
  print('📧 Supervisor ID: $supervisorId');
  print('👤 Created by: $userName');
    final periodId = DateTime.now().millisecondsSinceEpoch.toString();

    final period = Period(
      id: periodId,
      year: year,
      range: range,
      createdBy: createdBy,
      supervisorId: supervisorId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'Pending',
    );

    // Create period in Firestore
    await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .set(period.toJson());

    // Log the action
    await _auditLogService.logAction(
      districtId: districtId,
      userId: createdBy,
      userName: userName,
      userRole: userRole,
      action: AuditAction.created,
      targetType: TargetType.period,
      targetId: periodId,
      targetName: '$year $range',
    );

    // ============= NOTIFICATION INTEGRATION =============
    // Send notification to the assigned supervisor
    final periodName = '$year - $range';

    // Add logging before notification
  print('📬 Attempting to send notification to supervisor: $supervisorId');
  
  try {
    await _notificationRepo.createNotification(
      userId: supervisorId,
      type: NotificationType.supervisorAssignment,
      title: 'New Supervisor Assignment',
      message: 'You have been assigned as supervisor for period $periodName by $userName',
      data: {
        'periodId': periodId,
        'periodName': periodName,
        'year': year,
        'range': range,
        'assignedBy': userName,
        'districtId': districtId,
      },
    );
    print('✅ Notification sent successfully');
  } catch (e) {
    print('❌ Error sending notification: $e');
  }

    
  // Also send local notification
  try {
    await _notificationRepo.notifySupervisorAssignment(
      supervisorId: supervisorId,
      chequeNumber: periodName,
      assignedByName: userName,
    );
    print('✅ Local notification sent');
  } catch (e) {
    print('❌ Error sending local notification: $e');
  }
    // ============= END NOTIFICATION INTEGRATION =============
  }

  /// Update supervisor for existing period
  Future<void> updatePeriodSupervisor({
    required String districtId,
    required String periodId,
    required String newSupervisorId,
    required String updatedBy,
    required String userName,
    required String userRole,
  }) async {
    // Get current period data
    final periodDoc = await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .get();

    if (!periodDoc.exists) {
      throw Exception('Period not found');
    }

    final oldSupervisorId = periodDoc.data()?['supervisorId'] as String?;
    final periodData = periodDoc.data()!;
    final periodName = '${periodData['year']} - ${periodData['range']}';

    // Update supervisor
    await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .update({
          'supervisorId': newSupervisorId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    // Log the action
    await _auditLogService.logAction(
      districtId: districtId,
      userId: updatedBy,
      userName: userName,
      userRole: userRole,
      action: AuditAction.updated,
      targetType: TargetType.period,
      targetId: periodId,
      targetName: periodName,
      metadata: {
        'field': 'supervisorId',
        'oldValue': oldSupervisorId ?? 'none',
        'newValue': newSupervisorId,
      },
    );

    // ============= NOTIFICATION INTEGRATION =============
    // Notify new supervisor
    await _notificationRepo.createNotification(
      userId: newSupervisorId,
      type: NotificationType.supervisorAssignment,
      title: 'New Supervisor Assignment',
      message:
          'You have been assigned as supervisor for period $periodName by $userName',
      data: {
        'periodId': periodId,
        'periodName': periodName,
        'assignedBy': userName,
        'districtId': districtId,
      },
    );

    // Notify old supervisor about removal (if different)
    if (oldSupervisorId != null && oldSupervisorId != newSupervisorId) {
      await _notificationRepo.createNotification(
        userId: oldSupervisorId,
        type: NotificationType.statusUpdate,
        title: 'Supervisor Role Changed',
        message: 'You are no longer the supervisor for period $periodName',
        data: {
          'periodId': periodId,
          'periodName': periodName,
          'updatedBy': userName,
          'districtId': districtId,
        },
      );
    }

    // Send local notifications
    await _notificationRepo.notifySupervisorAssignment(
      supervisorId: newSupervisorId,
      chequeNumber: periodName,
      assignedByName: userName,
    );
    // ============= END NOTIFICATION INTEGRATION =============
  }

  /// Stream periods for a district
  Stream<List<Period>> streamPeriods(String districtId) {
    return _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Period.fromJson(doc.data())).toList(),
        );
  }

  /// Get a single period
  Future<Period?> getPeriod(String districtId, String periodId) async {
    final doc = await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .get();

    if (!doc.exists) return null;
    return Period.fromJson(doc.data()!);
  }

  /// Update period status
  Future<void> updatePeriodStatus({
    required String districtId,
    required String periodId,
    required String status,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    print('═══════════════════════════════════════════');
  print('🔄 UPDATING PERIOD STATUS');
  print('═══════════════════════════════════════════');
  print('Period ID: $periodId');
  print('New Status: $status');
  print('Updated by: $userName ($userId)');
  print('District ID: $districtId');
 // Update the period status
  try {
    print('💾 Updating period status in Firestore...');
    await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('✅ Period status updated');
  } catch (e) {
    print('❌ Error updating period status: $e');
    rethrow;
  }
    // Get period data for notification
  print('📖 Fetching period data...');
  final periodDoc = await _db
      .collection('districts')
      .doc(districtId)
      .collection('periods')
      .doc(periodId)
      .get();

  if (!periodDoc.exists) {
    print('⚠️ Period document not found');
    return;
  }

    final periodData = periodDoc.data();
    final supervisorId = periodData?['supervisorId'] as String?;
    final periodName = '${periodData?['year']} - ${periodData?['range']}';

print('📄 Period name: $periodName');
  print('👤 Supervisor ID: $supervisorId');

  // Log the action
  try {
    print('📝 Creating audit log...');
    await _auditLogService.logAction(
      districtId: districtId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.updated,
      targetType: TargetType.period,
      targetId: periodId,
      targetName: periodName,
      metadata: {'field': 'status', 'newValue': status},
    );
    print('✅ Audit log created');
  } catch (e) {
    print('❌ Error creating audit log: $e');
    // Don't rethrow - continue with notification
  }



  // ============= NOTIFICATION INTEGRATION =============
  // Only notify supervisor if they're not the one making the change
  if (supervisorId != null && supervisorId != userId) {
    print('═══════════════════════════════════════════');
    print('📬 SENDING STATUS UPDATE NOTIFICATION');
    print('═══════════════════════════════════════════');
    print('Target user: $supervisorId');
    print('Updated by: $userName');
    print('New status: $status');
    
    try {
      print('📝 Creating Firestore notification...');
      await _notificationRepo.createNotification(
        userId: supervisorId,
        type: NotificationType.statusUpdate,
        title: 'Period Status Updated',
        message: 'Period $periodName status changed to $status by $userName',
        data: {
          'periodId': periodId,
          'periodName': periodName,
          'status': status,
          'updatedBy': userName,
          'districtId': districtId,
        },
      );
      print('✅ Notification sent to supervisor');
    } catch (e, stackTrace) {
      print('❌ Error sending notification: $e');
      print('Stack trace: $stackTrace');
      // Don't rethrow - status update succeeded
    }
  } else {
    if (supervisorId == null) {
      print('⚠️ No supervisor assigned - skipping notification');
    } else if (supervisorId == userId) {
      print('ℹ️ Supervisor updated their own period - skipping self-notification');
    }
  }

   print('═══════════════════════════════════════════');
  print('✅ PERIOD STATUS UPDATE COMPLETE');
  print('═══════════════════════════════════════════');

   
  }

  /// Delete period
  Future<void> deletePeriod({
    required String districtId,
    required String periodId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    // Get period data before deletion
    final periodDoc = await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .get();

    final periodData = periodDoc.data();
    final periodName = '${periodData?['year']} - ${periodData?['range']}';

    // Delete the period
    await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .delete();

    // Log the action
    await _auditLogService.logAction(
      districtId: districtId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.deleted,
      targetType: TargetType.period,
      targetId: periodId,
      targetName: periodName,
    );
  }

  /// Check and update period status based on folders
  Future<void> checkAndUpdatePeriodStatus({
    required String districtId,
    required String periodId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    final foldersSnapshot = await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .get();

    if (foldersSnapshot.docs.isEmpty) return;

    final allCompleted = foldersSnapshot.docs.every(
      (doc) => doc.data()['status'] == 'Completed',
    );

    if (allCompleted) {
      await updatePeriodStatus(
        districtId: districtId,
        periodId: periodId,
        status: 'Completed',
        userId: userId,
        userName: userName,
        userRole: userRole,
      );
    }
  }
}
