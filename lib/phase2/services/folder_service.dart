// lib/services/core/folder_service.dart
import 'package:auditlab/phase2/models/audit_log.dart';
import 'package:auditlab/phase2/models/folder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audit_log_service.dart';
import 'period_service.dart';

class FolderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();
  final PeriodService _periodService = PeriodService();

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
    await updateFolderProgress(
      districtId: districtId,
      periodId: periodId,
      folderId: folderId,
    );

    final folder = await getFolder(districtId, periodId, folderId);
    if (folder != null && folder.status == 'Completed') {
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
