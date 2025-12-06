// File: assign_cheque_bottom_sheet.dart

import 'package:auditlab/models/cheque.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignChequeBottomSheet extends ConsumerStatefulWidget {
  final String districtId;
  final String periodId;
  final String folderId;
  final Cheque cheque;

  const AssignChequeBottomSheet({
    super.key,
    required this.districtId,
    required this.periodId,
    required this.folderId,
    required this.cheque,
  });

  @override
  ConsumerState<AssignChequeBottomSheet> createState() =>
      _AssignChequeBottomSheetState();
}

class _AssignChequeBottomSheetState
    extends ConsumerState<AssignChequeBottomSheet> {
  String? _selectedStaffId;
  bool _isLoading = false;
  String _selectedAction = 'assign'; // assign, missing, canceled

  Future<void> _performAction() async {
    if (_selectedAction == 'assign' && _selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a staff member')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await ref.read(currentUserDataProvider.future);

      final chequeRef = FirebaseFirestore.instance
          .collection('districts')
          .doc(widget.districtId)
          .collection('periods')
          .doc(widget.periodId)
          .collection('folders')
          .doc(widget.folderId)
          .collection('cheques')
          .doc(widget.cheque.id);

      if (_selectedAction == 'assign') {
        // Assign to staff
        await chequeRef.update({
          'assignedTo': _selectedStaffId,
          'lastUpdatedBy': user.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cheque assigned successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (_selectedAction == 'missing') {
        // Mark as missing
        await chequeRef.update({
          'status': 'Missing',
          'lastUpdatedBy': user.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cheque marked as missing'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      } else if (_selectedAction == 'canceled') {
        // Mark as canceled
        await chequeRef.update({
          'status': 'Canceled',
          'lastUpdatedBy': user.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cheque marked as canceled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
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
    final districtIdAsync = ref.watch(userDistrictIdProvider);

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
                      'Manage Cheque',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cheque Info
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
                            const Icon(
                              Icons.receipt,
                              color: Colors.blue,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cheque #${widget.cheque.chequeNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (widget.cheque.payee != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.cheque.payee!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Selection
                      Text(
                        'Select Action',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Assign to Staff Option
                      _ActionCard(
                        icon: Icons.person_add,
                        title: 'Assign to Staff',
                        description:
                            'Assign this cheque to a staff member for review',
                        color: Colors.blue,
                        isSelected: _selectedAction == 'assign',
                        onTap: () => setState(() => _selectedAction = 'assign'),
                      ),

                      // Mark as Missing Option
                      _ActionCard(
                        icon: Icons.help_outline,
                        title: 'Mark as Missing',
                        description: 'This cheque cannot be found in records',
                        color: Colors.grey,
                        isSelected: _selectedAction == 'missing',
                        onTap: () =>
                            setState(() => _selectedAction = 'missing'),
                      ),

                      // Mark as Canceled Option
                      _ActionCard(
                        icon: Icons.cancel,
                        title: 'Mark as Canceled',
                        description: 'This cheque has been voided or canceled',
                        color: Colors.orange,
                        isSelected: _selectedAction == 'canceled',
                        onTap: () =>
                            setState(() => _selectedAction = 'canceled'),
                      ),

                      // Staff Selection (only show when assign is selected)
                      if (_selectedAction == 'assign') ...[
                        const SizedBox(height: 24),
                        Text(
                          'Select Staff Member',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        districtIdAsync.when(
                          data: (districtId) {
                            if (districtId == null) {
                              return const Text('No district assigned');
                            }

                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('districtId', isEqualTo: districtId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Text(
                                    'No staff members available',
                                  );
                                }

                                final staff = snapshot.data!.docs;

                                return Column(
                                  children: staff.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final staffId = doc.id;
                                    final name = data['name'] ?? 'Unknown';
                                    final role = data['role'] ?? 'Unknown';

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      color: _selectedStaffId == staffId
                                          ? Colors.blue.withOpacity(0.1)
                                          : null,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: _selectedStaffId == staffId
                                              ? Colors.blue
                                              : Colors.grey.shade300,
                                          width: _selectedStaffId == staffId
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () => setState(
                                          () => _selectedStaffId = staffId,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.blue,
                                                child: Text(
                                                  name[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            _selectedStaffId ==
                                                                staffId
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                    Text(
                                                      role,
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (_selectedStaffId == staffId)
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => Text('Error: $error'),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Action button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _performAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getActionColor(),
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
                              : Text(
                                  _getActionButtonText(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getActionColor() {
    switch (_selectedAction) {
      case 'assign':
        return Colors.blue;
      case 'missing':
        return Colors.grey;
      case 'canceled':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getActionButtonText() {
    switch (_selectedAction) {
      case 'assign':
        return 'Assign Cheque';
      case 'missing':
        return 'Mark as Missing';
      case 'canceled':
        return 'Mark as Canceled';
      default:
        return 'Confirm';
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? color.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.grey.shade300,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 16,
                        color: isSelected ? color : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
