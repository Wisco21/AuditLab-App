// lib/services/core/folder_service.dart
import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/models/folder.dart';
import 'package:auditlab/phase_three_support/notification_model.dart';
import 'package:auditlab/phase_three_support/notification_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audit_log_service.dart';
import 'period_service.dart';

class FolderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();
  final PeriodService _periodService = PeriodService();
  final NotificationRepository _notificationRepo = NotificationRepository();

  /// Create a new folder (DOF/CA only)
  Future<String> createFolder({
    required String districtId,
    required String periodId,
    required String folderNumber,
    required String chequeRangeStart,
    required String chequeRangeEnd,
    required String createdBy,
    required String userName,
    required String userRole,
  }) async {
    print('═══════════════════════════════════════════');
    print('📁 CREATING FOLDER');
    print('═══════════════════════════════════════════');
    print('Folder number: $folderNumber');
    print('Cheque range: $chequeRangeStart - $chequeRangeEnd');
    print('Created by: $userName');

    final docRef = _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc();

    final folder = Folder(
      id: docRef.id,
      periodId: periodId,
      folderNumber: folderNumber,
      chequeRangeStart: chequeRangeStart,
      chequeRangeEnd: chequeRangeEnd,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastUpdatedBy: createdBy,
      status: 'Pending',
      totalCheques: 0,
      completedCheques: 0,
    );

    await docRef.set(folder.toJson());
    print('✅ Folder created');

    await _auditLogService.logAction(
      districtId: districtId,
      userId: createdBy,
      userName: userName,
      userRole: userRole,
      action: AuditAction.created,
      targetType: TargetType.folder,
      targetId: docRef.id,
      targetName: 'Folder $folderNumber',
    );

    // ============= NOTIFICATION FOR SUPERVISOR =============
    print('═══════════════════════════════════════════');
    print('📬 SENDING FOLDER CREATION NOTIFICATION');
    print('═══════════════════════════════════════════');

    try {
      // Get period supervisor
      final periodDoc = await _db
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(periodId)
          .get();

      final supervisorId = periodDoc.data()?['supervisorId'] as String?;
      final periodData = periodDoc.data();
      final periodName = '${periodData?['year']} - ${periodData?['range']}';

      print('👤 Period supervisor: $supervisorId');
      print('📅 Period: $periodName');

      // Notify supervisor if they didn't create it
      if (supervisorId != null && supervisorId != createdBy) {
        await _notificationRepo.createNotification(
          userId: supervisorId,
          type: NotificationType.statusUpdate,
          title: 'New Folder Created',
          message: 'Folder $folderNumber created in period $periodName by $userName',
          data: {
            'folderId': docRef.id,
            'folderNumber': folderNumber,
            'periodId': periodId,
            'periodName': periodName,
            'chequeRange': '$chequeRangeStart - $chequeRangeEnd',
            'createdBy': userName,
            'districtId': districtId,
          },
        );
        print('✅ Notification sent to supervisor');
      } else {
        if (supervisorId == null) {
          print('⚠️ No supervisor assigned to period');
        } else {
          print('ℹ️ Supervisor created the folder - skipping self-notification');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error sending notification: $e');
      print('Stack trace: $stackTrace');
      // Don't rethrow - folder was created successfully
    }
    print('═══════════════════════════════════════════');

    return docRef.id;
  }

  /// Get folders for a period
  Stream<List<Folder>> streamFolders(String districtId, String periodId) {
    return _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .orderBy('folderNumber')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Folder.fromJson(doc.data())).toList(),
        );
  }

  /// Get a single folder
  Future<Folder?> getFolder(
    String districtId,
    String periodId,
    String folderId,
  ) async {
    final doc = await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .get();

    if (!doc.exists) return null;
    return Folder.fromJson(doc.data()!);
  }

  /// Update folder progress
  Future<void> updateFolderProgress({
    required String districtId,
    required String periodId,
    required String folderId,
  }) async {
    print('📊 Updating folder progress: $folderId');

    final chequesSnapshot = await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .collection('cheques')
        .get();

    final totalCheques = chequesSnapshot.docs.length;
    final completedCheques = chequesSnapshot.docs
        .where((doc) => doc.data()['status'] == 'Cleared')
        .length;

    String status = 'Pending';
    if (totalCheques > 0) {
      if (completedCheques == totalCheques) {
        status = 'Completed';
      } else if (completedCheques > 0) {
        status = 'In Progress';
      }
    }

    print('📊 Progress: $completedCheques/$totalCheques cheques cleared');
    print('📊 New status: $status');

    // Get old status before updating
    final folderDoc = await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .get();

    final oldStatus = folderDoc.data()?['status'] as String?;

    await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .update({
      'totalCheques': totalCheques,
      'completedCheques': completedCheques,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // ============= NOTIFICATION WHEN FOLDER COMPLETED =============
    // Only notify if status changed to Completed
    if (oldStatus != 'Completed' && status == 'Completed') {
      print('═══════════════════════════════════════════');
      print('🎉 FOLDER COMPLETED - SENDING NOTIFICATION');
      print('═══════════════════════════════════════════');

      try {
        // Get folder and period info
        final folderData = folderDoc.data();
        final folderNumber = folderData?['folderNumber'] as String?;

        final periodDoc = await _db
            .collection('districts')
            .doc(districtId)
            .collection('periods')
            .doc(periodId)
            .get();

        final supervisorId = periodDoc.data()?['supervisorId'] as String?;
        final periodData = periodDoc.data();
        final periodName = '${periodData?['year']} - ${periodData?['range']}';

        print('📁 Folder number: $folderNumber');
        print('👤 Supervisor: $supervisorId');
        print('📅 Period: $periodName');

        // Notify supervisor
        if (supervisorId != null && folderNumber != null) {
          await _notificationRepo.createNotification(
            userId: supervisorId,
            type: NotificationType.statusUpdate,
            title: 'Folder Completed',
            message: 'Folder $folderNumber in period $periodName has been completed! All $totalCheques cheques cleared.',
            data: {
              'folderId': folderId,
              'folderNumber': folderNumber,
              'periodId': periodId,
              'periodName': periodName,
              'totalCheques': totalCheques,
              'districtId': districtId,
            },
          );
          print('✅ Completion notification sent to supervisor');
        }
      } catch (e, stackTrace) {
        print('❌ Error sending completion notification: $e');
        print('Stack trace: $stackTrace');
        // Don't rethrow - progress update succeeded
      }
      print('═══════════════════════════════════════════');
    }
  }

  /// Check and update folder status based on cheques
  Future<void> checkAndUpdateFolderStatus({
    required String districtId,
    required String periodId,
    required String folderId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    print('🔍 Checking folder status...');

    await updateFolderProgress(
      districtId: districtId,
      periodId: periodId,
      folderId: folderId,
    );

    final folder = await getFolder(districtId, periodId, folderId);
    if (folder != null && folder.status == 'Completed') {
      print('✅ Folder completed - checking period status...');
      await _periodService.checkAndUpdatePeriodStatus(
        districtId: districtId,
        periodId: periodId,
        userId: userId,
        userName: userName,
        userRole: userRole,
      );
    }
  }
}
