// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Folder _$FolderFromJson(Map<String, dynamic> json) => _Folder(
  id: json['id'] as String,
  periodId: json['periodId'] as String,
  folderNumber: json['folderNumber'] as String,
  chequeRangeStart: json['chequeRangeStart'] as String,
  chequeRangeEnd: json['chequeRangeEnd'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: timestampFromJson(json['createdAt']),
  updatedAt: timestampFromJson(json['updatedAt']),
  lastUpdatedBy: json['lastUpdatedBy'] as String,
  status: json['status'] as String? ?? 'Pending',
  totalCheques: (json['totalCheques'] as num?)?.toInt() ?? 0,
  completedCheques: (json['completedCheques'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$FolderToJson(_Folder instance) => <String, dynamic>{
  'id': instance.id,
  'periodId': instance.periodId,
  'folderNumber': instance.folderNumber,
  'chequeRangeStart': instance.chequeRangeStart,
  'chequeRangeEnd': instance.chequeRangeEnd,
  'createdBy': instance.createdBy,
  'createdAt': timestampToJson(instance.createdAt),
  'updatedAt': timestampToJson(instance.updatedAt),
  'lastUpdatedBy': instance.lastUpdatedBy,
  'status': instance.status,
  'totalCheques': instance.totalCheques,
  'completedCheques': instance.completedCheques,
};
