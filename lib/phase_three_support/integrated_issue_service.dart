// lib/services/core/issue_service.dart
import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/models/issue.dart';
import 'package:auditlab/phase_three_support/integrated_cheque_service.dart';
import 'package:auditlab/phase_three_support/notification_repository.dart';
import 'package:auditlab/phase_two_core_features/core_services/audit_log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();
  final ChequeService _chequeService = ChequeService();
  final NotificationRepository _notificationRepo = NotificationRepository();

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
  }) async {
    final issue = Issue(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      description: description,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      status: 'Open',
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

    // ============= NOTIFICATION INTEGRATION =============
    // Get cheque details to find who to notify
    final chequeDoc = await chequeRef.get();
    if (chequeDoc.exists) {
      final chequeData = chequeDoc.data()!;
      final chequeNumber = chequeData['chequeNumber'] as String?;
      final assignedTo = chequeData['assignedTo'] as String?;

      // Get supervisor from period
      final periodDoc = await _db
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(periodId)
          .get();

      final supervisorId = periodDoc.data()?['supervisorId'] as String?;

      // Build list of people to notify
      List<String> recipientIds = [];

      // Notify supervisor
      if (supervisorId != null && supervisorId != createdBy) {
        recipientIds.add(supervisorId);
      }

      // Notify assigned user
      if (assignedTo != null && assignedTo != createdBy) {
        recipientIds.add(assignedTo);
      }

      // Send notifications
      if (recipientIds.isNotEmpty && chequeNumber != null) {
        await _notificationRepo.notifyIssueReported(
          recipientIds: recipientIds,
          chequeNumber: chequeNumber,
          issueType: _getIssueTypeLabel(type),
          reportedByName: userName,
        );
      }
    }
    // ============= END NOTIFICATION INTEGRATION =============
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

    // Find the issue being resolved
    final resolvedIssue = cheque.issues.firstWhere(
      (issue) => issue.id == issueId,
      orElse: () => throw Exception('Issue not found'),
    );

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

    // ============= NOTIFICATION INTEGRATION =============
    // Notify people about issue resolution
    List<String> recipientIds = [];

    // Notify the person who reported the issue
    if (resolvedIssue.createdBy != resolvedBy) {
      recipientIds.add(resolvedIssue.createdBy);
    }

    // Notify supervisor
    final periodDoc = await _db
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(periodId)
        .get();

    final supervisorId = periodDoc.data()?['supervisorId'] as String?;
    if (supervisorId != null && supervisorId != resolvedBy) {
      recipientIds.add(supervisorId);
    }

    // Notify assigned user
    if (cheque.assignedTo != null &&
        cheque.assignedTo != resolvedBy &&
        !recipientIds.contains(cheque.assignedTo)) {
      recipientIds.add(cheque.assignedTo!);
    }

    // Send notifications
    if (recipientIds.isNotEmpty) {
      await _notificationRepo.notifyIssueResolved(
        recipientIds: recipientIds,
        chequeNumber: cheque.chequeNumber,
        issueType: _getIssueTypeLabel(resolvedIssue.type),
        resolvedByName: userName,
      );
    }
    // ============= END NOTIFICATION INTEGRATION =============

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

  /// Helper to get readable issue type label
  String _getIssueTypeLabel(IssueType type) {
    switch (type) {
      case IssueType.missingSignatories:
        return 'Missing Signatories';
      case IssueType.missingVoucher:
        return 'Missing Voucher';
      case IssueType.missingLooseMinute:
        return 'Missing Loose Minute';
      case IssueType.missingRequisition:
        return 'Missing Requisition';
      case IssueType.missingSigningSheet:
        return 'Missing Signing Sheet';
      case IssueType.noInvoice:
        return 'No Invoice';
      case IssueType.missingReceipt:
        return 'Missing Receipt';
      case IssueType.improperSupport:
        return 'Improper Support';
      case IssueType.other:
        return 'Other Issue';
    }
  }
}
