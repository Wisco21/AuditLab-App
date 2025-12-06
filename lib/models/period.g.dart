// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Period _$PeriodFromJson(Map<String, dynamic> json) => _Period(
  id: json['id'] as String,
  year: json['year'] as String,
  range: json['range'] as String,
  createdBy: json['createdBy'] as String,
  supervisorId: json['supervisorId'] as String,
  createdAt: timestampFromJson(json['createdAt']),
  updatedAt: timestampFromJson(json['updatedAt']),
  status: json['status'] as String? ?? 'Pending',
);

Map<String, dynamic> _$PeriodToJson(_Period instance) => <String, dynamic>{
  'id': instance.id,
  'year': instance.year,
  'range': instance.range,
  'createdBy': instance.createdBy,
  'supervisorId': instance.supervisorId,
  'createdAt': timestampToJson(instance.createdAt),
  'updatedAt': timestampToJson(instance.updatedAt),
  'status': instance.status,
};
