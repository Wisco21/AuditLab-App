// lib/screens/audit/cheque_details_screen.dart
import 'package:auditlab/models/models_sector.dart';
import 'package:auditlab/phase2/models/cheque.dart';
import 'package:auditlab/phase2/models/folder.dart';
import 'package:auditlab/phase2/models/issue.dart';
import 'package:auditlab/phase2/phase2_issue_dialogs.dart';
import 'package:auditlab/phase2/provider/cheque_provider.dart';
import 'package:auditlab/phase2/provider/permission_provider.dart';
import 'package:auditlab/phase2/provider/user_provider.dart';
import 'package:auditlab/phase2/widgets/resolve_issue_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChequeDetailsScreen extends ConsumerWidget {
  final String districtId;
  final Folder folder;
  final Cheque cheque;

  const ChequeDetailsScreen({
    super.key,
    required this.districtId,
    required this.folder,
    required this.cheque,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser!;
    final permission = ref.watch(permissionProvider);
    final canEdit = permission.canEditCheque(cheque.assignedTo, user.uid);
    final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cheque #${cheque.chequeNumber}'),
        actions: [
          if (isSupervisor)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOptionsMenu(context, ref),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _getStatusColor(cheque.status).withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(cheque.status),
                    color: _getStatusColor(cheque.status),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          cheque.status,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(cheque.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Cheque Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cheque Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    'Cheque Number',
                    cheque.chequeNumber,
                    Icons.receipt,
                  ),
                  if (cheque.payee != null)
                    _buildInfoRow(
                      context,
                      'Payee',
                      cheque.payee!,
                      Icons.person_outline,
                    ),
                  if (cheque.amount != null)
                    _buildInfoRow(
                      context,
                      'Amount',
                      'MK ${cheque.amount!.toStringAsFixed(2)}',
                      Icons.attach_money,
                    ),
                  _buildInfoRow(
                    context,
                    'Sector',
                    _getSectorName(cheque.sectorCode),
                    Icons.business,
                  ),
                  if (cheque.description != null)
                    _buildInfoRow(
                      context,
                      'Description',
                      cheque.description!,
                      Icons.notes,
                    ),
                  _buildInfoRow(
                    context,
                    'Created',
                    DateFormat('MMM d, y • h:mm a').format(cheque.createdAt),
                    Icons.calendar_today,
                  ),
                  _buildInfoRow(
                    context,
                    'Last Updated',
                    DateFormat('MMM d, y • h:mm a').format(cheque.updatedAt),
                    Icons.update,
                  ),
                  const SizedBox(height: 24),

                  // Issues Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Issues',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSupervisor)
                        TextButton.icon(
                          onPressed: () => _showAddIssueDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Issue'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (cheque.issues.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No issues found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This cheque is clear',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...cheque.issues.map(
                      (issue) => _IssueCard(
                        issue: issue,
                        cheque: cheque,
                        districtId: districtId,
                        folder: folder,
                        canResolve: canEdit,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSectorName(String code) {
    final sector = Sector.getByCode(code);
    return sector?.displayName ?? code;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Cleared':
        return Colors.green;
      case 'Has Issues':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Cleared':
        return Icons.check_circle;
      case 'Has Issues':
        return Icons.warning_amber;
      default:
        return Icons.pending;
    }
  }

  void _showAddIssueDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddIssueDialog(
        districtId: districtId,
        periodId: folder.periodId,
        folderId: folder.id,
        chequeId: cheque.id,
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Assign to Staff'),
              onTap: () {
                Navigator.pop(context);
                _showAssignDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Mark as Cleared'),
              onTap: () {
                Navigator.pop(context);
                _markAsCleared(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement staff selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Staff assignment coming soon')),
    );
  }

  Future<void> _markAsCleared(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Cleared'),
        content: const Text('Are you sure this cheque has no issues?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final service = ref.read(chequeServiceProvider);
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await ref.read(currentUserDataProvider.future);

      await service.updateChequeStatus(
        districtId: districtId,
        periodId: folder.periodId,
        folderId: folder.id,
        chequeId: cheque.id,
        status: 'Cleared',
        userId: user.uid,
        userName: userData!['name'] ?? 'Unknown',
        userRole: userData['role'] ?? 'Unknown',
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cheque marked as cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _IssueCard extends ConsumerWidget {
  final Issue issue;
  final Cheque cheque;
  final String districtId;
  final Folder folder;
  final bool canResolve;

  const _IssueCard({
    required this.issue,
    required this.cheque,
    required this.districtId,
    required this.folder,
    required this.canResolve,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isResolved = issue.status == 'Resolved';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isResolved ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isResolved ? Icons.check_circle : Icons.warning_amber,
                  color: isResolved ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getIssueTypeText(issue.type),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isResolved ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    issue.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(issue.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Text(
              'Created ${DateFormat('MMM d, y').format(issue.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (isResolved && issue.resolvedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Resolved ${DateFormat('MMM d, y').format(issue.resolvedAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.green[700]),
              ),
              if (issue.resolutionNotes != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resolution Notes:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.resolutionNotes!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            if (!isResolved && canResolve) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showResolveDialog(context, ref),
                  icon: const Icon(Icons.check),
                  label: const Text('Resolve Issue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getIssueTypeText(IssueType type) {
    switch (type) {
      case IssueType.missingReceipt:
        return 'Missing Receipt';
      case IssueType.wrongCoding:
        return 'Wrong Coding';
      case IssueType.overExpenditure:
        return 'Over Expenditure';
      case IssueType.improperSupport:
        return 'Improper Support';
      case IssueType.other:
        return 'Other Issue';
    }
  }

  void _showResolveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ResolveIssueDialog(
        districtId: districtId,
        periodId: folder.periodId,
        folderId: folder.id,
        chequeId: cheque.id,
        issue: issue,
      ),
    );
  }
}
