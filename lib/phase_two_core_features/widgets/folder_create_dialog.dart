// lib/screens/audit/create_folder_dialog.dart
import 'package:auditlab/phase_two_core_features/provider/folder_provider.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateFolderDialog extends ConsumerStatefulWidget {
  final String districtId;
  final String periodId;

  const CreateFolderDialog({
    super.key,
    required this.districtId,
    required this.periodId,
  });

  @override
  ConsumerState<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends ConsumerState<CreateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _folderNumberController = TextEditingController();
  final _startChequeController = TextEditingController();
  final _endChequeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _folderNumberController.dispose();
    _startChequeController.dispose();
    _endChequeController.dispose();
    super.dispose();
  }

  Future<void> _createFolder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(folderServiceProvider);
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await ref.read(currentUserDataProvider.future);

      await service.createFolder(
        districtId: widget.districtId,
        periodId: widget.periodId,
        folderNumber: _folderNumberController.text,
        chequeRangeStart: _startChequeController.text,
        chequeRangeEnd: _endChequeController.text,
        createdBy: user.uid,
        userName: userData!['name'] ?? 'Unknown',
        userRole: userData['role'] ?? 'Unknown',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Folder created successfully'),
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
      title: const Text('Create New Folder'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _folderNumberController,
                decoration: const InputDecoration(
                  labelText: 'Folder Number',
                  prefixIcon: Icon(Icons.folder),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter folder number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startChequeController,
                decoration: const InputDecoration(
                  labelText: 'Start Cheque Number',
                  prefixIcon: Icon(Icons.receipt),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter start cheque number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endChequeController,
                decoration: const InputDecoration(
                  labelText: 'End Cheque Number',
                  prefixIcon: Icon(Icons.receipt_long),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter end cheque number';
                  }
                  return null;
                },
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
          onPressed: _isLoading ? null : _createFolder,
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
