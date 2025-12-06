// lib/providers/audit/permission_provider.dart
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionChecker {
  final String? userRole;

  PermissionChecker(this.userRole);

  bool get canCreatePeriod => userRole == 'DOF' || userRole == 'CA';
  bool get canCreateFolder => userRole == 'DOF' || userRole == 'CA';
  bool get canAssignCheque => userRole == 'DOF' || userRole == 'CA';
  bool get canViewAuditLogs => userRole == 'DOF' || userRole == 'CA';
  bool get canApprove => userRole == 'DOF' || userRole == 'CA';

  bool canEditCheque(String? assignedTo, String userId) {
    if (canApprove) return true;
    return assignedTo == userId;
  }

  bool canResolveIssue(String? assignedTo, String userId) {
    if (canApprove) return true;
    return assignedTo == userId;
  }
}

final permissionProvider = Provider<PermissionChecker>((ref) {
  final role = ref.watch(userRoleProvider).value;
  return PermissionChecker(role);
});
