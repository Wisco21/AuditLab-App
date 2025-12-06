// File: cheque_bottom_sheets.dart

import 'package:auditlab/phase_one_auth/models/models_sector.dart';
import 'package:auditlab/models/cheque.dart';
import 'package:auditlab/models/issue.dart';
import 'package:auditlab/phase_two_core_features/provider/cheque_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:auditlab/phase_two_core_features/core_services/cheque_service.dart';
import 'package:auditlab/phase_two_core_features/core_services/issue_service.dart';
import 'package:auditlab/phase_one_auth/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// CREATE/EDIT CHEQUE BOTTOM SHEET
// =============================================================================

class CreateChequeBottomSheet extends ConsumerStatefulWidget {
  final String districtId;
  final String periodId;
  final String folderId;
  final Cheque? cheque; // null for create, provided for edit

  const CreateChequeBottomSheet({
    super.key,
    required this.districtId,
    required this.periodId,
    required this.folderId,
    this.cheque,
  });

  @override
  ConsumerState<CreateChequeBottomSheet> createState() =>
      _CreateChequeBottomSheetState();
}

class _CreateChequeBottomSheetState
    extends ConsumerState<CreateChequeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _chequeNumberController;
  late final TextEditingController _payeeController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  String? _selectedSectorCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chequeNumberController = TextEditingController(
      text: widget.cheque?.chequeNumber ?? '',
    );
    _payeeController = TextEditingController(text: widget.cheque?.payee ?? '');
    _amountController = TextEditingController(
      text: widget.cheque?.amount?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.cheque?.description ?? '',
    );
    _selectedSectorCode = widget.cheque?.sectorCode;
  }

  @override
  void dispose() {
    _chequeNumberController.dispose();
    _payeeController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.cheque != null;

  Future<void> _saveCheque() async {
    if (!_formKey.currentState!.validate() || _selectedSectorCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(chequeServiceProvider);
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await ref.read(currentUserDataProvider.future);

      if (_isEditing) {
        // Update existing cheque
        await FirebaseFirestore.instance
            .collection('districts')
            .doc(widget.districtId)
            .collection('periods')
            .doc(widget.periodId)
            .collection('folders')
            .doc(widget.folderId)
            .collection('cheques')
            .doc(widget.cheque!.id)
            .update({
              'chequeNumber': _chequeNumberController.text.trim(),
              'sectorCode': _selectedSectorCode!,
              'payee': _payeeController.text.trim().isNotEmpty
                  ? _payeeController.text.trim()
                  : null,
              'amount': _amountController.text.trim().isNotEmpty
                  ? double.tryParse(_amountController.text.trim())
                  : null,
              'description': _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
              'lastUpdatedBy': user.uid,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cheque updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new cheque
        await service.createCheque(
          districtId: widget.districtId,
          periodId: widget.periodId,
          folderId: widget.folderId,
          chequeNumber: _chequeNumberController.text.trim(),
          sectorCode: _selectedSectorCode!,
          createdBy: user.uid,
          userName: userData?['name'] ?? 'Unknown',
          userRole: userData?['role'] ?? 'Unknown',
          payee: _payeeController.text.trim().isNotEmpty
              ? _payeeController.text.trim()
              : null,
          amount: _amountController.text.trim().isNotEmpty
              ? double.tryParse(_amountController.text.trim())
              : null,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cheque created successfully'),
              backgroundColor: Colors.green,
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
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                      _isEditing ? 'Edit Cheque' : 'Add New Cheque',
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
                        // Cheque Number
                        TextFormField(
                          controller: _chequeNumberController,
                          decoration: InputDecoration(
                            labelText: 'Cheque Number *',
                            prefixIcon: const Icon(Icons.receipt),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter cheque number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Sector Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedSectorCode,
                          decoration: InputDecoration(
                            labelText: 'Sector *',
                            prefixIcon: const Icon(Icons.business),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: Sector.allSectors.map((sector) {
                            return DropdownMenuItem(
                              value: sector.code,
                              child: Text(sector.displayName),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedSectorCode = value),
                          validator: (value) {
                            if (value == null) return 'Please select sector';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Payee
                        TextFormField(
                          controller: _payeeController,
                          decoration: InputDecoration(
                            labelText: 'Payee',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Who receives the payment',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Amount
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount (MK)',
                            prefixIcon: const Icon(Icons.attach_money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'e.g., 10000.00',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: const Icon(Icons.notes),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Purpose or notes about this cheque',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveCheque,
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
                                : Text(
                                    _isEditing ? 'Update Cheque' : 'Add Cheque',
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
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// ADD ISSUE BOTTOM SHEET
// =============================================================================

class AddIssueBottomSheet extends ConsumerStatefulWidget {
  final String districtId;
  final String periodId;
  final String folderId;
  final String chequeId;

  const AddIssueBottomSheet({
    super.key,
    required this.districtId,
    required this.periodId,
    required this.folderId,
    required this.chequeId,
  });

  @override
  ConsumerState<AddIssueBottomSheet> createState() =>
      _AddIssueBottomSheetState();
}

class _AddIssueBottomSheetState extends ConsumerState<AddIssueBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  IssueType? _selectedIssueType;
  List<SignatoryType> _selectedSignatories = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addIssue() async {
    if (!_formKey.currentState!.validate() || _selectedIssueType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an issue type')),
      );
      return;
    }

    if (_selectedIssueType == IssueType.missingSignatories &&
        _selectedSignatories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one missing signatory'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = IssueService();
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await ref.read(currentUserDataProvider.future);

      await service.addIssue(
        districtId: widget.districtId,
        periodId: widget.periodId,
        folderId: widget.folderId,
        chequeId: widget.chequeId,
        type: _selectedIssueType!,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : _getDefaultDescription(),
        createdBy: user.uid,
        userName: userData?['name'] ?? 'Unknown',
        userRole: userData?['role'] ?? 'Unknown',
        // missingSignatories: _selectedSignatories,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Issue added successfully'),
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

  String _getDefaultDescription() {
    if (_selectedIssueType == IssueType.missingSignatories) {
      final signatoryNames = _selectedSignatories
          .map((s) => _getSignatoryName(s))
          .join(', ');
      return 'Missing signatures from: $signatoryNames';
    }
    return _getIssueTypeText(_selectedIssueType!);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                      'Add Issue',
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
                        Text(
                          'Issue Type *',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Issue Type Selection
                        ...IssueType.values.map(
                          (type) => _IssueTypeCard(
                            type: type,
                            isSelected: _selectedIssueType == type,
                            onTap: () => setState(() {
                              _selectedIssueType = type;
                              if (type != IssueType.missingSignatories) {
                                _selectedSignatories = [];
                              }
                            }),
                          ),
                        ),

                        // Missing Signatories Expansion
                        if (_selectedIssueType ==
                            IssueType.missingSignatories) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_off,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Select Missing Signatories',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...SignatoryType.values.map(
                                  (signatory) => CheckboxListTile(
                                    title: Text(_getSignatoryName(signatory)),
                                    value: _selectedSignatories.contains(
                                      signatory,
                                    ),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedSignatories.add(signatory);
                                        } else {
                                          _selectedSignatories.remove(
                                            signatory,
                                          );
                                        }
                                      });
                                    },
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Additional Notes (Optional)',
                            prefixIcon: const Icon(Icons.notes),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Add more details about this issue',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),

                        // Add Issue button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addIssue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
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
                                : const Text(
                                    'Add Issue',
                                    style: TextStyle(
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
              ),
            ],
          ),
        );
      },
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
        return 'District Commissioner (DC)';
      case SignatoryType.dof:
        return 'Director of Finance (DOF)';
      case SignatoryType.sectorHead:
        return 'Sector Head';
      case SignatoryType.accountant:
        return 'Accountant';
      case SignatoryType.compiler:
        return 'Compiler';
    }
  }
}

class _IssueTypeCard extends StatelessWidget {
  final IssueType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _IssueTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Colors.red.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.red : Colors.grey.shade300,
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
              Icon(
                _getIcon(),
                color: isSelected ? Colors.red : Colors.grey[600],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _getText(),
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.red : null,
                  ),
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case IssueType.missingSignatories:
        return Icons.person_off;
      case IssueType.missingVoucher:
        return Icons.receipt_long;
      case IssueType.missingLooseMinute:
        return Icons.description;
      case IssueType.missingRequisition:
        return Icons.request_page;
      case IssueType.missingSigningSheet:
        return Icons.assignment;
      case IssueType.noInvoice:
        return Icons.receipt;
      case IssueType.improperSupport:
        return Icons.support;
      case IssueType.missingReceipt:
        return Icons.receipt_long;
      case IssueType.other:
        return Icons.error_outline;
    }
  }

  String _getText() {
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
}
