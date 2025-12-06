// PART 1: Updated Issue Model with new issue types
// File: issue.dart (UPDATE THIS FILE)

import 'package:auditlab/phase_two_core_features/time_covertor.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'issue.freezed.dart';
part 'issue.g.dart';

enum IssueType {
  @JsonValue('missing_signatories')
  missingSignatories,
  @JsonValue('missing_voucher')
  missingVoucher,
  @JsonValue('missing_loose_minute')
  missingLooseMinute,
  @JsonValue('missing_requisition')
  missingRequisition,
  @JsonValue('missing_signing_sheet')
  missingSigningSheet,
  @JsonValue('no_invoice')
  noInvoice,
  @JsonValue('missing_receipt')
  missingReceipt,
  @JsonValue('improper_support')
  improperSupport,
  @JsonValue('other')
  other,
}

// For missing signatories sub-types
enum SignatoryType {
  @JsonValue('dc')
  dc,
  @JsonValue('dof')
  dof,
  @JsonValue('sector_head')
  sectorHead,
  @JsonValue('accountant')
  accountant,
  @JsonValue('compiler')
  compiler,
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
    @Default([])
    List<SignatoryType> missingSignatories, // For signatories sub-types
  }) = _Issue;

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);
}
