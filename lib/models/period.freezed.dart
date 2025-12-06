// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'period.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Period {

 String get id; String get year; String get range; String get createdBy; String get supervisorId;// @TimestampConverter() required DateTime createdAt,
// @TimestampConverter() required DateTime updatedAt,
@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime get createdAt;@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime get updatedAt; String get status;
/// Create a copy of Period
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodCopyWith<Period> get copyWith => _$PeriodCopyWithImpl<Period>(this as Period, _$identity);

  /// Serializes this Period to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Period&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&(identical(other.range, range) || other.range == range)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.supervisorId, supervisorId) || other.supervisorId == supervisorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,range,createdBy,supervisorId,createdAt,updatedAt,status);

@override
String toString() {
  return 'Period(id: $id, year: $year, range: $range, createdBy: $createdBy, supervisorId: $supervisorId, createdAt: $createdAt, updatedAt: $updatedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $PeriodCopyWith<$Res>  {
  factory $PeriodCopyWith(Period value, $Res Function(Period) _then) = _$PeriodCopyWithImpl;
@useResult
$Res call({
 String id, String year, String range, String createdBy, String supervisorId,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime createdAt,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime updatedAt, String status
});




}
/// @nodoc
class _$PeriodCopyWithImpl<$Res>
    implements $PeriodCopyWith<$Res> {
  _$PeriodCopyWithImpl(this._self, this._then);

  final Period _self;
  final $Res Function(Period) _then;

/// Create a copy of Period
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? year = null,Object? range = null,Object? createdBy = null,Object? supervisorId = null,Object? createdAt = null,Object? updatedAt = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,supervisorId: null == supervisorId ? _self.supervisorId : supervisorId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Period].
extension PeriodPatterns on Period {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Period value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Period() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Period value)  $default,){
final _that = this;
switch (_that) {
case _Period():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Period value)?  $default,){
final _that = this;
switch (_that) {
case _Period() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String year,  String range,  String createdBy,  String supervisorId, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime updatedAt,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Period() when $default != null:
return $default(_that.id,_that.year,_that.range,_that.createdBy,_that.supervisorId,_that.createdAt,_that.updatedAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String year,  String range,  String createdBy,  String supervisorId, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime updatedAt,  String status)  $default,) {final _that = this;
switch (_that) {
case _Period():
return $default(_that.id,_that.year,_that.range,_that.createdBy,_that.supervisorId,_that.createdAt,_that.updatedAt,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String year,  String range,  String createdBy,  String supervisorId, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime updatedAt,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Period() when $default != null:
return $default(_that.id,_that.year,_that.range,_that.createdBy,_that.supervisorId,_that.createdAt,_that.updatedAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Period implements Period {
  const _Period({required this.id, required this.year, required this.range, required this.createdBy, required this.supervisorId, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) required this.createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) required this.updatedAt, this.status = 'Pending'});
  factory _Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);

@override final  String id;
@override final  String year;
@override final  String range;
@override final  String createdBy;
@override final  String supervisorId;
// @TimestampConverter() required DateTime createdAt,
// @TimestampConverter() required DateTime updatedAt,
@override@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) final  DateTime createdAt;
@override@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) final  DateTime updatedAt;
@override@JsonKey() final  String status;

/// Create a copy of Period
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodCopyWith<_Period> get copyWith => __$PeriodCopyWithImpl<_Period>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeriodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Period&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&(identical(other.range, range) || other.range == range)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.supervisorId, supervisorId) || other.supervisorId == supervisorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,range,createdBy,supervisorId,createdAt,updatedAt,status);

@override
String toString() {
  return 'Period(id: $id, year: $year, range: $range, createdBy: $createdBy, supervisorId: $supervisorId, createdAt: $createdAt, updatedAt: $updatedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PeriodCopyWith<$Res> implements $PeriodCopyWith<$Res> {
  factory _$PeriodCopyWith(_Period value, $Res Function(_Period) _then) = __$PeriodCopyWithImpl;
@override @useResult
$Res call({
 String id, String year, String range, String createdBy, String supervisorId,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime createdAt,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime updatedAt, String status
});




}
/// @nodoc
class __$PeriodCopyWithImpl<$Res>
    implements _$PeriodCopyWith<$Res> {
  __$PeriodCopyWithImpl(this._self, this._then);

  final _Period _self;
  final $Res Function(_Period) _then;

/// Create a copy of Period
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? year = null,Object? range = null,Object? createdBy = null,Object? supervisorId = null,Object? createdAt = null,Object? updatedAt = null,Object? status = null,}) {
  return _then(_Period(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,supervisorId: null == supervisorId ? _self.supervisorId : supervisorId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
