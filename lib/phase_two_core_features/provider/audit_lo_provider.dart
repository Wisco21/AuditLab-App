// lib/providers/audit/audit_log_provider.dart
import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/phase_two_core_features/core_services/audit_log_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final auditLogServiceProvider = Provider((ref) => AuditLogService());

final auditLogsProvider = StreamProvider.family<List<AuditLog>, String>((
  ref,
  districtId,
) {
  final service = ref.watch(auditLogServiceProvider);
  return service.streamAuditLogs(districtId);
});
