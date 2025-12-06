import 'package:auditlab/phase_one_auth/auth/auth_service/auth_service.dart';
import 'package:auditlab/phase_one_auth/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth Service Provider - Singleton instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Firestore Service Provider - Singleton instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
