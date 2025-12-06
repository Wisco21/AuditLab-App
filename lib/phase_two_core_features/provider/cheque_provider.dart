// lib/providers/audit/cheque_provider.dart
import 'package:auditlab/models/cheque.dart';
import 'package:auditlab/phase_two_core_features/core_services/cheque_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chequeServiceProvider = Provider((ref) => ChequeService());

final chequesProvider =
    StreamProvider.family<
      List<Cheque>,
      ({String districtId, String periodId, String folderId})
    >((ref, params) {
      final service = ref.watch(chequeServiceProvider);
      return service.streamCheques(
        params.districtId,
        params.periodId,
        params.folderId,
      );
    });

final userChequesProvider =
    StreamProvider.family<List<Cheque>, ({String districtId, String userId})>((
      ref,
      params,
    ) {
      final service = ref.watch(chequeServiceProvider);
      return service.streamUserCheques(params.districtId, params.userId);
    });

final selectedChequeProvider = StateProvider<Cheque?>((ref) => null);
