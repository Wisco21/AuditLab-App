import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auditlab/phase_one_auth/services/firestore_service.dart';

final userDistrictDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  
  final firestoreService = FirestoreService();
  
  // Get user profile first
  final userData = await firestoreService.getUserProfile(user.uid);
  if (userData == null) return null;
  
  // Try to get district by ID first, then by code as fallback
  Map<String, dynamic>? districtData;
  
  if (userData['districtId'] != null) {
    districtData = await firestoreService.getDistrict(userData['districtId']);
  }
  
  // If district not found by ID, try by code
  if (districtData == null && userData['districtCode'] != null) {
    districtData = await firestoreService.getDistrictByCode(userData['districtCode']);
  }
  
  return districtData;
});