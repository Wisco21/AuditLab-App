// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditLog {

 String get id; String get districtId; String get userId; String get userName; String get userRole; AuditAction get action; TargetType get targetType; String get targetId; String? get targetName;@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime get timestamp; Map<String, dynamic>? get metadata;
/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogCopyWith<AuditLog> get copyWith => _$AuditLogCopyWithImpl<AuditLog>(this as AuditLog, _$identity);

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLog&&(identical(other.id, id) || other.id == id)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.action, action) || other.action == action)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.targetName, targetName) || other.targetName == targetName)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,districtId,userId,userName,userRole,action,targetType,targetId,targetName,timestamp,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'AuditLog(id: $id, districtId: $districtId, userId: $userId, userName: $userName, userRole: $userRole, action: $action, targetType: $targetType, targetId: $targetId, targetName: $targetName, timestamp: $timestamp, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $AuditLogCopyWith<$Res>  {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) _then) = _$AuditLogCopyWithImpl;
@useResult
$Res call({
 String id, String districtId, String userId, String userName, String userRole, AuditAction action, TargetType targetType, String targetId, String? targetName,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime timestamp, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$AuditLogCopyWithImpl<$Res>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._self, this._then);

  final AuditLog _self;
  final $Res Function(AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? districtId = null,Object? userId = null,Object? userName = null,Object? userRole = null,Object? action = null,Object? targetType = null,Object? targetId = null,Object? targetName = freezed,Object? timestamp = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,districtId: null == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userRole: null == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as TargetType,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,targetName: freezed == targetName ? _self.targetName : targetName // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLog].
extension AuditLogPatterns on AuditLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLog value)  $default,){
final _that = this;
switch (_that) {
case _AuditLog():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLog value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String districtId,  String userId,  String userName,  String userRole,  AuditAction action,  TargetType targetType,  String targetId,  String? targetName, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime timestamp,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.id,_that.districtId,_that.userId,_that.userName,_that.userRole,_that.action,_that.targetType,_that.targetId,_that.targetName,_that.timestamp,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String districtId,  String userId,  String userName,  String userRole,  AuditAction action,  TargetType targetType,  String targetId,  String? targetName, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime timestamp,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _AuditLog():
return $default(_that.id,_that.districtId,_that.userId,_that.userName,_that.userRole,_that.action,_that.targetType,_that.targetId,_that.targetName,_that.timestamp,_that.metadata);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String districtId,  String userId,  String userName,  String userRole,  AuditAction action,  TargetType targetType,  String targetId,  String? targetName, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime timestamp,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.id,_that.districtId,_that.userId,_that.userName,_that.userRole,_that.action,_that.targetType,_that.targetId,_that.targetName,_that.timestamp,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLog extends AuditLog {
  const _AuditLog({required this.id, required this.districtId, required this.userId, required this.userName, required this.userRole, required this.action, required this.targetType, required this.targetId, this.targetName, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) required this.timestamp, final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);

@override final  String id;
@override final  String districtId;
@override final  String userId;
@override final  String userName;
@override final  String userRole;
@override final  AuditAction action;
@override final  TargetType targetType;
@override final  String targetId;
@override final  String? targetName;
@override@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) final  DateTime timestamp;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogCopyWith<_AuditLog> get copyWith => __$AuditLogCopyWithImpl<_AuditLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLog&&(identical(other.id, id) || other.id == id)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.action, action) || other.action == action)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.targetName, targetName) || other.targetName == targetName)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,districtId,userId,userName,userRole,action,targetType,targetId,targetName,timestamp,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'AuditLog(id: $id, districtId: $districtId, userId: $userId, userName: $userName, userRole: $userRole, action: $action, targetType: $targetType, targetId: $targetId, targetName: $targetName, timestamp: $timestamp, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$AuditLogCopyWith<$Res> implements $AuditLogCopyWith<$Res> {
  factory _$AuditLogCopyWith(_AuditLog value, $Res Function(_AuditLog) _then) = __$AuditLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String districtId, String userId, String userName, String userRole, AuditAction action, TargetType targetType, String targetId, String? targetName,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime timestamp, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$AuditLogCopyWithImpl<$Res>
    implements _$AuditLogCopyWith<$Res> {
  __$AuditLogCopyWithImpl(this._self, this._then);

  final _AuditLog _self;
  final $Res Function(_AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? districtId = null,Object? userId = null,Object? userName = null,Object? userRole = null,Object? action = null,Object? targetType = null,Object? targetId = null,Object? targetName = freezed,Object? timestamp = null,Object? metadata = freezed,}) {
  return _then(_AuditLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,districtId: null == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userRole: null == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as TargetType,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,targetName: freezed == targetName ? _self.targetName : targetName // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
