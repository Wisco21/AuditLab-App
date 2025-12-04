// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Issue {

 String get id; IssueType get type; String get description; String get createdBy;@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime get createdAt; String get status; String? get resolvedBy;@JsonKey(fromJson: nullableTimestampFromJson, toJson: nullableTimestampToJson) DateTime? get resolvedAt; String? get resolutionNotes;
/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueCopyWith<Issue> get copyWith => _$IssueCopyWithImpl<Issue>(this as Issue, _$identity);

  /// Serializes this Issue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Issue&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,description,createdBy,createdAt,status,resolvedBy,resolvedAt,resolutionNotes);

@override
String toString() {
  return 'Issue(id: $id, type: $type, description: $description, createdBy: $createdBy, createdAt: $createdAt, status: $status, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, resolutionNotes: $resolutionNotes)';
}


}

/// @nodoc
abstract mixin class $IssueCopyWith<$Res>  {
  factory $IssueCopyWith(Issue value, $Res Function(Issue) _then) = _$IssueCopyWithImpl;
@useResult
$Res call({
 String id, IssueType type, String description, String createdBy,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime createdAt, String status, String? resolvedBy,@JsonKey(fromJson: nullableTimestampFromJson, toJson: nullableTimestampToJson) DateTime? resolvedAt, String? resolutionNotes
});




}
/// @nodoc
class _$IssueCopyWithImpl<$Res>
    implements $IssueCopyWith<$Res> {
  _$IssueCopyWithImpl(this._self, this._then);

  final Issue _self;
  final $Res Function(Issue) _then;

/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? description = null,Object? createdBy = null,Object? createdAt = null,Object? status = null,Object? resolvedBy = freezed,Object? resolvedAt = freezed,Object? resolutionNotes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IssueType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Issue].
extension IssuePatterns on Issue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Issue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Issue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Issue value)  $default,){
final _that = this;
switch (_that) {
case _Issue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Issue value)?  $default,){
final _that = this;
switch (_that) {
case _Issue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  IssueType type,  String description,  String createdBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt,  String status,  String? resolvedBy, @JsonKey(fromJson: nullableTimestampFromJson, toJson: nullableTimestampToJson)  DateTime? resolvedAt,  String? resolutionNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Issue() when $default != null:
return $default(_that.id,_that.type,_that.description,_that.createdBy,_that.createdAt,_that.status,_that.resolvedBy,_that.resolvedAt,_that.resolutionNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  IssueType type,  String description,  String createdBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt,  String status,  String? resolvedBy, @JsonKey(fromJson: nullableTimestampFromJson, toJson: nullableTimestampToJson)  DateTime? resolvedAt,  String? resolutionNotes)  $default,) {final _that = this;
switch (_that) {
case _Issue():
return $default(_that.id,_that.type,_that.description,_that.createdBy,_that.createdAt,_that.status,_that.resolvedBy,_that.resolvedAt,_that.resolutionNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  IssueType type,  String description,  String createdBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt,  String status,  String? resolvedBy, @JsonKey(fromJson: nullableTimestampFromJson, toJson: nullableTimestampToJson)  DateTime? resolvedAt,  String? resolutionNotes)?  $default,) {final _that = this;
switch (_that) {
case _Issue() when $default != null:
return $default(_that.id,_that.type,_that.description,_that.createdBy,_that.createdAt,_that.status,_that.resolvedBy,_that.resolvedAt,_that.resolutionNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Issue implements Issue {
  const _Issue({required this.id, required this.type, required this.description, required this.createdBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) required this.createdAt, this.status = 'Open', this.resolvedBy, @JsonKey(fromJson: nullableTimestampFromJson, toJson: nullableTimestampToJson) this.resolvedAt, this.resolutionNotes});
  factory _Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);

@override final  String id;
@override final  IssueType type;
@override final  String description;
@override final  String createdBy;
@override@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) final  DateTime createdAt;
@override@JsonKey() final  String status;
@override final  String? resolvedBy;
@override@JsonKey(fromJson: nullableTimestampFromJson, toJson: nullableTimestampToJson) final  DateTime? resolvedAt;
@override final  String? resolutionNotes;

/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueCopyWith<_Issue> get copyWith => __$IssueCopyWithImpl<_Issue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Issue&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,description,createdBy,createdAt,status,resolvedBy,resolvedAt,resolutionNotes);

@override
String toString() {
  return 'Issue(id: $id, type: $type, description: $description, createdBy: $createdBy, createdAt: $createdAt, status: $status, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, resolutionNotes: $resolutionNotes)';
}


}

/// @nodoc
abstract mixin class _$IssueCopyWith<$Res> implements $IssueCopyWith<$Res> {
  factory _$IssueCopyWith(_Issue value, $Res Function(_Issue) _then) = __$IssueCopyWithImpl;
@override @useResult
$Res call({
 String id, IssueType type, String description, String createdBy,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime createdAt, String status, String? resolvedBy,@JsonKey(fromJson: nullableTimestampFromJson, toJson: nullableTimestampToJson) DateTime? resolvedAt, String? resolutionNotes
});




}
/// @nodoc
class __$IssueCopyWithImpl<$Res>
    implements _$IssueCopyWith<$Res> {
  __$IssueCopyWithImpl(this._self, this._then);

  final _Issue _self;
  final $Res Function(_Issue) _then;

/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? description = null,Object? createdBy = null,Object? createdAt = null,Object? status = null,Object? resolvedBy = freezed,Object? resolvedAt = freezed,Object? resolutionNotes = freezed,}) {
  return _then(_Issue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IssueType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
