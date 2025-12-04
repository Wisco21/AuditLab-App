// lib/services/core/audit_log_service.dart
import 'package:auditlab/phase2/models/audit_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Log an action
  Future<void> logAction({
    required String districtId,
    required String userId,
    required String userName,
    required String userRole,
    required AuditAction action,
    required TargetType targetType,
    required String targetId,
    String? targetName,
    Map<String, dynamic>? metadata,
  }) async {
    final docRef = _db
        .collection('districts')
        .doc(districtId)
        .collection('auditLogs')
        .doc();

    final log = AuditLog(
      id: docRef.id,
      districtId: districtId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: action,
      targetType: targetType,
      targetId: targetId,
      targetName: targetName,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await docRef.set(log.toJson());
  }

  /// Get audit logs for district
  Stream<List<AuditLog>> streamAuditLogs(String districtId, {int limit = 100}) {
    return _db
        .collection('districts')
        .doc(districtId)
        .collection('auditLogs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuditLog.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get audit logs filtered by target
  Stream<List<AuditLog>> streamTargetLogs(
    String districtId,
    TargetType targetType,
    String targetId,
  ) {
    return _db
        .collection('districts')
        .doc(districtId)
        .collection('auditLogs')
        .where('targetType', isEqualTo: targetType.toString().split('.').last)
        .where('targetId', isEqualTo: targetId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuditLog.fromJson(doc.data()))
              .toList(),
        );
  }
}
