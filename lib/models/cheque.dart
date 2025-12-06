import 'package:auditlab/phase_two_core_features/time_covertor.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'issue.dart';

part 'cheque.freezed.dart';
part 'cheque.g.dart';

@freezed
abstract class Cheque with _$Cheque {
  const factory Cheque({
    required String id,
    required String folderId,
    required String periodId,
    required String chequeNumber,
    required String sectorCode,
    String? assignedTo,
    required String lastUpdatedBy,
    @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
    required DateTime updatedAt,
    @Default('Pending') String status,
    @Default([]) List<Issue> issues,
    String? payee,
    double? amount,
    String? description,
  }) = _Cheque;

  factory Cheque.fromJson(Map<String, dynamic> json) => _$ChequeFromJson(json);
}
