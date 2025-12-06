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
  missingSignatories:
      (json['missingSignatories'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SignatoryTypeEnumMap, e))
          .toList() ??
      const [],
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
  'missingSignatories': instance.missingSignatories
      .map((e) => _$SignatoryTypeEnumMap[e]!)
      .toList(),
};

const _$IssueTypeEnumMap = {
  IssueType.missingSignatories: 'missing_signatories',
  IssueType.missingVoucher: 'missing_voucher',
  IssueType.missingLooseMinute: 'missing_loose_minute',
  IssueType.missingRequisition: 'missing_requisition',
  IssueType.missingSigningSheet: 'missing_signing_sheet',
  IssueType.noInvoice: 'no_invoice',
  IssueType.missingReceipt: 'missing_receipt',
  IssueType.improperSupport: 'improper_support',
  IssueType.other: 'other',
};

const _$SignatoryTypeEnumMap = {
  SignatoryType.dc: 'dc',
  SignatoryType.dof: 'dof',
  SignatoryType.sectorHead: 'sector_head',
  SignatoryType.accountant: 'accountant',
  SignatoryType.compiler: 'compiler',
};
