// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Issue _$IssueFromJson(Map<String, dynamic> json) => _Issue(
  id: json['id'] as String,
  type: $enumDecode(_$IssueTypeEnumMap, json['type']),
  description: json['description'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: timestampFromJson(json['createdAt']),
  status: json['status'] as String? ?? 'Open',
  resolvedBy: json['resolvedBy'] as String?,
  resolvedAt: nullableTimestampFromJson(json['resolvedAt']),
  resolutionNotes: json['resolutionNotes'] as String?,
);

Map<String, dynamic> _$IssueToJson(_Issue instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$IssueTypeEnumMap[instance.type]!,
  'description': instance.description,
  'createdBy': instance.createdBy,
  'createdAt': timestampToJson(instance.createdAt),
  'status': instance.status,
  'resolvedBy': instance.resolvedBy,
  'resolvedAt': nullableTimestampToJson(instance.resolvedAt),
  'resolutionNotes': instance.resolutionNotes,
};

const _$IssueTypeEnumMap = {
  IssueType.missingReceipt: 'missing_receipt',
  IssueType.wrongCoding: 'wrong_coding',
  IssueType.overExpenditure: 'over_expenditure',
  IssueType.improperSupport: 'improper_support',
  IssueType.other: 'other',
};
