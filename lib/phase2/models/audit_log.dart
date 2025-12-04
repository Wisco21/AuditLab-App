import 'package:auditlab/phase2/time_covertor.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

enum AuditAction {
  created,
  updated,
  deleted,
  assigned,
  resolved,
  statusChanged,
}

enum TargetType { period, folder, cheque, issue }

@freezed
abstract class AuditLog with _$AuditLog {
  const AuditLog._(); // Add this line

  const factory AuditLog({
    required String id,
    required String districtId,
    required String userId,
    required String userName,
    required String userRole,
    required AuditAction action,
    required TargetType targetType,
    required String targetId,
    String? targetName,
    @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);
}

// import 'package:auditlab/phase2/timeStamp.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'audit_log.freezed.dart';
// part 'audit_log.g.dart';

// enum AuditAction {
//   created,
//   updated,
//   deleted,
//   assigned,
//   resolved,
//   statusChanged,
// }

// enum TargetType { period, folder, cheque, issue }

// @freezed
// class AuditLog with _$AuditLog {
//   const AuditLog._();

//   @JsonSerializable(explicitToJson: true)
//   const factory AuditLog({
//     required String id,
//     required String districtId,
//     required String userId,
//     required String userName,
//     required String userRole,
//     required AuditAction action,
//     required TargetType targetType,
//     required String targetId,
//     String? targetName,
//     @TimestampConverter() required DateTime timestamp,
//     Map<String, dynamic>? metadata,
//   }) = _AuditLog;

//   factory AuditLog.fromJson(Map<String, dynamic> json) =>
//       _$AuditLogFromJson(json);
// }
