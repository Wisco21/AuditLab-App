import 'package:auditlab/phase2/time_covertor.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'issue.freezed.dart';
part 'issue.g.dart';

enum IssueType {
  @JsonValue('missing_receipt')
  missingReceipt,
  @JsonValue('wrong_coding')
  wrongCoding,
  @JsonValue('over_expenditure')
  overExpenditure,
  @JsonValue('improper_support')
  improperSupport,
  @JsonValue('other')
  other,
}

@freezed
abstract class Issue with _$Issue {
  const factory Issue({
    required String id,
    required IssueType type,
    required String description,
    required String createdBy,
    @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
    required DateTime createdAt,
    @Default('Open') String status,
    String? resolvedBy,
    @JsonKey(
      fromJson: nullableTimestampFromJson,
      toJson: nullableTimestampToJson,
    )
    DateTime? resolvedAt,
    String? resolutionNotes,
  }) = _Issue;

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);
}
