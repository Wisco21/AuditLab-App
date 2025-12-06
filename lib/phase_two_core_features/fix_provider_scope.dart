// ============================================
// FIX 2: Create providers file
// ============================================

// lib/providers/service_providers.dart
import 'package:auditlab/phase_one_auth/auth/auth_service/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../phase_one_auth/services/firestore_service.dart';

/// Auth Service Provider - Singleton
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Firestore Service Provider - Singleton
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
