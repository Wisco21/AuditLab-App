// lib/providers/audit/period_provider.dart
import 'package:auditlab/models/period.dart';
import 'package:auditlab/phase_two_core_features/core_services/period_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final periodServiceProvider = Provider((ref) => PeriodService());

final periodsProvider = StreamProvider.family<List<Period>, String>((
  ref,
  districtId,
) {
  final service = ref.watch(periodServiceProvider);
  return service.streamPeriods(districtId);
});

final selectedPeriodProvider = StateProvider<Period?>((ref) => null);
