import 'package:auditlab/models/cheque.dart';
import 'package:auditlab/models/folder.dart';
import 'package:auditlab/models/period.dart';
import 'package:auditlab/phase_two_core_features/pages/improved_cheque_details.dart';
import 'package:auditlab/phase_two_core_features/pages/improved_folders_screen.dart';
import 'package:auditlab/phase_two_core_features/provider/cheque_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyAssignmentsScreen extends ConsumerStatefulWidget {
  const MyAssignmentsScreen({super.key});

  @override
  ConsumerState<MyAssignmentsScreen> createState() =>
      _MyAssignmentsScreenState();
}

class _MyAssignmentsScreenState extends ConsumerState<MyAssignmentsScreen> {
  String _filterStatus = 'all'; // all, pending, has_issues, cleared

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final districtIdAsync = ref.watch(userDistrictIdProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assignments'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: districtIdAsync.when(
        data: (districtId) {
          if (districtId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No district assigned'),
                ],
              ),
            );
          }

          final chequesAsync = ref.watch(
            userChequesProvider((districtId: districtId, userId: user.uid)),
          );

          return Column(
            children: [
              // Stats Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: chequesAsync.when(
                  data: (cheques) => _buildStatsHeader(context, cheques),
                  loading: () => const SizedBox(height: 80),
                  error: (_, __) => const SizedBox(height: 80),
                ),
              ),

              // Active Filter Indicator
              if (_filterStatus != 'all')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Chip(
                        label: Text('Filter: ${_getFilterLabel()}'),
                        onDeleted: () => setState(() => _filterStatus = 'all'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ),

              // Assignments List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      userChequesProvider((
                        districtId: districtId,
                        userId: user.uid,
                      )),
                    );
                  },
                  child: chequesAsync.when(
                    data: (cheques) {
                      // Apply filter
                      final filteredCheques = _filterCheques(cheques);

                      if (filteredCheques.isEmpty) {
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
                                  Icons.assignment_outlined,
                                  size: 80,
                                  color: Colors.blue[300],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _filterStatus == 'all'
                                    ? 'No assignments yet'
                                    : 'No ${_getFilterLabel().toLowerCase()} assignments',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                ),
                                child: Text(
                                  _filterStatus == 'all'
                                      ? 'Cheques assigned to you will appear here'
                                      : 'Try changing the filter to see other assignments',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredCheques.length,
                        itemBuilder: (context, index) {
                          final cheque = filteredCheques[index];
                          return _AssignmentCard(
                            cheque: cheque,
                            districtId: districtId,
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
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
                              userChequesProvider((
                                districtId: districtId,
                                userId: user.uid,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, List<Cheque> cheques) {
    final totalCount = cheques.length;
    final pendingCount = cheques.where((c) => c.status == 'Pending').length;
    final issuesCount = cheques.where((c) => c.status == 'Has Issues').length;
    final clearedCount = cheques.where((c) => c.status == 'Cleared').length;

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.assignment, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              'Your Assignments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatCard(
              label: 'Total',
              count: totalCount,
              color: Colors.white,
              icon: Icons.receipt_long,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Pending',
              count: pendingCount,
              color: Colors.blue[100]!,
              icon: Icons.pending,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Issues',
              count: issuesCount,
              color: Colors.red[100]!,
              icon: Icons.warning,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Cleared',
              count: clearedCount,
              color: Colors.green[100]!,
              icon: Icons.check_circle,
            ),
          ],
        ),
      ],
    );
  }

  List<Cheque> _filterCheques(List<Cheque> cheques) {
    switch (_filterStatus) {
      case 'pending':
        return cheques.where((c) => c.status == 'Pending').toList();
      case 'has_issues':
        return cheques.where((c) => c.status == 'Has Issues').toList();
      case 'cleared':
        return cheques.where((c) => c.status == 'Cleared').toList();
      default:
        return cheques;
    }
  }

  String _getFilterLabel() {
    switch (_filterStatus) {
      case 'pending':
        return 'Pending';
      case 'has_issues':
        return 'Has Issues';
      case 'cleared':
        return 'Cleared';
      default:
        return 'All';
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Assignments',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _FilterOption(
              label: 'All Assignments',
              icon: Icons.list,
              isSelected: _filterStatus == 'all',
              onTap: () {
                setState(() => _filterStatus = 'all');
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              label: 'Pending Only',
              icon: Icons.pending,
              isSelected: _filterStatus == 'pending',
              onTap: () {
                setState(() => _filterStatus = 'pending');
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              label: 'Has Issues',
              icon: Icons.warning,
              isSelected: _filterStatus == 'has_issues',
              onTap: () {
                setState(() => _filterStatus = 'has_issues');
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              label: 'Cleared',
              icon: Icons.check_circle,
              isSelected: _filterStatus == 'cleared',
              onTap: () {
                setState(() => _filterStatus = 'cleared');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Colors.blue.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.blue : Colors.grey[600]),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.blue : null,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentCard extends ConsumerWidget {
  final Cheque cheque;
  final String districtId;

  const _AssignmentCard({required this.cheque, required this.districtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasIssues = cheque.issues.isNotEmpty;
    final openIssues = cheque.issues.where((i) => i.status == 'Open').length;
    final resolvedIssues = cheque.issues
        .where((i) => i.status == 'Resolved')
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => NavigationHelper.navigateToChequeFromAssignment(
          context: context,
          districtId: districtId,
          cheque: cheque,
        ),
        // onTap: () => _navigateToChequeDetails(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(cheque.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(cheque.status),
                  color: _getStatusColor(cheque.status),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Cheque Info
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, y').format(cheque.updatedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (hasIssues) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (openIssues > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    size: 12,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$openIssues open',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (resolvedIssues > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$resolvedIssues resolved',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status Chip & Amount
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

  // Update the _navigateToChequeDetails method in _AssignmentCard:

  Future<void> _navigateToChequeDetails(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Fetch the folder information from Firestore
      final folderDoc = await FirebaseFirestore.instance
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(cheque.periodId)
          .collection('folders')
          .doc(cheque.folderId)
          .get();

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (!folderDoc.exists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Folder not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final folder = Folder.fromJson(folderDoc.data()!);

      if (context.mounted) {
        // OPTION 1: Direct navigation (simple)
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

        // OPTION 2: Named route navigation (if you prefer named routes)
        /*
      Navigator.pushNamed(
        context,
        AppRouter.chequeDetails,
        arguments: ChequeDetailsArgs(
          districtId: districtId,
          folder: folder,
          cheque: cheque,
        ),
      );
      */
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading details: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _navigateToChequeDetails(context, ref),
            ),
          ),
        );
      }
    }
  }

  // Future<void> _navigateToChequeDetails(
  //   BuildContext context,
  //   WidgetRef ref,
  // ) async {
  //   try {
  //     // Fetch the folder information from Firestore
  //     final folderDoc = await FirebaseFirestore.instance
  //         .collection('districts')
  //         .doc(districtId)
  //         .collection('periods')
  //         .doc(cheque.periodId)
  //         .collection('folders')
  //         .doc(cheque.folderId)
  //         .get();

  //     if (!folderDoc.exists) {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Folder not found'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //       return;
  //     }

  //     final folder = Folder.fromJson(folderDoc.data()!);

  //     if (context.mounted) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => ChequeDetailsScreen(
  //             districtId: districtId,
  //             folder: folder,
  //             cheque: cheque,
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
  //       );
  //     }
  //   }
  // }

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

class NavigationHelper {
  /// Navigate to cheque details from assignment
  static Future<void> navigateToChequeFromAssignment({
    required BuildContext context,
    required String districtId,
    required Cheque cheque,
  }) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading cheque details...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Fetch folder data
      final folderDoc = await FirebaseFirestore.instance
          .collection('districts')
          .doc(districtId)
          .collection('periods')
          .doc(cheque.periodId)
          .collection('folders')
          .doc(cheque.folderId)
          .get();

      if (!context.mounted) return;

      // Close loading
      Navigator.pop(context);

      if (!folderDoc.exists) {
        _showError(context, 'Folder not found');
        return;
      }

      final folder = Folder.fromJson(folderDoc.data()!);

      // Navigate to cheque details
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
    } catch (e) {
      if (!context.mounted) return;

      // Close loading if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _showError(context, 'Error: $e');
    }
  }

  /// Navigate to folder details
  static void navigateToFolder({
    required BuildContext context,
    required String districtId,
    required Folder folder,
    required Period period,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoldersScreen(districtId: districtId, period: period),
      ),
    );
  }

  /// Navigate to period details
  static void navigateToPeriod({
    required BuildContext context,
    required String districtId,
    required Period period,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoldersScreen(districtId: districtId, period: period),
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
