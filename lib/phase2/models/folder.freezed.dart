// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'folder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Folder {

 String get id; String get periodId; String get folderNumber; String get chequeRangeStart; String get chequeRangeEnd; String get createdBy;// @TimestampConverter() required DateTime createdAt,
// @TimestampConverter() required DateTime updatedAt,
@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime get createdAt;@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime get updatedAt; String get lastUpdatedBy; String get status; int get totalCheques; int get completedCheques;
/// Create a copy of Folder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FolderCopyWith<Folder> get copyWith => _$FolderCopyWithImpl<Folder>(this as Folder, _$identity);

  /// Serializes this Folder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Folder&&(identical(other.id, id) || other.id == id)&&(identical(other.periodId, periodId) || other.periodId == periodId)&&(identical(other.folderNumber, folderNumber) || other.folderNumber == folderNumber)&&(identical(other.chequeRangeStart, chequeRangeStart) || other.chequeRangeStart == chequeRangeStart)&&(identical(other.chequeRangeEnd, chequeRangeEnd) || other.chequeRangeEnd == chequeRangeEnd)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastUpdatedBy, lastUpdatedBy) || other.lastUpdatedBy == lastUpdatedBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalCheques, totalCheques) || other.totalCheques == totalCheques)&&(identical(other.completedCheques, completedCheques) || other.completedCheques == completedCheques));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodId,folderNumber,chequeRangeStart,chequeRangeEnd,createdBy,createdAt,updatedAt,lastUpdatedBy,status,totalCheques,completedCheques);

@override
String toString() {
  return 'Folder(id: $id, periodId: $periodId, folderNumber: $folderNumber, chequeRangeStart: $chequeRangeStart, chequeRangeEnd: $chequeRangeEnd, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, lastUpdatedBy: $lastUpdatedBy, status: $status, totalCheques: $totalCheques, completedCheques: $completedCheques)';
}


}

/// @nodoc
abstract mixin class $FolderCopyWith<$Res>  {
  factory $FolderCopyWith(Folder value, $Res Function(Folder) _then) = _$FolderCopyWithImpl;
@useResult
$Res call({
 String id, String periodId, String folderNumber, String chequeRangeStart, String chequeRangeEnd, String createdBy,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime createdAt,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime updatedAt, String lastUpdatedBy, String status, int totalCheques, int completedCheques
});




}
/// @nodoc
class _$FolderCopyWithImpl<$Res>
    implements $FolderCopyWith<$Res> {
  _$FolderCopyWithImpl(this._self, this._then);

  final Folder _self;
  final $Res Function(Folder) _then;

/// Create a copy of Folder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? periodId = null,Object? folderNumber = null,Object? chequeRangeStart = null,Object? chequeRangeEnd = null,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,Object? lastUpdatedBy = null,Object? status = null,Object? totalCheques = null,Object? completedCheques = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodId: null == periodId ? _self.periodId : periodId // ignore: cast_nullable_to_non_nullable
as String,folderNumber: null == folderNumber ? _self.folderNumber : folderNumber // ignore: cast_nullable_to_non_nullable
as String,chequeRangeStart: null == chequeRangeStart ? _self.chequeRangeStart : chequeRangeStart // ignore: cast_nullable_to_non_nullable
as String,chequeRangeEnd: null == chequeRangeEnd ? _self.chequeRangeEnd : chequeRangeEnd // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdatedBy: null == lastUpdatedBy ? _self.lastUpdatedBy : lastUpdatedBy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalCheques: null == totalCheques ? _self.totalCheques : totalCheques // ignore: cast_nullable_to_non_nullable
as int,completedCheques: null == completedCheques ? _self.completedCheques : completedCheques // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Folder].
extension FolderPatterns on Folder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Folder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Folder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Folder value)  $default,){
final _that = this;
switch (_that) {
case _Folder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Folder value)?  $default,){
final _that = this;
switch (_that) {
case _Folder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String periodId,  String folderNumber,  String chequeRangeStart,  String chequeRangeEnd,  String createdBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime updatedAt,  String lastUpdatedBy,  String status,  int totalCheques,  int completedCheques)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Folder() when $default != null:
return $default(_that.id,_that.periodId,_that.folderNumber,_that.chequeRangeStart,_that.chequeRangeEnd,_that.createdBy,_that.createdAt,_that.updatedAt,_that.lastUpdatedBy,_that.status,_that.totalCheques,_that.completedCheques);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String periodId,  String folderNumber,  String chequeRangeStart,  String chequeRangeEnd,  String createdBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime updatedAt,  String lastUpdatedBy,  String status,  int totalCheques,  int completedCheques)  $default,) {final _that = this;
switch (_that) {
case _Folder():
return $default(_that.id,_that.periodId,_that.folderNumber,_that.chequeRangeStart,_that.chequeRangeEnd,_that.createdBy,_that.createdAt,_that.updatedAt,_that.lastUpdatedBy,_that.status,_that.totalCheques,_that.completedCheques);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String periodId,  String folderNumber,  String chequeRangeStart,  String chequeRangeEnd,  String createdBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime updatedAt,  String lastUpdatedBy,  String status,  int totalCheques,  int completedCheques)?  $default,) {final _that = this;
switch (_that) {
case _Folder() when $default != null:
return $default(_that.id,_that.periodId,_that.folderNumber,_that.chequeRangeStart,_that.chequeRangeEnd,_that.createdBy,_that.createdAt,_that.updatedAt,_that.lastUpdatedBy,_that.status,_that.totalCheques,_that.completedCheques);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Folder implements Folder {
  const _Folder({required this.id, required this.periodId, required this.folderNumber, required this.chequeRangeStart, required this.chequeRangeEnd, required this.createdBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) required this.createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) required this.updatedAt, required this.lastUpdatedBy, this.status = 'Pending', this.totalCheques = 0, this.completedCheques = 0});
  factory _Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);

@override final  String id;
@override final  String periodId;
@override final  String folderNumber;
@override final  String chequeRangeStart;
@override final  String chequeRangeEnd;
@override final  String createdBy;
// @TimestampConverter() required DateTime createdAt,
// @TimestampConverter() required DateTime updatedAt,
@override@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) final  DateTime createdAt;
@override@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) final  DateTime updatedAt;
@override final  String lastUpdatedBy;
@override@JsonKey() final  String status;
@override@JsonKey() final  int totalCheques;
@override@JsonKey() final  int completedCheques;

/// Create a copy of Folder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FolderCopyWith<_Folder> get copyWith => __$FolderCopyWithImpl<_Folder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FolderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Folder&&(identical(other.id, id) || other.id == id)&&(identical(other.periodId, periodId) || other.periodId == periodId)&&(identical(other.folderNumber, folderNumber) || other.folderNumber == folderNumber)&&(identical(other.chequeRangeStart, chequeRangeStart) || other.chequeRangeStart == chequeRangeStart)&&(identical(other.chequeRangeEnd, chequeRangeEnd) || other.chequeRangeEnd == chequeRangeEnd)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastUpdatedBy, lastUpdatedBy) || other.lastUpdatedBy == lastUpdatedBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalCheques, totalCheques) || other.totalCheques == totalCheques)&&(identical(other.completedCheques, completedCheques) || other.completedCheques == completedCheques));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodId,folderNumber,chequeRangeStart,chequeRangeEnd,createdBy,createdAt,updatedAt,lastUpdatedBy,status,totalCheques,completedCheques);

@override
String toString() {
  return 'Folder(id: $id, periodId: $periodId, folderNumber: $folderNumber, chequeRangeStart: $chequeRangeStart, chequeRangeEnd: $chequeRangeEnd, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, lastUpdatedBy: $lastUpdatedBy, status: $status, totalCheques: $totalCheques, completedCheques: $completedCheques)';
}


}

/// @nodoc
abstract mixin class _$FolderCopyWith<$Res> implements $FolderCopyWith<$Res> {
  factory _$FolderCopyWith(_Folder value, $Res Function(_Folder) _then) = __$FolderCopyWithImpl;
@override @useResult
$Res call({
 String id, String periodId, String folderNumber, String chequeRangeStart, String chequeRangeEnd, String createdBy,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime createdAt,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime updatedAt, String lastUpdatedBy, String status, int totalCheques, int completedCheques
});




}
/// @nodoc
class __$FolderCopyWithImpl<$Res>
    implements _$FolderCopyWith<$Res> {
  __$FolderCopyWithImpl(this._self, this._then);

  final _Folder _self;
  final $Res Function(_Folder) _then;

/// Create a copy of Folder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? periodId = null,Object? folderNumber = null,Object? chequeRangeStart = null,Object? chequeRangeEnd = null,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,Object? lastUpdatedBy = null,Object? status = null,Object? totalCheques = null,Object? completedCheques = null,}) {
  return _then(_Folder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodId: null == periodId ? _self.periodId : periodId // ignore: cast_nullable_to_non_nullable
as String,folderNumber: null == folderNumber ? _self.folderNumber : folderNumber // ignore: cast_nullable_to_non_nullable
as String,chequeRangeStart: null == chequeRangeStart ? _self.chequeRangeStart : chequeRangeStart // ignore: cast_nullable_to_non_nullable
as String,chequeRangeEnd: null == chequeRangeEnd ? _self.chequeRangeEnd : chequeRangeEnd // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUpdatedBy: null == lastUpdatedBy ? _self.lastUpdatedBy : lastUpdatedBy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalCheques: null == totalCheques ? _self.totalCheques : totalCheques // ignore: cast_nullable_to_non_nullable
as int,completedCheques: null == completedCheques ? _self.completedCheques : completedCheques // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
