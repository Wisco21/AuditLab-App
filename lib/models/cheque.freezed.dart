// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cheque.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Cheque {

 String get id; String get folderId; String get periodId; String get chequeNumber; String get sectorCode; String? get assignedTo; String get lastUpdatedBy;@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime get createdAt;@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime get updatedAt; String get status; List<Issue> get issues; String? get payee; double? get amount; String? get description;
/// Create a copy of Cheque
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChequeCopyWith<Cheque> get copyWith => _$ChequeCopyWithImpl<Cheque>(this as Cheque, _$identity);

  /// Serializes this Cheque to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cheque&&(identical(other.id, id) || other.id == id)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.periodId, periodId) || other.periodId == periodId)&&(identical(other.chequeNumber, chequeNumber) || other.chequeNumber == chequeNumber)&&(identical(other.sectorCode, sectorCode) || other.sectorCode == sectorCode)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.lastUpdatedBy, lastUpdatedBy) || other.lastUpdatedBy == lastUpdatedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.issues, issues)&&(identical(other.payee, payee) || other.payee == payee)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,folderId,periodId,chequeNumber,sectorCode,assignedTo,lastUpdatedBy,createdAt,updatedAt,status,const DeepCollectionEquality().hash(issues),payee,amount,description);

@override
String toString() {
  return 'Cheque(id: $id, folderId: $folderId, periodId: $periodId, chequeNumber: $chequeNumber, sectorCode: $sectorCode, assignedTo: $assignedTo, lastUpdatedBy: $lastUpdatedBy, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, issues: $issues, payee: $payee, amount: $amount, description: $description)';
}


}

/// @nodoc
abstract mixin class $ChequeCopyWith<$Res>  {
  factory $ChequeCopyWith(Cheque value, $Res Function(Cheque) _then) = _$ChequeCopyWithImpl;
@useResult
$Res call({
 String id, String folderId, String periodId, String chequeNumber, String sectorCode, String? assignedTo, String lastUpdatedBy,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime createdAt,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime updatedAt, String status, List<Issue> issues, String? payee, double? amount, String? description
});




}
/// @nodoc
class _$ChequeCopyWithImpl<$Res>
    implements $ChequeCopyWith<$Res> {
  _$ChequeCopyWithImpl(this._self, this._then);

  final Cheque _self;
  final $Res Function(Cheque) _then;

/// Create a copy of Cheque
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? folderId = null,Object? periodId = null,Object? chequeNumber = null,Object? sectorCode = null,Object? assignedTo = freezed,Object? lastUpdatedBy = null,Object? createdAt = null,Object? updatedAt = null,Object? status = null,Object? issues = null,Object? payee = freezed,Object? amount = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,folderId: null == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String,periodId: null == periodId ? _self.periodId : periodId // ignore: cast_nullable_to_non_nullable
as String,chequeNumber: null == chequeNumber ? _self.chequeNumber : chequeNumber // ignore: cast_nullable_to_non_nullable
as String,sectorCode: null == sectorCode ? _self.sectorCode : sectorCode // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,lastUpdatedBy: null == lastUpdatedBy ? _self.lastUpdatedBy : lastUpdatedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,issues: null == issues ? _self.issues : issues // ignore: cast_nullable_to_non_nullable
as List<Issue>,payee: freezed == payee ? _self.payee : payee // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Cheque].
extension ChequePatterns on Cheque {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cheque value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cheque() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cheque value)  $default,){
final _that = this;
switch (_that) {
case _Cheque():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cheque value)?  $default,){
final _that = this;
switch (_that) {
case _Cheque() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String folderId,  String periodId,  String chequeNumber,  String sectorCode,  String? assignedTo,  String lastUpdatedBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime updatedAt,  String status,  List<Issue> issues,  String? payee,  double? amount,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cheque() when $default != null:
return $default(_that.id,_that.folderId,_that.periodId,_that.chequeNumber,_that.sectorCode,_that.assignedTo,_that.lastUpdatedBy,_that.createdAt,_that.updatedAt,_that.status,_that.issues,_that.payee,_that.amount,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String folderId,  String periodId,  String chequeNumber,  String sectorCode,  String? assignedTo,  String lastUpdatedBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime updatedAt,  String status,  List<Issue> issues,  String? payee,  double? amount,  String? description)  $default,) {final _that = this;
switch (_that) {
case _Cheque():
return $default(_that.id,_that.folderId,_that.periodId,_that.chequeNumber,_that.sectorCode,_that.assignedTo,_that.lastUpdatedBy,_that.createdAt,_that.updatedAt,_that.status,_that.issues,_that.payee,_that.amount,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String folderId,  String periodId,  String chequeNumber,  String sectorCode,  String? assignedTo,  String lastUpdatedBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)  DateTime updatedAt,  String status,  List<Issue> issues,  String? payee,  double? amount,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _Cheque() when $default != null:
return $default(_that.id,_that.folderId,_that.periodId,_that.chequeNumber,_that.sectorCode,_that.assignedTo,_that.lastUpdatedBy,_that.createdAt,_that.updatedAt,_that.status,_that.issues,_that.payee,_that.amount,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Cheque implements Cheque {
  const _Cheque({required this.id, required this.folderId, required this.periodId, required this.chequeNumber, required this.sectorCode, this.assignedTo, required this.lastUpdatedBy, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) required this.createdAt, @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) required this.updatedAt, this.status = 'Pending', final  List<Issue> issues = const [], this.payee, this.amount, this.description}): _issues = issues;
  factory _Cheque.fromJson(Map<String, dynamic> json) => _$ChequeFromJson(json);

@override final  String id;
@override final  String folderId;
@override final  String periodId;
@override final  String chequeNumber;
@override final  String sectorCode;
@override final  String? assignedTo;
@override final  String lastUpdatedBy;
@override@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) final  DateTime createdAt;
@override@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) final  DateTime updatedAt;
@override@JsonKey() final  String status;
 final  List<Issue> _issues;
@override@JsonKey() List<Issue> get issues {
  if (_issues is EqualUnmodifiableListView) return _issues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issues);
}

@override final  String? payee;
@override final  double? amount;
@override final  String? description;

/// Create a copy of Cheque
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChequeCopyWith<_Cheque> get copyWith => __$ChequeCopyWithImpl<_Cheque>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChequeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cheque&&(identical(other.id, id) || other.id == id)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.periodId, periodId) || other.periodId == periodId)&&(identical(other.chequeNumber, chequeNumber) || other.chequeNumber == chequeNumber)&&(identical(other.sectorCode, sectorCode) || other.sectorCode == sectorCode)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.lastUpdatedBy, lastUpdatedBy) || other.lastUpdatedBy == lastUpdatedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._issues, _issues)&&(identical(other.payee, payee) || other.payee == payee)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,folderId,periodId,chequeNumber,sectorCode,assignedTo,lastUpdatedBy,createdAt,updatedAt,status,const DeepCollectionEquality().hash(_issues),payee,amount,description);

@override
String toString() {
  return 'Cheque(id: $id, folderId: $folderId, periodId: $periodId, chequeNumber: $chequeNumber, sectorCode: $sectorCode, assignedTo: $assignedTo, lastUpdatedBy: $lastUpdatedBy, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, issues: $issues, payee: $payee, amount: $amount, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ChequeCopyWith<$Res> implements $ChequeCopyWith<$Res> {
  factory _$ChequeCopyWith(_Cheque value, $Res Function(_Cheque) _then) = __$ChequeCopyWithImpl;
@override @useResult
$Res call({
 String id, String folderId, String periodId, String chequeNumber, String sectorCode, String? assignedTo, String lastUpdatedBy,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime createdAt,@JsonKey(fromJson: timestampFromJson, toJson: timestampToJson) DateTime updatedAt, String status, List<Issue> issues, String? payee, double? amount, String? description
});




}
/// @nodoc
class __$ChequeCopyWithImpl<$Res>
    implements _$ChequeCopyWith<$Res> {
  __$ChequeCopyWithImpl(this._self, this._then);

  final _Cheque _self;
  final $Res Function(_Cheque) _then;

/// Create a copy of Cheque
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? folderId = null,Object? periodId = null,Object? chequeNumber = null,Object? sectorCode = null,Object? assignedTo = freezed,Object? lastUpdatedBy = null,Object? createdAt = null,Object? updatedAt = null,Object? status = null,Object? issues = null,Object? payee = freezed,Object? amount = freezed,Object? description = freezed,}) {
  return _then(_Cheque(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,folderId: null == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String,periodId: null == periodId ? _self.periodId : periodId // ignore: cast_nullable_to_non_nullable
as String,chequeNumber: null == chequeNumber ? _self.chequeNumber : chequeNumber // ignore: cast_nullable_to_non_nullable
as String,sectorCode: null == sectorCode ? _self.sectorCode : sectorCode // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,lastUpdatedBy: null == lastUpdatedBy ? _self.lastUpdatedBy : lastUpdatedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,issues: null == issues ? _self._issues : issues // ignore: cast_nullable_to_non_nullable
as List<Issue>,payee: freezed == payee ? _self.payee : payee // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
