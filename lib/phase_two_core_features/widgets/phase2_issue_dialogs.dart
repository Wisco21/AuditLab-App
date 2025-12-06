// // lib/screens/audit/add_issue_dialog.dart
// import 'package:auditlab/phase2/models/issue.dart';
// import 'package:auditlab/phase2/provider/user_provider.dart';
// import 'package:auditlab/phase2/services/issue_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AddIssueDialog extends ConsumerStatefulWidget {
//   final String districtId;
//   final String periodId;
//   final String folderId;
//   final String chequeId;

//   const AddIssueDialog({
//     super.key,
//     required this.districtId,
//     required this.periodId,
//     required this.folderId,
//     required this.chequeId,
//   });

//   @override
//   ConsumerState<AddIssueDialog> createState() => _AddIssueDialogState();
// }

// class _AddIssueDialogState extends ConsumerState<AddIssueDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _descriptionController = TextEditingController();
//   IssueType? _selectedType;
//   bool _isLoading = false;

//   final List<Map<String, dynamic>> _issueTypes = [
//     {
//       'type': IssueType.missingReceipt,
//       'label': 'Missing Receipt',
//       'icon': Icons.receipt_long,
//       'description': 'Receipt or supporting document is missing',
//     },
//     {
//       'type': IssueType.wrongCoding,
//       'label': 'Wrong Coding',
//       'icon': Icons.code_off,
//       'description': 'Incorrect account or budget code',
//     },
//     {
//       'type': IssueType.overExpenditure,
//       'label': 'Over Expenditure',
//       'icon': Icons.trending_up,
//       'description': 'Amount exceeds budget allocation',
//     },
//     {
//       'type': IssueType.improperSupport,
//       'label': 'Improper Support',
//       'icon': Icons.description,
//       'description': 'Supporting documents are incomplete or inadequate',
//     },
//     {
//       'type': IssueType.other,
//       'label': 'Other Issue',
//       'icon': Icons.error_outline,
//       'description': 'Other audit issue',
//     },
//   ];

//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _addIssue() async {
//     if (!_formKey.currentState!.validate() || _selectedType == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final issueService = IssueService();
//       final user = FirebaseAuth.instance.currentUser!;
//       final userData = await ref.read(currentUserDataProvider.future);

//       await issueService.addIssue(
//         districtId: widget.districtId,
//         periodId: widget.periodId,
//         folderId: widget.folderId,
//         chequeId: widget.chequeId,
//         type: _selectedType!,
//         description: _descriptionController.text.trim(),
//         createdBy: user.uid,
//         userName: userData!['name'] ?? 'Unknown',
//         userRole: userData['role'] ?? 'Unknown',
//       );

//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Issue added successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Add Issue'),
//       content: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Issue Type',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//               ),
//               const SizedBox(height: 12),
//               ..._issueTypes.map((issueType) {
//                 final isSelected = _selectedType == issueType['type'];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   color: isSelected ? Colors.red.shade50 : Colors.white,
//                   child: InkWell(
//                     onTap: () =>
//                         setState(() => _selectedType = issueType['type']),
//                     borderRadius: BorderRadius.circular(12),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         children: [
//                           Radio<IssueType>(
//                             value: issueType['type'],
//                             groupValue: _selectedType,
//                             onChanged: (value) =>
//                                 setState(() => _selectedType = value),
//                           ),
//                           Icon(
//                             issueType['icon'],
//                             color: isSelected ? Colors.red : Colors.grey,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   issueType['label'],
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: isSelected
//                                         ? Colors.red[700]
//                                         : Colors.black87,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   issueType['description'],
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description *',
//                   hintText: 'Describe the issue in detail...',
//                   prefixIcon: Icon(Icons.notes),
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 4,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please describe the issue';
//                   }
//                   if (value.length < 10) {
//                     return 'Please provide more details (min 10 characters)';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: _isLoading ? null : () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _isLoading ? null : _addIssue,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red,
//             foregroundColor: Colors.white,
//           ),
//           child: _isLoading
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation(Colors.white),
//                   ),
//                 )
//               : const Text('Add Issue'),
//         ),
//       ],
//     );
//   }
// }
