// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadRecord {

 int get bookId; String get title; List<String> get authors; DownloadStatus get status; double get progress; int get totalBytes; String? get error;
/// Create a copy of DownloadRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadRecordCopyWith<DownloadRecord> get copyWith => _$DownloadRecordCopyWithImpl<DownloadRecord>(this as DownloadRecord, _$identity);

  /// Serializes this DownloadRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadRecord&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.authors, authors)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,title,const DeepCollectionEquality().hash(authors),status,progress,totalBytes,error);

@override
String toString() {
  return 'DownloadRecord(bookId: $bookId, title: $title, authors: $authors, status: $status, progress: $progress, totalBytes: $totalBytes, error: $error)';
}


}

/// @nodoc
abstract mixin class $DownloadRecordCopyWith<$Res>  {
  factory $DownloadRecordCopyWith(DownloadRecord value, $Res Function(DownloadRecord) _then) = _$DownloadRecordCopyWithImpl;
@useResult
$Res call({
 int bookId, String title, List<String> authors, DownloadStatus status, double progress, int totalBytes, String? error
});




}
/// @nodoc
class _$DownloadRecordCopyWithImpl<$Res>
    implements $DownloadRecordCopyWith<$Res> {
  _$DownloadRecordCopyWithImpl(this._self, this._then);

  final DownloadRecord _self;
  final $Res Function(DownloadRecord) _then;

/// Create a copy of DownloadRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? title = null,Object? authors = null,Object? status = null,Object? progress = null,Object? totalBytes = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadRecord].
extension DownloadRecordPatterns on DownloadRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadRecord value)  $default,){
final _that = this;
switch (_that) {
case _DownloadRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadRecord value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookId,  String title,  List<String> authors,  DownloadStatus status,  double progress,  int totalBytes,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadRecord() when $default != null:
return $default(_that.bookId,_that.title,_that.authors,_that.status,_that.progress,_that.totalBytes,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookId,  String title,  List<String> authors,  DownloadStatus status,  double progress,  int totalBytes,  String? error)  $default,) {final _that = this;
switch (_that) {
case _DownloadRecord():
return $default(_that.bookId,_that.title,_that.authors,_that.status,_that.progress,_that.totalBytes,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookId,  String title,  List<String> authors,  DownloadStatus status,  double progress,  int totalBytes,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _DownloadRecord() when $default != null:
return $default(_that.bookId,_that.title,_that.authors,_that.status,_that.progress,_that.totalBytes,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DownloadRecord implements DownloadRecord {
  const _DownloadRecord({required this.bookId, required this.title, final  List<String> authors = const [], required this.status, this.progress = 0.0, this.totalBytes = 0, this.error}): _authors = authors;
  factory _DownloadRecord.fromJson(Map<String, dynamic> json) => _$DownloadRecordFromJson(json);

@override final  int bookId;
@override final  String title;
 final  List<String> _authors;
@override@JsonKey() List<String> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

@override final  DownloadStatus status;
@override@JsonKey() final  double progress;
@override@JsonKey() final  int totalBytes;
@override final  String? error;

/// Create a copy of DownloadRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadRecordCopyWith<_DownloadRecord> get copyWith => __$DownloadRecordCopyWithImpl<_DownloadRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DownloadRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadRecord&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._authors, _authors)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,title,const DeepCollectionEquality().hash(_authors),status,progress,totalBytes,error);

@override
String toString() {
  return 'DownloadRecord(bookId: $bookId, title: $title, authors: $authors, status: $status, progress: $progress, totalBytes: $totalBytes, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DownloadRecordCopyWith<$Res> implements $DownloadRecordCopyWith<$Res> {
  factory _$DownloadRecordCopyWith(_DownloadRecord value, $Res Function(_DownloadRecord) _then) = __$DownloadRecordCopyWithImpl;
@override @useResult
$Res call({
 int bookId, String title, List<String> authors, DownloadStatus status, double progress, int totalBytes, String? error
});




}
/// @nodoc
class __$DownloadRecordCopyWithImpl<$Res>
    implements _$DownloadRecordCopyWith<$Res> {
  __$DownloadRecordCopyWithImpl(this._self, this._then);

  final _DownloadRecord _self;
  final $Res Function(_DownloadRecord) _then;

/// Create a copy of DownloadRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? title = null,Object? authors = null,Object? status = null,Object? progress = null,Object? totalBytes = null,Object? error = freezed,}) {
  return _then(_DownloadRecord(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
