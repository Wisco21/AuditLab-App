// lib/services/core/period_service.dart
import 'package:auditlab/phase2/models/audit_log.dart';
import 'package:auditlab/phase2/models/period.dart';
import 'package:auditlab/phase2/services/audit_log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();

  /// Create a new period (DOF/CA only)
  Future<String> createPeriod({
    required String districtId,
    required String year,
    required String range,
    required String createdBy,
    required String supervisorId,
    required String userName,
    required String userRole,
  }) async {
    final docRef = _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc();

    final period = Period(
      id: docRef.id,
      year: year,
      range: range,
      createdBy: createdBy,
      supervisorId: supervisorId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'Pending',
    );

    await docRef.set(period.toJson());

    // Log the action
    await _auditLogService.logAction(
      districtId: districtId,
      userId: createdBy,
      userName: userName,
      userRole: userRole,
      action: AuditAction.created,
      targetType: TargetType.period,
      targetId: docRef.id,
      targetName: '$year - $range',
    );

    return docRef.id;
  }

  /// Get all periods for a district
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
    await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});

    await _auditLogService.logAction(
      districtId: districtId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.statusChanged,
      targetType: TargetType.period,
      targetId: periodId,
      metadata: {'newStatus': status},
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
