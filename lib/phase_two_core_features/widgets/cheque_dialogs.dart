// lib/screens/audit/create_cheque_dialog.dart
import 'package:auditlab/phase_one_auth/models/models_sector.dart';
import 'package:auditlab/phase_two_core_features/provider/cheque_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateChequeDialog extends ConsumerStatefulWidget {
  final String districtId;
  final String periodId;
  final String folderId;

  const CreateChequeDialog({
    super.key,
    required this.districtId,
    required this.periodId,
    required this.folderId,
  });

  @override
  ConsumerState<CreateChequeDialog> createState() => _CreateChequeDialogState();
}

class _CreateChequeDialogState extends ConsumerState<CreateChequeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _chequeNumberController = TextEditingController();
  final _payeeController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedSectorCode;
  bool _isLoading = false;

  @override
  void dispose() {
    _chequeNumberController.dispose();
    _payeeController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createCheque() async {
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

      await service.createCheque(
        districtId: widget.districtId,
        periodId: widget.periodId,
        folderId: widget.folderId,
        chequeNumber: _chequeNumberController.text.trim(),
        sectorCode: _selectedSectorCode!,
        createdBy: user.uid,
        userName: userData!['name'] ?? 'Unknown',
        userRole: userData['role'] ?? 'Unknown',
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
    return AlertDialog(
      title: const Text('Add Cheque'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cheque Number
              TextFormField(
                controller: _chequeNumberController,
                decoration: const InputDecoration(
                  labelText: 'Cheque Number *',
                  prefixIcon: Icon(Icons.receipt),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cheque number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sector Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSectorCode,
                decoration: const InputDecoration(
                  labelText: 'Sector *',
                  prefixIcon: Icon(Icons.business),
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
              const SizedBox(height: 16),

              // Payee (Optional)
              TextFormField(
                controller: _payeeController,
                decoration: const InputDecoration(
                  labelText: 'Payee',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Amount (Optional)
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'e.g., 10000.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Description (Optional)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createCheque,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
