// // lib/screens/audit/folders_screen.dart
// import 'package:auditlab/phase2/models/folder.dart';
// import 'package:auditlab/phase2/models/period.dart';
// import 'package:auditlab/phase2/phase2_folders_cheques_screens.dart';
// import 'package:auditlab/phase2/models/audit_log.dart';
// import 'package:auditlab/phase2/widgets/folder_create_dialog.dart';
// import 'package:auditlab/phase2/provider/folder_provider.dart';
// import 'package:auditlab/phase2/provider/permission_provider.dart';
// import 'package:auditlab/phase2/provider/user_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class FoldersScreen extends ConsumerWidget {
//   final String districtId;
//   final Period period;

//   const FoldersScreen({
//     super.key,
//     required this.districtId,
//     required this.period,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isSupervisor = ref.watch(isSupervisorProvider).value ?? false;
//     final foldersAsync = ref.watch(
//       foldersProvider((districtId: districtId, periodId: period.id)),
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('${period.year} - ${period.range}'),
//             Text(
//               'Folders',
//               style: Theme.of(
//                 context,
//               ).textTheme.bodySmall?.copyWith(color: Colors.white70),
//             ),
//           ],
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           ref.invalidate(
//             foldersProvider((districtId: districtId, periodId: period.id)),
//           );
//         },
//         child: foldersAsync.when(
//           data: (folders) {
//             if (folders.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.folder_outlined,
//                       size: 64,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No folders yet',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       isSupervisor
//                           ? 'Tap the + button to create a folder'
//                           : 'Waiting for supervisor to create folders',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: folders.length,
//               itemBuilder: (context, index) {
//                 final folder = folders[index];
//                 return _FolderCard(folder: folder, districtId: districtId);
//               },
//             );
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (error, stack) => Center(child: Text('Error: $error')),
//         ),
//       ),
//       floatingActionButton: isSupervisor
//           ? FloatingActionButton.extended(
//               onPressed: () => _showCreateFolderDialog(context),
//               icon: const Icon(Icons.add),
//               label: const Text('New Folder'),
//             )
//           : null,
//     );
//   }

//   void _showCreateFolderDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) =>
//           CreateFolderDialog(districtId: districtId, periodId: period.id),
//     );
//   }
// }

// class _FolderCard extends ConsumerWidget {
//   final Folder folder;
//   final String districtId;

//   const _FolderCard({required this.folder, required this.districtId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final progress = folder.totalCheques > 0
//         ? folder.completedCheques / folder.totalCheques
//         : 0.0;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: () {
//           ref.read(selectedFolderProvider.notifier).state = folder;
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   FolderDetailsScreen(districtId: districtId, folder: folder),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(folder.status).withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       Icons.folder,
//                       color: _getStatusColor(folder.status),
//                       size: 32,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Folder ${folder.folderNumber}',
//                           style: Theme.of(context).textTheme.titleLarge
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Cheques: ${folder.chequeRangeStart} - ${folder.chequeRangeEnd}',
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   ),
//                   _StatusChip(status: folder.status),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '${folder.completedCheques}/${folder.totalCheques} Cheques',
//                           style: TextStyle(
//                             color: Colors.grey[700],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         LinearProgressIndicator(
//                           value: progress,
//                           backgroundColor: Colors.grey[200],
//                           valueColor: AlwaysStoppedAnimation(
//                             _getStatusColor(folder.status),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Completed':
//         return Colors.green;
//       case 'In Progress':
//         return Colors.orange;
//       default:
//         return Colors.blue;
//     }
//   }
// }

// class _StatusChip extends StatelessWidget {
//   final String status;

//   const _StatusChip({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: _getColor().withOpacity(0.2),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _getColor()),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: _getColor(),
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Color _getColor() {
//     switch (status) {
//       case 'Completed':
//         return Colors.green;
//       case 'In Progress':
//         return Colors.orange;
//       default:
//         return Colors.blue;
//     }
//   }
// }
