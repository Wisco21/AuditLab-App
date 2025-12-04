// lib/screens/audit/create_period_dialog.dart
import 'package:auditlab/phase2/provider/period_provider.dart';
import 'package:auditlab/phase2/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePeriodDialog extends ConsumerStatefulWidget {
  const CreatePeriodDialog({super.key});

  @override
  ConsumerState<CreatePeriodDialog> createState() => _CreatePeriodDialogState();
}

class _CreatePeriodDialogState extends ConsumerState<CreatePeriodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  String? _selectedRange;
  bool _isLoading = false;

  final List<String> _ranges = ['Jan-Mar', 'Apr-Jun', 'Jul-Sep', 'Oct-Dec'];

  @override
  void initState() {
    super.initState();
    _yearController.text = DateTime.now().year.toString();
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _createPeriod() async {
    if (!_formKey.currentState!.validate() || _selectedRange == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(periodServiceProvider);
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await ref.read(currentUserDataProvider.future);
      final districtId = userData!['districtId'] as String;

      await service.createPeriod(
        districtId: districtId,
        year: _yearController.text,
        range: _selectedRange!,
        createdBy: user.uid,
        supervisorId: user.uid,
        userName: userData['name'] ?? 'Unknown',
        userRole: userData['role'] ?? 'Unknown',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Period created successfully'),
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
      title: const Text('Create New Period'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter year';
                }
                final year = int.tryParse(value);
                if (year == null || year < 2000 || year > 2100) {
                  return 'Please enter valid year';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRange,
              decoration: const InputDecoration(
                labelText: 'Quarter',
                prefixIcon: Icon(Icons.date_range),
              ),
              items: _ranges.map((range) {
                return DropdownMenuItem(value: range, child: Text(range));
              }).toList(),
              onChanged: (value) => setState(() => _selectedRange = value),
              validator: (value) {
                if (value == null) return 'Please select quarter';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createPeriod,
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
