// / lib/services/core/cheque_service.dart
import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/models/cheque.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audit_log_service.dart';
import 'folder_service.dart';

class ChequeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();
  final FolderService _folderService = FolderService();

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

  /// Assign cheque to user
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
