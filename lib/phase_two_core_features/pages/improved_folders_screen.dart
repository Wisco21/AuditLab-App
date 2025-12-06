import 'package:auditlab/phase_two_core_features/fix_provider_scope.dart';
import 'package:auditlab/models/folder.dart';
import 'package:auditlab/models/period.dart';
import 'package:auditlab/phase_two_core_features/cheques_screens.dart';
import 'package:auditlab/phase_two_core_features/provider/folder_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:auditlab/phase_two_core_features/core_services/cheque_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoldersScreen extends ConsumerWidget {
  final String districtId;
  final Period period;

  const FoldersScreen({
    super.key,
    required this.districtId,
    required this.period,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final currentUser = ref.watch(currentUserDataProvider);
    final foldersAsync = ref.watch(
      foldersProvider((districtId: districtId, periodId: period.id)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${period.year} - ${period.range}'),
            Text(
              'Folders',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            foldersProvider((districtId: districtId, periodId: period.id)),
          );
        },
        child: foldersAsync.when(
          data: (folders) {
            if (folders.isEmpty) {
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
                        Icons.folder_open_outlined,
                        size: 80,
                        color: Colors.blue[300],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No folders yet',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        userRole.value == 'DOF' ||
                                userRole.value == 'CA' ||
                                (currentUser.value?['uid'] ==
                                    period.supervisorId)
                            ? 'Get started by creating your first folder to organize cheques for this period'
                            : 'Folders will appear here once the supervisor creates them',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (userRole.value == 'DOF' ||
                        userRole.value == 'CA' ||
                        (currentUser.value?['uid'] == period.supervisorId))
                      ElevatedButton.icon(
                        onPressed: () => _showCreateFolderBottomSheet(
                          context,
                          ref,
                          folders.length + 1,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Folder'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return _FolderCard(
                  folder: folder,
                  districtId: districtId,
                  period: period,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(
                    foldersProvider((
                      districtId: districtId,
                      periodId: period.id,
                    )),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: userRole.when(
        data: (role) {
          final userId = currentUser.value?['uid'];
          // Only DOF, CA, or the period's supervisor can create folders
          if (role == 'DOF' || role == 'CA' || userId == period.supervisorId) {
            return foldersAsync.when(
              data: (folders) => FloatingActionButton.extended(
                onPressed: () => _showCreateFolderBottomSheet(
                  context,
                  ref,
                  folders.length + 1,
                ),
                icon: const Icon(Icons.add),
                label: const Text('New Folder'),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          }
          return const SizedBox.shrink();
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  void _showCreateFolderBottomSheet(
    BuildContext context,
    WidgetRef ref,
    int nextFolderNumber,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateFolderBottomSheet(
        districtId: districtId,
        periodId: period.id,
        nextFolderNumber: nextFolderNumber,
      ),
    );
  }
}

class _FolderCard extends ConsumerWidget {
  final Folder folder;
  final String districtId;
  final Period period;

  const _FolderCard({
    required this.folder,
    required this.districtId,
    required this.period,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = folder.totalCheques > 0
        ? folder.completedCheques / folder.totalCheques
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          ref.read(selectedFolderProvider.notifier).state = folder;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  FolderDetailsScreen(districtId: districtId, folder: folder),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(folder.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder,
                      color: _getStatusColor(folder.status),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Folder ${folder.folderNumber}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cheques: ${folder.chequeRangeStart} - ${folder.chequeRangeEnd}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.grey[600]),
                    onPressed: () => _showFolderInfoDialog(context, ref),
                    tooltip: 'Folder Details',
                  ),
                  _StatusChip(status: folder.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${folder.completedCheques}/${folder.totalCheques} Cheques',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${(progress * 100).toInt()}%)',
                              style: TextStyle(
                                color: _getStatusColor(folder.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
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
      ),
    );
  }

  void _showFolderInfoDialog(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.read(firestoreServiceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.folder, color: _getStatusColor(folder.status)),
            const SizedBox(width: 12),
            Text('Folder ${folder.folderNumber}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                icon: Icons.numbers,
                label: 'Folder Number',
                value: folder.folderNumber,
              ),
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.receipt_long,
                label: 'Cheque Range',
                value: '${folder.chequeRangeStart} - ${folder.chequeRangeEnd}',
              ),
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.check_circle_outline,
                label: 'Progress',
                value:
                    '${folder.completedCheques}/${folder.totalCheques} cheques',
              ),
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.flag,
                label: 'Status',
                value: folder.status,
                valueColor: _getStatusColor(folder.status),
              ),
              const Divider(height: 24),
              FutureBuilder<Map<String, dynamic>?>(
                future: firestoreService.getUserProfile(folder.createdBy),
                builder: (context, snapshot) {
                  return _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Created By',
                    value: snapshot.data?['name'] ?? 'Loading...',
                  );
                },
              ),
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.access_time,
                label: 'Created',
                value: _formatDate(folder.createdAt),
              ),
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.update,
                label: 'Last Updated',
                value: _formatDate(folder.updatedAt),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getColor() {
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

class CreateFolderBottomSheet extends ConsumerStatefulWidget {
  final String districtId;
  final String periodId;
  final int nextFolderNumber;

  const CreateFolderBottomSheet({
    super.key,
    required this.districtId,
    required this.periodId,
    required this.nextFolderNumber,
  });

  @override
  ConsumerState<CreateFolderBottomSheet> createState() =>
      _CreateFolderBottomSheetState();
}

class _CreateFolderBottomSheetState
    extends ConsumerState<CreateFolderBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  int _startCheque = 000000;
  int _endCheque = 000099;
  bool _isLoading = false;
  bool _createWithDummyCheques = false;

  @override
  void initState() {
    super.initState();
    // Set default cheque range based on folder number
    _startCheque = 000000 + (widget.nextFolderNumber - 1) * 100;
    _endCheque = _startCheque + 99;
  }

  void _incrementStart() {
    setState(() {
      _startCheque++;
      if (_startCheque > _endCheque) {
        _endCheque = _startCheque;
      }
    });
  }

  void _decrementStart() {
    if (_startCheque > 000000) {
      setState(() {
        _startCheque--;
      });
    }
  }

  void _incrementEnd() {
    setState(() {
      _endCheque++;
    });
  }

  void _decrementEnd() {
    if (_endCheque > _startCheque) {
      setState(() {
        _endCheque--;
      });
    }
  }

  int get _totalCheques => _endCheque - _startCheque + 1;

  Future<void> _createFolder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startCheque >= _endCheque) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start cheque must be less than end cheque'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final folderService = ref.read(folderServiceProvider);
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await ref.read(currentUserDataProvider.future);

      // Create folder
      final folderId = await folderService.createFolder(
        districtId: widget.districtId,
        periodId: widget.periodId,
        folderNumber: widget.nextFolderNumber.toString().padLeft(3, '0'),
        chequeRangeStart: _startCheque.toString().padLeft(6, '0'),
        chequeRangeEnd: _endCheque.toString().padLeft(6, '0'),
        createdBy: user.uid,
        userName: userData?['name'] ?? 'Unknown',
        userRole: userData?['role'] ?? 'Unknown',
      );

      // Create dummy cheques if requested
      if (_createWithDummyCheques) {
        final chequeService = ChequeService();
        for (int i = _startCheque; i <= _endCheque; i++) {
          await chequeService.createCheque(
            districtId: widget.districtId,
            periodId: widget.periodId,
            folderId: folderId,
            chequeNumber: i.toString().padLeft(6, '0'),
            sectorCode: '000', // Default sector
            createdBy: user.uid,
            userName: userData?['name'] ?? 'Unknown',
            userRole: userData?['role'] ?? 'Unknown',
            payee: 'Pending Assignment',
            description: 'Dummy cheque - awaiting data entry',
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _createWithDummyCheques
                  ? 'Folder created with ${_totalCheques} dummy cheques'
                  : 'Folder created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Handle bar
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Folder',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Folder number (automatic)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.folder,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Folder Number',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.nextFolderNumber.toString().padLeft(
                                      3,
                                      '0',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Auto-assigned',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Cheque Range Section
                        Text(
                          'Cheque Range',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Start Cheque
                        Text(
                          'Start Cheque Number',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _decrementStart,
                                icon: const Icon(Icons.remove),
                                color: Colors.red,
                              ),
                              Expanded(
                                child: Text(
                                  _startCheque.toString().padLeft(6, '0'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _incrementStart,
                                icon: const Icon(Icons.add),
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // End Cheque
                        Text(
                          'End Cheque Number',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _decrementEnd,
                                icon: const Icon(Icons.remove),
                                color: Colors.red,
                              ),
                              Expanded(
                                child: Text(
                                  _endCheque.toString().padLeft(6, '0'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _incrementEnd,
                                icon: const Icon(Icons.add),
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Total cheques indicator
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.receipt_long, color: Colors.grey[600]),
                              const SizedBox(width: 12),
                              Text(
                                'Total Cheques: ',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _totalCheques.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Create with dummy cheques option
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange[200]!),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.orange.withOpacity(0.05),
                          ),
                          child: CheckboxListTile(
                            title: const Text(
                              'Create with dummy cheques',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Pre-populate folder with $_totalCheques placeholder cheques that can be updated later',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            value: _createWithDummyCheques,
                            onChanged: (value) => setState(
                              () => _createWithDummyCheques = value!,
                            ),
                            secondary: Icon(
                              Icons.auto_awesome,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Create button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createFolder,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_circle_outline),
                                      const SizedBox(width: 8),
                                      Text(
                                        _createWithDummyCheques
                                            ? 'Create Folder with Cheques'
                                            : 'Create Empty Folder',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
