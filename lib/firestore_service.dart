import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';

/// Service to handle all Firestore database operations
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ==================== USER OPERATIONS ====================

  // /// Create or update user profile
  // Future<void> createUserProfile({
  //   required String userId,
  //   required String email,
  //   required String name,
  //   required String phone,
  //   required String role,
  //   required String districtId,
  //   required List<String> sectorCodes,
  //   String? profilePictureUrl,
  // }) async {
  //   await _db.collection('users').doc(userId).set({
  //     'email': email,
  //     'name': name,
  //     'phone': phone,
  //     'role': role,
  //     'districtId': districtId,
  //     'sectorCodes': sectorCodes,
  //     'profilePictureUrl': profilePictureUrl,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'updatedAt': FieldValue.serverTimestamp(),
  //   }, SetOptions(merge: true));
  // }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  /// Update user role selection (first step after signup)
  /// Creates the document if it doesn't exist
  Future<void> updateUserRole(String userId, String role, String email) async {
    await _db.collection('users').doc(userId).set({
      'role': role,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream user profile
  Stream<DocumentSnapshot> streamUserProfile(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // ==================== DISTRICT OPERATIONS ====================

  // /// Create a new district (DOF/CA only)
  // Future<String> createDistrict({
  //   required String districtName,
  //   required String createdBy,
  // }) async {
  //   final districtId = _uuid.v4();
  //   final joinCode = _generateJoinCode();
  //   final expiresAt = DateTime.now().add(const Duration(hours: 24));

  //   await _db.collection('districts').doc(districtId).set({
  //     'districtId': districtId,
  //     'districtName': districtName,
  //     'createdBy': createdBy,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'joinCode': joinCode,
  //     'joinCodeExpiresAt': Timestamp.fromDate(expiresAt),
  //   });

  //   return districtId;
  // }

  /// Check if district exists by name
  Future<String?> getDistrictIdByName(String districtName) async {
    final query = await _db
        .collection('districts')
        .where('districtName', isEqualTo: districtName)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  /// Get district by ID
  Future<Map<String, dynamic>?> getDistrict(String districtId) async {
    final doc = await _db.collection('districts').doc(districtId).get();
    return doc.exists ? doc.data() : null;
  }

  /// Validate join code and get district ID
  Future<String?> validateJoinCode(String joinCode) async {
    final query = await _db
        .collection('districts')
        .where('joinCode', isEqualTo: joinCode.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final district = query.docs.first.data();
    final expiresAt = (district['joinCodeExpiresAt'] as Timestamp).toDate();

    // Check if code is expired
    if (DateTime.now().isAfter(expiresAt)) {
      throw Exception('Join code has expired');
    }

    return query.docs.first.id;
  }

  /// Generate a new join code for a district
  Future<String> generateNewJoinCode(String districtId) async {
    final joinCode = _generateJoinCode();
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    await _db.collection('districts').doc(districtId).update({
      'joinCode': joinCode,
      'joinCodeExpiresAt': Timestamp.fromDate(expiresAt),
    });

    return joinCode;
  }

  /// Helper to generate random alphanumeric join code
  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Exclude ambiguous chars
    final random = Random.secure();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // ==================== CA ROLE REQUEST OPERATIONS ====================

  /// Get unavailable sector codes (sectors already assigned to Accountants)
  Future<List<String>> getUnavailableSectorCodes(String districtId) async {
    final accountants = await _db
        .collection('users')
        .where('districtId', isEqualTo: districtId)
        .where('role', isEqualTo: 'Accountant')
        .get();

    final Set<String> unavailableCodes = {};
    for (var doc in accountants.docs) {
      final data = doc.data();
      final sectorCodes = List<String>.from(data['sectorCodes'] ?? []);
      unavailableCodes.addAll(sectorCodes);
    }

    return unavailableCodes.toList();
  }

  /// Assign CA role to a user (DOF only)
  /// Only Accountants with "Other" (000) sector can be assigned as CA
  Future<void> assignCARole({
    required String districtId,
    required String userId,
  }) async {
    // Get user data to verify they're eligible
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception('User not found');
    }

    final userData = userDoc.data()!;

    // Verify user is an Accountant
    if (userData['role'] != 'Accountant') {
      throw Exception('Only Accountants can be assigned as CA');
    }

    // Verify user has "Other" (000) sector
    final sectorCodes = List<String>.from(userData['sectorCodes'] ?? []);
    if (!sectorCodes.contains('000')) {
      throw Exception(
        'Only Accountants with "Other" sector can be assigned as CA',
      );
    }

    // Update user role to CA
    await _db.collection('users').doc(userId).update({
      'role': 'CA',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove CA role from a user (DOF only)
  Future<void> removeCARole({required String userId}) async {
    // Revert back to Accountant role
    await _db.collection('users').doc(userId).update({
      'role': 'Accountant',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user details for a CA request
  Future<Map<String, dynamic>?> getUserForRequest(String userId) async {
    return await getUserProfile(userId);
  }
  // ==================== DISTRICT MEMBERS ====================

  /// Get all users in a district
  Stream<QuerySnapshot> streamDistrictMembers(String districtId) {
    return _db
        .collection('users')
        .where('districtId', isEqualTo: districtId)
        .snapshots();
  }

  //   /// Check if a role already exists in a district
  // Future<bool> checkExistingRoleInDistrict(String districtCode, String role) async {
  //   final query = await _db
  //       .collection('users')
  //       .where('districtCode', isEqualTo: districtCode)
  //       .where('role', isEqualTo: role)
  //       .limit(1)
  //       .get();

  //   return query.docs.isNotEmpty;
  // }

  // /// Update user role and district
  // Future<void> updateUserRoleAndDistrict(
  //   String userId,
  //   String role,
  //   String email,
  //   String districtCode,
  //   String districtName,
  // ) async {
  //   await _db.collection('users').doc(userId).set({
  //     'role': role,
  //     'email': email,
  //     'districtCode': districtCode,
  //     'districtName': districtName,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'updatedAt': FieldValue.serverTimestamp(),
  //   }, SetOptions(merge: true));
  // }

  // /// Create district with district code
  // Future<String> createDistrict({
  //   required String districtName,
  //   required String districtCode,
  //   required String createdBy,
  // }) async {
  //   final districtId = _uuid.v4();
  //   final joinCode = _generateJoinCode();
  //   final expiresAt = DateTime.now().add(const Duration(hours: 24));

  //   await _db.collection('districts').doc(districtId).set({
  //     'districtId': districtId,
  //     'districtCode': districtCode,
  //     'districtName': districtName,
  //     'createdBy': createdBy,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'joinCode': joinCode,
  //     'joinCodeExpiresAt': Timestamp.fromDate(expiresAt),
  //   });

  //   return districtId;
  // }

  /// Create or update user profile
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String name,
    required String phone,
    required String role,
    required String districtId,
    required String districtCode,
    required String districtName,
    required List<String> sectorCodes,
    String? profilePictureUrl,
  }) async {
    await _db.collection('users').doc(userId).set({
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'districtId': districtId,
      'districtCode': districtCode,
      'districtName': districtName,
      'sectorCodes': sectorCodes,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update user role and district
  Future<void> updateUserRoleAndDistrict(
    String userId,
    String role,
    String email,
    String districtCode,
    String districtName,
  ) async {
    await _db.collection('users').doc(userId).set({
      'role': role,
      'email': email,
      'districtCode': districtCode,
      'districtName': districtName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Check if a role already exists in a district
  Future<bool> checkExistingRoleInDistrict(
    String districtCode,
    String role,
  ) async {
    final query = await _db
        .collection('users')
        .where('districtCode', isEqualTo: districtCode)
        .where('role', isEqualTo: role)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  /// Create district with district code
  Future<String> createDistrict({
    required String districtName,
    required String districtCode,
    required String createdBy,
  }) async {
    final districtId = _uuid.v4();
    final joinCode = _generateJoinCode();
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    await _db.collection('districts').doc(districtId).set({
      'districtId': districtId,
      'districtCode': districtCode,
      'districtName': districtName,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'joinCode': joinCode,
      'joinCodeExpiresAt': Timestamp.fromDate(expiresAt),
    });

    return districtId;
  }
}
