// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => _AuditLog(
  id: json['id'] as String,
  districtId: json['districtId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userRole: json['userRole'] as String,
  action: $enumDecode(_$AuditActionEnumMap, json['action']),
  targetType: $enumDecode(_$TargetTypeEnumMap, json['targetType']),
  targetId: json['targetId'] as String,
  targetName: json['targetName'] as String?,
  timestamp: timestampFromJson(json['timestamp']),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AuditLogToJson(_AuditLog instance) => <String, dynamic>{
  'id': instance.id,
  'districtId': instance.districtId,
  'userId': instance.userId,
  'userName': instance.userName,
  'userRole': instance.userRole,
  'action': _$AuditActionEnumMap[instance.action]!,
  'targetType': _$TargetTypeEnumMap[instance.targetType]!,
  'targetId': instance.targetId,
  'targetName': instance.targetName,
  'timestamp': timestampToJson(instance.timestamp),
  'metadata': instance.metadata,
};

const _$AuditActionEnumMap = {
  AuditAction.created: 'created',
  AuditAction.updated: 'updated',
  AuditAction.deleted: 'deleted',
  AuditAction.assigned: 'assigned',
  AuditAction.resolved: 'resolved',
  AuditAction.statusChanged: 'statusChanged',
};

const _$TargetTypeEnumMap = {
  TargetType.period: 'period',
  TargetType.folder: 'folder',
  TargetType.cheque: 'cheque',
  TargetType.issue: 'issue',
};
