// =============================================================================
// PART 2: Improved Folder Details Screen
// File: folder_details_screen.dart

import 'package:auditlab/models/cheque.dart';
import 'package:auditlab/models/folder.dart';
import 'package:auditlab/phase_two_core_features/pages/improved_cheque_details.dart';
import 'package:auditlab/phase_two_core_features/provider/cheque_provider.dart';
import 'package:auditlab/phase_two_core_features/widgets/cheque_bottom_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FolderDetailsScreen extends ConsumerWidget {
  final String districtId;
  final Folder folder;

  const FolderDetailsScreen({
    super.key,
    required this.districtId,
    required this.folder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chequesAsync = ref.watch(
      chequesProvider((
        districtId: districtId,
        periodId: folder.periodId,
        folderId: folder.id,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Folder ${folder.folderNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Cheque',
            onPressed: () => _showCreateChequeBottomSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Folder Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(folder.status).withOpacity(0.1),
                  _getStatusColor(folder.status).withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_open,
                      color: _getStatusColor(folder.status),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cheque Range: ${folder.chequeRangeStart} - ${folder.chequeRangeEnd}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status: ${folder.status}',
                            style: TextStyle(
                              color: _getStatusColor(folder.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${folder.completedCheques}/${folder.totalCheques} Cheques Completed',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: folder.totalCheques > 0
                                  ? folder.completedCheques /
                                        folder.totalCheques
                                  : 0.0,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation(
                                _getStatusColor(folder.status),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Cheques List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  chequesProvider((
                    districtId: districtId,
                    periodId: folder.periodId,
                    folderId: folder.id,
                  )),
                );
              },
              child: chequesAsync.when(
                data: (cheques) {
                  if (cheques.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.blue[300],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No cheques yet',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add cheques to this folder to start auditing',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showCreateChequeBottomSheet(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Cheque'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cheques.length,
                    itemBuilder: (context, index) {
                      final cheque = cheques[index];
                      return _ChequeCard(
                        cheque: cheque,
                        districtId: districtId,
                        folder: folder,
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
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(
                          chequesProvider((
                            districtId: districtId,
                            periodId: folder.periodId,
                            folderId: folder.id,
                          )),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateChequeBottomSheet(BuildContext context, WidgetRef ref) {
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
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class _ChequeCard extends ConsumerWidget {
  final Cheque cheque;
  final String districtId;
  final Folder folder;

  const _ChequeCard({
    required this.cheque,
    required this.districtId,
    required this.folder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChequeDetailsScreen(
                districtId: districtId,
                folder: folder,
                cheque: cheque,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(cheque.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(cheque.status),
                  color: _getStatusColor(cheque.status),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cheque #${cheque.chequeNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (cheque.payee != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        cheque.payee!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (cheque.issues.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${cheque.issues.length} issue(s)',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusChip(status: cheque.status),
                  if (cheque.amount != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'MK ${cheque.amount!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor(), width: 1.5),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getColor(),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getColor() {
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
}
