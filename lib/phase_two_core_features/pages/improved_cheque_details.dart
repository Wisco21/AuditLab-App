// File: cheque_details_screen.dart

import 'package:auditlab/phase_one_auth/models/models_sector.dart';
import 'package:auditlab/phase_two_core_features/widgets/assign_cheque_sheet.dart';
import 'package:auditlab/models/cheque.dart';
import 'package:auditlab/models/folder.dart';
import 'package:auditlab/models/issue.dart';
import 'package:auditlab/phase_two_core_features/widgets/cheque_bottom_sheets.dart';
import 'package:auditlab/phase_two_core_features/widgets/resolve_issue_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    // Watch the cheque to get real-time updates
    final chequeStream = FirebaseFirestore.instance
        .collection('districts')
        .doc(districtId)
        .collection('periods')
        .doc(folder.periodId)
        .collection('folders')
        .doc(folder.id)
        .collection('cheques')
        .doc(cheque.id)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: chequeStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cheque Not Found')),
            body: const Center(child: Text('Cheque not found')),
          );
        }

        final currentCheque = Cheque.fromJson(
          snapshot.data!.data() as Map<String, dynamic>,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('Cheque #${currentCheque.chequeNumber}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Cheque',
                onPressed: () =>
                    _showEditChequeBottomSheet(context, currentCheque),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsMenu(context, ref, currentCheque),
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(currentCheque.status),
                        _getStatusColor(currentCheque.status).withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStatusIcon(currentCheque.status),
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentCheque.status,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cheque Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        context,
                        icon: Icons.receipt,
                        label: 'Cheque Number',
                        value: currentCheque.chequeNumber,
                      ),

                      if (currentCheque.payee != null)
                        _buildInfoCard(
                          context,
                          icon: Icons.person_outline,
                          label: 'Payee',
                          value: currentCheque.payee!,
                        ),

                      if (currentCheque.amount != null)
                        _buildInfoCard(
                          context,
                          icon: Icons.attach_money,
                          label: 'Amount',
                          value:
                              'MK ${currentCheque.amount!.toStringAsFixed(2)}',
                        ),

                      _buildInfoCard(
                        context,
                        icon: Icons.business,
                        label: 'Sector',
                        value: _getSectorName(currentCheque.sectorCode),
                      ),

                      if (currentCheque.description != null)
                        _buildInfoCard(
                          context,
                          icon: Icons.notes,
                          label: 'Description',
                          value: currentCheque.description!,
                        ),

                      if (currentCheque.assignedTo != null)
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentCheque.assignedTo)
                              .get(),
                          builder: (context, userSnapshot) {
                            final assignedName =
                                userSnapshot.data?.data() != null
                                ? (userSnapshot.data!.data()
                                      as Map<String, dynamic>)['name']
                                : 'Loading...';
                            return _buildInfoCard(
                              context,
                              icon: Icons.person,
                              label: 'Assigned To',
                              value: assignedName ?? 'Unknown',
                            );
                          },
                        ),

                      _buildInfoCard(
                        context,
                        icon: Icons.calendar_today,
                        label: 'Created',
                        value: DateFormat(
                          'MMM d, y • h:mm a',
                        ).format(currentCheque.createdAt),
                      ),

                      _buildInfoCard(
                        context,
                        icon: Icons.update,
                        label: 'Last Updated',
                        value: DateFormat(
                          'MMM d, y • h:mm a',
                        ).format(currentCheque.updatedAt),
                      ),

                      const SizedBox(height: 32),

                      // Issues Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Issues',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddIssueBottomSheet(
                              context,
                              currentCheque,
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Issue'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (currentCheque.issues.isEmpty)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: Colors.green[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No issues found',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
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
                        ...currentCheque.issues.map(
                          (issue) => _IssueCard(
                            issue: issue,
                            cheque: currentCheque,
                            districtId: districtId,
                            folder: folder,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
      case 'Missing':
        return Colors.grey;
      case 'Canceled':
        return Colors.orange;
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
      case 'Missing':
        return Icons.help_outline;
      case 'Canceled':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  void _showEditChequeBottomSheet(BuildContext context, Cheque cheque) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateChequeBottomSheet(
        districtId: districtId,
        periodId: folder.periodId,
        folderId: folder.id,
        cheque: cheque,
      ),
    );
  }

  void _showAddIssueBottomSheet(BuildContext context, Cheque cheque) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddIssueBottomSheet(
        districtId: districtId,
        periodId: folder.periodId,
        folderId: folder.id,
        chequeId: cheque.id,
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref, Cheque cheque) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Cheque Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.blue),
              title: const Text('Manage Assignment'),
              subtitle: const Text('Assign staff or mark status'),
              onTap: () {
                Navigator.pop(context);
                _showAssignDialog(context, cheque);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
              title: const Text('Mark as Cleared'),
              subtitle: const Text('No issues found'),
              onTap: () {
                Navigator.pop(context);
                _markAsCleared(context, ref, cheque);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, Cheque cheque) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AssignChequeBottomSheet(
        districtId: districtId,
        periodId: folder.periodId,
        folderId: folder.id,
        cheque: cheque,
      ),
    );
  }

  Future<void> _markAsCleared(
    BuildContext context,
    WidgetRef ref,
    Cheque cheque,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Cleared'),
        content: const Text(
          'Are you sure this cheque has no issues and should be marked as cleared?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Mark Cleared'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser!;

      await FirebaseFirestore.instance
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(folder.periodId)
          .collection('folders')
          .doc(folder.id)
          .collection('cheques')
          .doc(cheque.id)
          .update({
            'status': 'Cleared',
            'lastUpdatedBy': user.uid,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (context.mounted) {
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

  const _IssueCard({
    required this.issue,
    required this.cheque,
    required this.districtId,
    required this.folder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isResolved = issue.status == 'Resolved';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isResolved ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isResolved ? Colors.green : Colors.red).withOpacity(
                      0.15,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isResolved ? Icons.check_circle : Icons.warning_amber,
                    color: isResolved ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getIssueTypeText(issue.type),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (issue.type == IssueType.missingSignatories &&
                          issue.missingSignatories.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: issue.missingSignatories
                              .map(
                                (s) => Chip(
                                  label: Text(
                                    _getSignatoryName(s),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isResolved ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    issue.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(issue.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Created ${DateFormat('MMM d, y').format(issue.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (isResolved && issue.resolvedAt != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Resolved ${DateFormat('MMM d, y').format(issue.resolvedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (issue.resolutionNotes != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        issue.resolutionNotes!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (!isResolved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showResolveDialog(context, ref),
                  icon: const Icon(Icons.check, size: 18),
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
      case IssueType.improperSupport:
        return 'Improper Support';
      case IssueType.missingReceipt:
        return 'Missing Receipt';
      case IssueType.other:
        return 'Other Issue';
    }
  }

  String _getSignatoryName(SignatoryType type) {
    switch (type) {
      case SignatoryType.dc:
        return 'DC';
      case SignatoryType.dof:
        return 'DOF';
      case SignatoryType.sectorHead:
        return 'Sector Head';
      case SignatoryType.accountant:
        return 'Accountant';
      case SignatoryType.compiler:
        return 'Compiler';
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
