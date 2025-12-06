// File: issue_service.dart (UPDATED)

import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/models/issue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audit_log_service.dart';
import 'cheque_service.dart';

class IssueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();
  final ChequeService _chequeService = ChequeService();

  /// Add issue to cheque
  Future<void> addIssue({
    required String districtId,
    required String periodId,
    required String folderId,
    required String chequeId,
    required IssueType type,
    required String description,
    required String createdBy,
    required String userName,
    required String userRole,
    List<SignatoryType> missingSignatories = const [],
  }) async {
    final issue = Issue(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      description: description,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      status: 'Open',
      missingSignatories: missingSignatories,
    );

    final chequeRef = _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .collection('folders')
        .doc(folderId)
        .collection('cheques')
        .doc(chequeId);

    await chequeRef.update({
      'issues': FieldValue.arrayUnion([issue.toJson()]),
      'status': 'Has Issues',
      'lastUpdatedBy': createdBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _auditLogService.logAction(
      districtId: districtId,
      userId: createdBy,
      userName: userName,
      userRole: userRole,
      action: AuditAction.created,
      targetType: TargetType.issue,
      targetId: issue.id,
      targetName: type.toString(),
      metadata: {'chequeId': chequeId},
    );
  }

  /// Resolve issue
  Future<void> resolveIssue({
    required String districtId,
    required String periodId,
    required String folderId,
    required String chequeId,
    required String issueId,
    required String resolvedBy,
    required String userName,
    required String userRole,
    String? resolutionNotes,
  }) async {
    final cheque = await _chequeService.getCheque(
      districtId,
      periodId,
      folderId,
      chequeId,
    );

    if (cheque == null) throw Exception('Cheque not found');

    final updatedIssues = cheque.issues.map((issue) {
      if (issue.id == issueId) {
        return issue.copyWith(
          status: 'Resolved',
          resolvedBy: resolvedBy,
          resolvedAt: DateTime.now(),
          resolutionNotes: resolutionNotes,
        );
      }
      return issue;
    }).toList();

    // Check if all issues are resolved
    final allResolved = updatedIssues.every(
      (issue) => issue.status == 'Resolved',
    );
    final newStatus = allResolved ? 'Cleared' : 'Has Issues';

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
          'issues': updatedIssues.map((e) => e.toJson()).toList(),
          'status': newStatus,
          'lastUpdatedBy': resolvedBy,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    await _auditLogService.logAction(
      districtId: districtId,
      userId: resolvedBy,
      userName: userName,
      userRole: userRole,
      action: AuditAction.resolved,
      targetType: TargetType.issue,
      targetId: issueId,
      metadata: {'chequeId': chequeId},
    );

    // Update cheque status if all issues resolved
    if (allResolved) {
      await _chequeService.updateChequeStatus(
        districtId: districtId,
        periodId: periodId,
        folderId: folderId,
        chequeId: chequeId,
        status: 'Cleared',
        userId: resolvedBy,
        userName: userName,
        userRole: userRole,
      );
    }
  }
}
