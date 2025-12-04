// lib/screens/audit/folder_details_screen.dart
import 'package:auditlab/phase2/models/cheque.dart';
import 'package:auditlab/phase2/models/folder.dart';
import 'package:auditlab/phase2/pages/cheque_screen.dart';
import 'package:auditlab/phase2/phase2_cheque_dialogs.dart';
import 'package:auditlab/phase2/provider/cheque_provider.dart';
import 'package:auditlab/phase2/provider/user_provider.dart';
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
    final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;
    final chequesAsync = ref.watch(
      chequesProvider((
        districtId: districtId,
        periodId: folder.periodId,
        folderId: folder.id,
      )),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Folder ${folder.folderNumber}')),
      body: Column(
        children: [
          // Folder Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cheque Range: ${folder.chequeRangeStart} - ${folder.chequeRangeEnd}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${folder.status}',
                  style: TextStyle(
                    color: _getStatusColor(folder.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: folder.totalCheques > 0
                      ? folder.completedCheques / folder.totalCheques
                      : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(
                    _getStatusColor(folder.status),
                  ),
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
                          Icon(
                            Icons.receipt_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text('No cheques yet'),
                          if (isSupervisor) ...[
                            const SizedBox(height: 8),
                            const Text('Tap + to add cheques'),
                          ],
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
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isSupervisor
          ? FloatingActionButton(
              onPressed: () => _showCreateChequeDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreateChequeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateChequeDialog(
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(cheque.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(cheque.status),
                  color: _getStatusColor(cheque.status),
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
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                    if (cheque.issues.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${cheque.issues.length} issue(s)',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor()),
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
      default:
        return Colors.blue;
    }
  }
}
