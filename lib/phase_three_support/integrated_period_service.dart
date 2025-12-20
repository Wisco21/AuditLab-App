// // lib/phase_two_core_features/core_services/period_service.dart
// // Add this to your existing PeriodService class

// import 'package:auditlab/phase_three_support/notification_model.dart';
// import 'package:auditlab/phase_three_support/notification_repository.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../models/period.dart';
// // import '../../repositories/notification_repository.dart';

// class PeriodService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final NotificationRepository _notificationRepo = NotificationRepository();

//   // ... your existing methods ...

//   /// Assign supervisor to a period
//   Future<void> assignSupervisor({
//     required String districtId,
//     required String periodId,
//     required String supervisorId,
//     required String assignedByUserId,
//     required String assignedByName,
//   }) async {
//     await _db
//         .collection('districts')
//         .doc(districtId)
//         .collection('periods')
//         .doc(periodId)
//         .update({
//           'supervisorId': supervisorId,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });

//     // ============= NOTIFICATION INTEGRATION =============
//     // Get period details for notification
//     final periodDoc = await _db
//         .collection('districts')
//         .doc(districtId)
//         .collection('periods')
//         .doc(periodId)
//         .get();

//     if (periodDoc.exists) {
//       final periodData = periodDoc.data()!;
//       final periodName = '${periodData['year']} - ${periodData['range']}';

//       await _notificationRepo.createNotification(
//         userId: supervisorId,
//         type: NotificationType.supervisorAssignment,
//         title: 'New Supervisor Assignment',
//         message:
//             'You have been assigned as supervisor for period $periodName by $assignedByName',
//         data: {
//           'periodId': periodId,
//           'periodName': periodName,
//           'assignedBy': assignedByName,
//           'districtId': districtId,
//         },
//       );

//       // Also send local notification
//       await _notificationRepo.notifySupervisorAssignment(
//         supervisorId: supervisorId,
//         chequeNumber: periodName, // Use period name as identifier
//         assignedByName: assignedByName,
//       );
//     }
//     // ============= END NOTIFICATION INTEGRATION =============
//   }

//   /// Update supervisor for a period
//   Future<void> updateSupervisor({
//     required String districtId,
//     required String periodId,
//     required String newSupervisorId,
//     required String updatedByUserId,
//     required String updatedByName,
//   }) async {
//     // Get old supervisor for notification
//     final periodDoc = await _db
//         .collection('districts')
//         .doc(districtId)
//         .collection('periods')
//         .doc(periodId)
//         .get();

//     final oldSupervisorId = periodDoc.data()?['supervisorId'] as String?;

//     // Update supervisor
//     await _db
//         .collection('districts')
//         .doc(districtId)
//         .collection('periods')
//         .doc(periodId)
//         .update({
//           'supervisorId': newSupervisorId,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });

//     // ============= NOTIFICATION INTEGRATION =============
//     if (periodDoc.exists) {
//       final periodData = periodDoc.data()!;
//       final periodName = '${periodData['year']} - ${periodData['range']}';

//       // Notify new supervisor
//       await _notificationRepo.createNotification(
//         userId: newSupervisorId,
//         type: NotificationType.supervisorAssignment,
//         title: 'New Supervisor Assignment',
//         message:
//             'You have been assigned as supervisor for period $periodName by $updatedByName',
//         data: {
//           'periodId': periodId,
//           'periodName': periodName,
//           'assignedBy': updatedByName,
//           'districtId': districtId,
//         },
//       );

//       // Notify old supervisor about removal (if exists and different)
//       if (oldSupervisorId != null && oldSupervisorId != newSupervisorId) {
//         await _notificationRepo.createNotification(
//           userId: oldSupervisorId,
//           type: NotificationType.statusUpdate,
//           title: 'Supervisor Role Changed',
//           message: 'You are no longer the supervisor for period $periodName',
//           data: {
//             'periodId': periodId,
//             'periodName': periodName,
//             'updatedBy': updatedByName,
//             'districtId': districtId,
//           },
//         );
//       }
//     }
//     // ============= END NOTIFICATION INTEGRATION =============
//   }

//   /// Stream periods for a district
//   Stream<List<Period>> streamPeriods(String districtId) {
//     return _db
//         .collection('districts')
//         .doc(districtId)
//         .collection('periods')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map(
//           (snapshot) =>
//               snapshot.docs.map((doc) => Period.fromJson(doc.data())).toList(),
//         );
//   }

//   /// Get a single period
//   Future<Period?> getPeriod(String districtId, String periodId) async {
//     final doc = await _db
//         .collection('districts')
//         .doc(districtId)
//         .collection('periods')
//         .doc(periodId)
//         .get();

//     if (!doc.exists) return null;
//     return Period.fromJson(doc.data()!);
//   }
// }
