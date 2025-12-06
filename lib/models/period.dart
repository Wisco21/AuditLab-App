import 'package:auditlab/phase_two_core_features/time_covertor.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'period.freezed.dart';
part 'period.g.dart';

@freezed
abstract class Period with _$Period {
  // const Period._();

  // @JsonSerializable(explicitToJson: true)
  const factory Period({
    required String id,
    required String year,
    required String range,
    required String createdBy,
    required String supervisorId,

    @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
    required DateTime updatedAt,
    @Default('Pending') String status,
  }) = _Period;

  factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);
}
