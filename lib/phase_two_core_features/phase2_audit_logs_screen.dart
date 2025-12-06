// lib/screens/audit/audit_logs_screen.dart
import 'package:auditlab/models/audit_log.dart';
import 'package:auditlab/phase_two_core_features/provider/audit_lo_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtIdAsync = ref.watch(userDistrictIdProvider);
    final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;

    if (!isSupervisor) {
      return Scaffold(
        appBar: AppBar(title: const Text('Audit Logs')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Only supervisors can view audit logs',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs'), elevation: 2),
      body: districtIdAsync.when(
        data: (districtId) {
          if (districtId == null) {
            return const Center(child: Text('No district assigned'));
          }

          final logsAsync = ref.watch(auditLogsProvider(districtId));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(auditLogsProvider(districtId));
            },
            child: logsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No activity logs yet',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final isFirst = index == 0;
                    final isNewDay =
                        isFirst ||
                        !_isSameDay(log.timestamp, logs[index - 1].timestamp);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNewDay) ...[
                          if (!isFirst) const SizedBox(height: 16),
                          _DateHeader(date: log.timestamp),
                          const SizedBox(height: 12),
                        ],
                        _AuditLogCard(log: log),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(auditLogsProvider(districtId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;

  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;

    String dateText;
    if (isToday) {
      dateText = 'Today';
    } else if (isYesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('EEEE, MMMM d, y').format(date);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        dateText,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AuditLog log;

  const _AuditLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getActionColor(log.action).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getActionIcon(log.action),
            color: _getActionColor(log.action),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: log.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' ${_getActionText(log.action)} '),
                    TextSpan(
                      text: _getTargetText(log.targetType),
                      style: TextStyle(
                        color: _getActionColor(log.action),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log.targetName != null) ...[
              const SizedBox(height: 4),
              Text(
                log.targetName!,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('h:mm a').format(log.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(log.userRole).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.userRole,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getRoleColor(log.userRole),
                    ),
                  ),
                ),
              ],
            ),
            if (log.metadata != null && log.metadata!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...log.metadata!.entries.map(
                      (entry) => Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getActionColor(AuditAction action) {
    switch (action) {
      case AuditAction.created:
        return Colors.green;
      case AuditAction.updated:
        return Colors.blue;
      case AuditAction.deleted:
        return Colors.red;
      case AuditAction.assigned:
        return Colors.orange;
      case AuditAction.resolved:
        return Colors.teal;
      case AuditAction.statusChanged:
        return Colors.purple;
    }
  }

  IconData _getActionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.created:
        return Icons.add_circle_outline;
      case AuditAction.updated:
        return Icons.edit_outlined;
      case AuditAction.deleted:
        return Icons.delete_outline;
      case AuditAction.assigned:
        return Icons.person_add_outlined;
      case AuditAction.resolved:
        return Icons.check_circle_outline;
      case AuditAction.statusChanged:
        return Icons.swap_horiz;
    }
  }

  String _getActionText(AuditAction action) {
    switch (action) {
      case AuditAction.created:
        return 'created';
      case AuditAction.updated:
        return 'updated';
      case AuditAction.deleted:
        return 'deleted';
      case AuditAction.assigned:
        return 'assigned';
      case AuditAction.resolved:
        return 'resolved';
      case AuditAction.statusChanged:
        return 'changed status of';
    }
  }

  String _getTargetText(TargetType type) {
    switch (type) {
      case TargetType.period:
        return 'period';
      case TargetType.folder:
        return 'folder';
      case TargetType.cheque:
        return 'cheque';
      case TargetType.issue:
        return 'issue';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'DOF':
        return Colors.blue;
      case 'CA':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
