// lib/providers/user_provider.dart
import 'package:auditlab/phase_one_auth/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserDataProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final auth = await ref.watch(authProvider.future);
  if (auth == null) return null;

  final firestoreService = FirestoreService();
  return await firestoreService.getUserProfile(auth.uid);
});

final userRoleProvider = FutureProvider<String?>((ref) async {
  final userData = await ref.watch(currentUserDataProvider.future);
  return userData?['role'];
});

final userDistrictIdProvider = FutureProvider<String?>((ref) async {
  final userData = await ref.watch(currentUserDataProvider.future);
  return userData?['districtId'];
});

final isSupervisorProvider = FutureProvider<bool>((ref) async {
  final role = await ref.watch(userRoleProvider.future);
  return role == 'DOF' || role == 'CA';
});
// //=================================
// /// Current authenticated user stream
// final authProvider = StreamProvider<User?>((ref) {
//   final authService = ref.watch(authServiceProvider);
//   return authService.authStateChanges;
// });

// /// Current user data from Firestore
// final currentUserDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
//   final auth = await ref.watch(authProvider.future);
//   if (auth == null) return null;
  
//   final firestoreService = ref.watch(firestoreServiceProvider);
//   return await firestoreService.getUserProfile(auth.uid);
// });

// /// User role
// final userRoleProvider = FutureProvider<String?>((ref) async {
//   final userData = await ref.watch(currentUserDataProvider.future);
//   return userData?['role'];
// });

// /// User district ID
// final userDistrictIdProvider = FutureProvider<String?>((ref) async {
//   final userData = await ref.watch(currentUserDataProvider.future);
//   return userData?['districtId'];
// });

// /// Check if user is supervisor (DOF or CA)
// final isSupervisorProvider = FutureProvider<bool>((ref) async {
//   final role = await ref.watch(userRoleProvider.future);
//   return role == 'DOF' || role == 'CA';
// });

// // ======================