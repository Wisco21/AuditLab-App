// lib/screens/audit/resolve_issue_dialog.dart
import 'package:auditlab/models/issue.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:auditlab/phase_two_core_features/core_services/issue_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ResolveIssueDialog extends ConsumerStatefulWidget {
  final String districtId;
  final String periodId;
  final String folderId;
  final String chequeId;
  final Issue issue;

  const ResolveIssueDialog({
    super.key,
    required this.districtId,
    required this.periodId,
    required this.folderId,
    required this.chequeId,
    required this.issue,
  });

  @override
  ConsumerState<ResolveIssueDialog> createState() => _ResolveIssueDialogState();
}

class _ResolveIssueDialogState extends ConsumerState<ResolveIssueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _resolveIssue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final issueService = IssueService();
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await ref.read(currentUserDataProvider.future);

      await issueService.resolveIssue(
        districtId: widget.districtId,
        periodId: widget.periodId,
        folderId: widget.folderId,
        chequeId: widget.chequeId,
        issueId: widget.issue.id,
        resolvedBy: user.uid,
        userName: userData!['name'] ?? 'Unknown',
        userRole: userData['role'] ?? 'Unknown',
        resolutionNotes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Issue resolved successfully'),
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

  String _getIssueTypeText(IssueType type) {
    switch (type) {
      case IssueType.missingSignatories:
        return 'Missing Signatories';
      case IssueType.noInvoice:
        return 'No Invoice';
      case IssueType.missingReceipt:
        return 'Missing Receipt';
      case IssueType.missingVoucher:
        return 'Missing Voucher';
      case IssueType.missingRequisition:
        return 'Missing Requisition';
      case IssueType.improperSupport:
        return 'Improper Support';
      case IssueType.missingLooseMinute:
        return 'Missing loose minute';
      case IssueType.missingSigningSheet:
        return 'Missing Signing Sheet';
      case IssueType.other:
        return 'Other Issue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Resolve Issue'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Issue Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getIssueTypeText(widget.issue.type),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.issue.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Resolution Notes
              const Text(
                'Resolution Notes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Explain how this issue was resolved (optional but recommended)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Receipt was found and attached...',
                  prefixIcon: Icon(Icons.edit_note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
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
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _resolveIssue,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.check_circle),
          label: const Text('Mark as Resolved'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
