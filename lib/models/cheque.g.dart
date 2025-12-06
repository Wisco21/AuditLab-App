// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cheque.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Cheque _$ChequeFromJson(Map<String, dynamic> json) => _Cheque(
  id: json['id'] as String,
  folderId: json['folderId'] as String,
  periodId: json['periodId'] as String,
  chequeNumber: json['chequeNumber'] as String,
  sectorCode: json['sectorCode'] as String,
  assignedTo: json['assignedTo'] as String?,
  lastUpdatedBy: json['lastUpdatedBy'] as String,
  createdAt: timestampFromJson(json['createdAt']),
  updatedAt: timestampFromJson(json['updatedAt']),
  status: json['status'] as String? ?? 'Pending',
  issues:
      (json['issues'] as List<dynamic>?)
          ?.map((e) => Issue.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  payee: json['payee'] as String?,
  amount: (json['amount'] as num?)?.toDouble(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$ChequeToJson(_Cheque instance) => <String, dynamic>{
  'id': instance.id,
  'folderId': instance.folderId,
  'periodId': instance.periodId,
  'chequeNumber': instance.chequeNumber,
  'sectorCode': instance.sectorCode,
  'assignedTo': instance.assignedTo,
  'lastUpdatedBy': instance.lastUpdatedBy,
  'createdAt': timestampToJson(instance.createdAt),
  'updatedAt': timestampToJson(instance.updatedAt),
  'status': instance.status,
  'issues': instance.issues,
  'payee': instance.payee,
  'amount': instance.amount,
  'description': instance.description,
};
