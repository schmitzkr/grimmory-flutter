// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthTokens {

 String get accessToken; String get refreshToken; int? get expires;
/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthTokensCopyWith<AuthTokens> get copyWith => _$AuthTokensCopyWithImpl<AuthTokens>(this as AuthTokens, _$identity);

  /// Serializes this AuthTokens to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthTokens;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthTokens&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.expires, _this.expires) || other.expires == _this.expires));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthTokens;
  return Object.hash(runtimeType,_this.accessToken,_this.refreshToken,_this.expires);
}

@override
String toString() {
  final _this = this as AuthTokens;
  return 'AuthTokens(accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken}, expires: ${_this.expires})';
}


}

/// @nodoc
abstract mixin class $AuthTokensCopyWith<$Res>  {
  factory $AuthTokensCopyWith(AuthTokens value, $Res Function(AuthTokens) _then) = _$AuthTokensCopyWithImpl;
@useResult
$Res call({
 String accessToken, String refreshToken, int? expires
});




}
/// @nodoc
class _$AuthTokensCopyWithImpl<$Res>
    implements $AuthTokensCopyWith<$Res> {
  _$AuthTokensCopyWithImpl(this._self, this._then);

  final AuthTokens _self;
  final $Res Function(AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expires = freezed,}) {
  return _then(AuthTokens(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expires: freezed == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthTokens].
extension AuthTokensPatterns on AuthTokens {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthTokens value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthTokens value)  $default,){
final _that = this;
switch (_that) {
case _AuthTokens():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthTokens value)?  $default,){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  int? expires)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expires);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  int? expires)  $default,) {final _that = this;
switch (_that) {
case _AuthTokens():
return $default(_that.accessToken,_that.refreshToken,_that.expires);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  String refreshToken,  int? expires)?  $default,) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expires);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthTokens implements AuthTokens {
  const _AuthTokens({required this.accessToken, required this.refreshToken, this.expires});
  factory _AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);

@override final  String accessToken;
@override final  String refreshToken;
@override final  int? expires;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthTokensCopyWith<_AuthTokens> get copyWith => __$AuthTokensCopyWithImpl<_AuthTokens>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthTokensToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthTokens&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expires, expires) || other.expires == expires));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accessToken,refreshToken,expires);
}

@override
String toString() {
    return 'AuthTokens(accessToken: $accessToken, refreshToken: $refreshToken, expires: $expires)';
}


}

/// @nodoc
abstract mixin class _$AuthTokensCopyWith<$Res> implements $AuthTokensCopyWith<$Res> {
  factory _$AuthTokensCopyWith(_AuthTokens value, $Res Function(_AuthTokens) _then) = __$AuthTokensCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, String refreshToken, int? expires
});




}
/// @nodoc
class __$AuthTokensCopyWithImpl<$Res>
    implements _$AuthTokensCopyWith<$Res> {
  __$AuthTokensCopyWithImpl(this._self, this._then);

  final _AuthTokens _self;
  final $Res Function(_AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expires = freezed,}) {
  return _then(_AuthTokens(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expires: freezed == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Library {

 int get id; String get name; String? get icon; int get bookCount;
/// Create a copy of Library
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryCopyWith<Library> get copyWith => _$LibraryCopyWithImpl<Library>(this as Library, _$identity);

  /// Serializes this Library to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Library;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Library&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.bookCount, _this.bookCount) || other.bookCount == _this.bookCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Library;
  return Object.hash(runtimeType,_this.id,_this.name,_this.icon,_this.bookCount);
}

@override
String toString() {
  final _this = this as Library;
  return 'Library(id: ${_this.id}, name: ${_this.name}, icon: ${_this.icon}, bookCount: ${_this.bookCount})';
}


}

/// @nodoc
abstract mixin class $LibraryCopyWith<$Res>  {
  factory $LibraryCopyWith(Library value, $Res Function(Library) _then) = _$LibraryCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? icon, int bookCount
});




}
/// @nodoc
class _$LibraryCopyWithImpl<$Res>
    implements $LibraryCopyWith<$Res> {
  _$LibraryCopyWithImpl(this._self, this._then);

  final Library _self;
  final $Res Function(Library) _then;

/// Create a copy of Library
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? bookCount = null,}) {
  return _then(Library(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Library].
extension LibraryPatterns on Library {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Library value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Library() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Library value)  $default,){
final _that = this;
switch (_that) {
case _Library():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Library value)?  $default,){
final _that = this;
switch (_that) {
case _Library() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? icon,  int bookCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Library() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.bookCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? icon,  int bookCount)  $default,) {final _that = this;
switch (_that) {
case _Library():
return $default(_that.id,_that.name,_that.icon,_that.bookCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? icon,  int bookCount)?  $default,) {final _that = this;
switch (_that) {
case _Library() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.bookCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Library implements Library {
  const _Library({required this.id, required this.name, this.icon, this.bookCount = 0});
  factory _Library.fromJson(Map<String, dynamic> json) => _$LibraryFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? icon;
@override@JsonKey() final  int bookCount;

/// Create a copy of Library
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LibraryCopyWith<_Library> get copyWith => __$LibraryCopyWithImpl<_Library>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LibraryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Library&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.bookCount, bookCount) || other.bookCount == bookCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,icon,bookCount);
}

@override
String toString() {
    return 'Library(id: $id, name: $name, icon: $icon, bookCount: $bookCount)';
}


}

/// @nodoc
abstract mixin class _$LibraryCopyWith<$Res> implements $LibraryCopyWith<$Res> {
  factory _$LibraryCopyWith(_Library value, $Res Function(_Library) _then) = __$LibraryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? icon, int bookCount
});




}
/// @nodoc
class __$LibraryCopyWithImpl<$Res>
    implements _$LibraryCopyWith<$Res> {
  __$LibraryCopyWithImpl(this._self, this._then);

  final _Library _self;
  final $Res Function(_Library) _then;

/// Create a copy of Library
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? bookCount = null,}) {
  return _then(_Library(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Book {

 int get id; String get title; String? get thumbnailUrl; DateTime? get coverUpdatedOn; DateTime? get audiobookCoverUpdatedOn; int? get primaryFileId; List<String> get authors; String? get seriesName; double? get seriesNumber; int? get libraryId; String? get narrator; String? get description; String? get primaryFileType; double? get readProgress; String? get readStatus; DateTime? get addedOn; DateTime? get lastReadTime; List<BookFile> get files;
/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookCopyWith<Book> get copyWith => _$BookCopyWithImpl<Book>(this as Book, _$identity);

  /// Serializes this Book to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Book;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Book&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.thumbnailUrl, _this.thumbnailUrl) || other.thumbnailUrl == _this.thumbnailUrl)&&(identical(other.coverUpdatedOn, _this.coverUpdatedOn) || other.coverUpdatedOn == _this.coverUpdatedOn)&&(identical(other.audiobookCoverUpdatedOn, _this.audiobookCoverUpdatedOn) || other.audiobookCoverUpdatedOn == _this.audiobookCoverUpdatedOn)&&(identical(other.primaryFileId, _this.primaryFileId) || other.primaryFileId == _this.primaryFileId)&&const DeepCollectionEquality().equals(other.authors, _this.authors)&&(identical(other.seriesName, _this.seriesName) || other.seriesName == _this.seriesName)&&(identical(other.seriesNumber, _this.seriesNumber) || other.seriesNumber == _this.seriesNumber)&&(identical(other.libraryId, _this.libraryId) || other.libraryId == _this.libraryId)&&(identical(other.narrator, _this.narrator) || other.narrator == _this.narrator)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.primaryFileType, _this.primaryFileType) || other.primaryFileType == _this.primaryFileType)&&(identical(other.readProgress, _this.readProgress) || other.readProgress == _this.readProgress)&&(identical(other.readStatus, _this.readStatus) || other.readStatus == _this.readStatus)&&(identical(other.addedOn, _this.addedOn) || other.addedOn == _this.addedOn)&&(identical(other.lastReadTime, _this.lastReadTime) || other.lastReadTime == _this.lastReadTime)&&const DeepCollectionEquality().equals(other.files, _this.files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Book;
  return Object.hash(runtimeType,_this.id,_this.title,_this.thumbnailUrl,_this.coverUpdatedOn,_this.audiobookCoverUpdatedOn,_this.primaryFileId,const DeepCollectionEquality().hash(_this.authors),_this.seriesName,_this.seriesNumber,_this.libraryId,_this.narrator,_this.description,_this.primaryFileType,_this.readProgress,_this.readStatus,_this.addedOn,_this.lastReadTime,const DeepCollectionEquality().hash(_this.files));
}

@override
String toString() {
  final _this = this as Book;
  return 'Book(id: ${_this.id}, title: ${_this.title}, thumbnailUrl: ${_this.thumbnailUrl}, coverUpdatedOn: ${_this.coverUpdatedOn}, audiobookCoverUpdatedOn: ${_this.audiobookCoverUpdatedOn}, primaryFileId: ${_this.primaryFileId}, authors: ${_this.authors}, seriesName: ${_this.seriesName}, seriesNumber: ${_this.seriesNumber}, libraryId: ${_this.libraryId}, narrator: ${_this.narrator}, description: ${_this.description}, primaryFileType: ${_this.primaryFileType}, readProgress: ${_this.readProgress}, readStatus: ${_this.readStatus}, addedOn: ${_this.addedOn}, lastReadTime: ${_this.lastReadTime}, files: ${_this.files})';
}


}

/// @nodoc
abstract mixin class $BookCopyWith<$Res>  {
  factory $BookCopyWith(Book value, $Res Function(Book) _then) = _$BookCopyWithImpl;
@useResult
$Res call({
 int id, String title, String? thumbnailUrl, DateTime? coverUpdatedOn, DateTime? audiobookCoverUpdatedOn, int? primaryFileId, List<String> authors, String? seriesName, double? seriesNumber, int? libraryId, String? narrator, String? description, String? primaryFileType, double? readProgress, String? readStatus, DateTime? addedOn, DateTime? lastReadTime, List<BookFile> files
});




}
/// @nodoc
class _$BookCopyWithImpl<$Res>
    implements $BookCopyWith<$Res> {
  _$BookCopyWithImpl(this._self, this._then);

  final Book _self;
  final $Res Function(Book) _then;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? thumbnailUrl = freezed,Object? coverUpdatedOn = freezed,Object? audiobookCoverUpdatedOn = freezed,Object? primaryFileId = freezed,Object? authors = null,Object? seriesName = freezed,Object? seriesNumber = freezed,Object? libraryId = freezed,Object? narrator = freezed,Object? description = freezed,Object? primaryFileType = freezed,Object? readProgress = freezed,Object? readStatus = freezed,Object? addedOn = freezed,Object? lastReadTime = freezed,Object? files = null,}) {
  return _then(Book(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUpdatedOn: freezed == coverUpdatedOn ? _self.coverUpdatedOn : coverUpdatedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,audiobookCoverUpdatedOn: freezed == audiobookCoverUpdatedOn ? _self.audiobookCoverUpdatedOn : audiobookCoverUpdatedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,primaryFileId: freezed == primaryFileId ? _self.primaryFileId : primaryFileId // ignore: cast_nullable_to_non_nullable
as int?,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,seriesNumber: freezed == seriesNumber ? _self.seriesNumber : seriesNumber // ignore: cast_nullable_to_non_nullable
as double?,libraryId: freezed == libraryId ? _self.libraryId : libraryId // ignore: cast_nullable_to_non_nullable
as int?,narrator: freezed == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,primaryFileType: freezed == primaryFileType ? _self.primaryFileType : primaryFileType // ignore: cast_nullable_to_non_nullable
as String?,readProgress: freezed == readProgress ? _self.readProgress : readProgress // ignore: cast_nullable_to_non_nullable
as double?,readStatus: freezed == readStatus ? _self.readStatus : readStatus // ignore: cast_nullable_to_non_nullable
as String?,addedOn: freezed == addedOn ? _self.addedOn : addedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadTime: freezed == lastReadTime ? _self.lastReadTime : lastReadTime // ignore: cast_nullable_to_non_nullable
as DateTime?,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<BookFile>,
  ));
}

}


/// Adds pattern-matching-related methods to [Book].
extension BookPatterns on Book {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Book value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Book() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Book value)  $default,){
final _that = this;
switch (_that) {
case _Book():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Book value)?  $default,){
final _that = this;
switch (_that) {
case _Book() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String? thumbnailUrl,  DateTime? coverUpdatedOn,  DateTime? audiobookCoverUpdatedOn,  int? primaryFileId,  List<String> authors,  String? seriesName,  double? seriesNumber,  int? libraryId,  String? narrator,  String? description,  String? primaryFileType,  double? readProgress,  String? readStatus,  DateTime? addedOn,  DateTime? lastReadTime,  List<BookFile> files)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.thumbnailUrl,_that.coverUpdatedOn,_that.audiobookCoverUpdatedOn,_that.primaryFileId,_that.authors,_that.seriesName,_that.seriesNumber,_that.libraryId,_that.narrator,_that.description,_that.primaryFileType,_that.readProgress,_that.readStatus,_that.addedOn,_that.lastReadTime,_that.files);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String? thumbnailUrl,  DateTime? coverUpdatedOn,  DateTime? audiobookCoverUpdatedOn,  int? primaryFileId,  List<String> authors,  String? seriesName,  double? seriesNumber,  int? libraryId,  String? narrator,  String? description,  String? primaryFileType,  double? readProgress,  String? readStatus,  DateTime? addedOn,  DateTime? lastReadTime,  List<BookFile> files)  $default,) {final _that = this;
switch (_that) {
case _Book():
return $default(_that.id,_that.title,_that.thumbnailUrl,_that.coverUpdatedOn,_that.audiobookCoverUpdatedOn,_that.primaryFileId,_that.authors,_that.seriesName,_that.seriesNumber,_that.libraryId,_that.narrator,_that.description,_that.primaryFileType,_that.readProgress,_that.readStatus,_that.addedOn,_that.lastReadTime,_that.files);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String? thumbnailUrl,  DateTime? coverUpdatedOn,  DateTime? audiobookCoverUpdatedOn,  int? primaryFileId,  List<String> authors,  String? seriesName,  double? seriesNumber,  int? libraryId,  String? narrator,  String? description,  String? primaryFileType,  double? readProgress,  String? readStatus,  DateTime? addedOn,  DateTime? lastReadTime,  List<BookFile> files)?  $default,) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.thumbnailUrl,_that.coverUpdatedOn,_that.audiobookCoverUpdatedOn,_that.primaryFileId,_that.authors,_that.seriesName,_that.seriesNumber,_that.libraryId,_that.narrator,_that.description,_that.primaryFileType,_that.readProgress,_that.readStatus,_that.addedOn,_that.lastReadTime,_that.files);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Book implements Book {
  const _Book({required this.id, required this.title, this.thumbnailUrl, this.coverUpdatedOn, this.audiobookCoverUpdatedOn, this.primaryFileId,  List<String> authors = const [], this.seriesName, this.seriesNumber, this.libraryId, this.narrator, this.description, this.primaryFileType, this.readProgress, this.readStatus, this.addedOn, this.lastReadTime,  List<BookFile> files = const []}): _authors = authors,_files = files;
  factory _Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

@override final  int id;
@override final  String title;
@override final  String? thumbnailUrl;
@override final  DateTime? coverUpdatedOn;
@override final  DateTime? audiobookCoverUpdatedOn;
@override final  int? primaryFileId;
 final  List<String> _authors;
@override@JsonKey() List<String> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

@override final  String? seriesName;
@override final  double? seriesNumber;
@override final  int? libraryId;
@override final  String? narrator;
@override final  String? description;
@override final  String? primaryFileType;
@override final  double? readProgress;
@override final  String? readStatus;
@override final  DateTime? addedOn;
@override final  DateTime? lastReadTime;
 final  List<BookFile> _files;
@override@JsonKey() List<BookFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}


/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookCopyWith<_Book> get copyWith => __$BookCopyWithImpl<_Book>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Book&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.coverUpdatedOn, coverUpdatedOn) || other.coverUpdatedOn == coverUpdatedOn)&&(identical(other.audiobookCoverUpdatedOn, audiobookCoverUpdatedOn) || other.audiobookCoverUpdatedOn == audiobookCoverUpdatedOn)&&(identical(other.primaryFileId, primaryFileId) || other.primaryFileId == primaryFileId)&&const DeepCollectionEquality().equals(other.authors, _authors)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.seriesNumber, seriesNumber) || other.seriesNumber == seriesNumber)&&(identical(other.libraryId, libraryId) || other.libraryId == libraryId)&&(identical(other.narrator, narrator) || other.narrator == narrator)&&(identical(other.description, description) || other.description == description)&&(identical(other.primaryFileType, primaryFileType) || other.primaryFileType == primaryFileType)&&(identical(other.readProgress, readProgress) || other.readProgress == readProgress)&&(identical(other.readStatus, readStatus) || other.readStatus == readStatus)&&(identical(other.addedOn, addedOn) || other.addedOn == addedOn)&&(identical(other.lastReadTime, lastReadTime) || other.lastReadTime == lastReadTime)&&const DeepCollectionEquality().equals(other.files, _files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,thumbnailUrl,coverUpdatedOn,audiobookCoverUpdatedOn,primaryFileId,const DeepCollectionEquality().hash(_authors),seriesName,seriesNumber,libraryId,narrator,description,primaryFileType,readProgress,readStatus,addedOn,lastReadTime,const DeepCollectionEquality().hash(_files));
}

@override
String toString() {
    return 'Book(id: $id, title: $title, thumbnailUrl: $thumbnailUrl, coverUpdatedOn: $coverUpdatedOn, audiobookCoverUpdatedOn: $audiobookCoverUpdatedOn, primaryFileId: $primaryFileId, authors: $authors, seriesName: $seriesName, seriesNumber: $seriesNumber, libraryId: $libraryId, narrator: $narrator, description: $description, primaryFileType: $primaryFileType, readProgress: $readProgress, readStatus: $readStatus, addedOn: $addedOn, lastReadTime: $lastReadTime, files: $files)';
}


}

/// @nodoc
abstract mixin class _$BookCopyWith<$Res> implements $BookCopyWith<$Res> {
  factory _$BookCopyWith(_Book value, $Res Function(_Book) _then) = __$BookCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String? thumbnailUrl, DateTime? coverUpdatedOn, DateTime? audiobookCoverUpdatedOn, int? primaryFileId, List<String> authors, String? seriesName, double? seriesNumber, int? libraryId, String? narrator, String? description, String? primaryFileType, double? readProgress, String? readStatus, DateTime? addedOn, DateTime? lastReadTime, List<BookFile> files
});




}
/// @nodoc
class __$BookCopyWithImpl<$Res>
    implements _$BookCopyWith<$Res> {
  __$BookCopyWithImpl(this._self, this._then);

  final _Book _self;
  final $Res Function(_Book) _then;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? thumbnailUrl = freezed,Object? coverUpdatedOn = freezed,Object? audiobookCoverUpdatedOn = freezed,Object? primaryFileId = freezed,Object? authors = null,Object? seriesName = freezed,Object? seriesNumber = freezed,Object? libraryId = freezed,Object? narrator = freezed,Object? description = freezed,Object? primaryFileType = freezed,Object? readProgress = freezed,Object? readStatus = freezed,Object? addedOn = freezed,Object? lastReadTime = freezed,Object? files = null,}) {
  return _then(_Book(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUpdatedOn: freezed == coverUpdatedOn ? _self.coverUpdatedOn : coverUpdatedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,audiobookCoverUpdatedOn: freezed == audiobookCoverUpdatedOn ? _self.audiobookCoverUpdatedOn : audiobookCoverUpdatedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,primaryFileId: freezed == primaryFileId ? _self.primaryFileId : primaryFileId // ignore: cast_nullable_to_non_nullable
as int?,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,seriesNumber: freezed == seriesNumber ? _self.seriesNumber : seriesNumber // ignore: cast_nullable_to_non_nullable
as double?,libraryId: freezed == libraryId ? _self.libraryId : libraryId // ignore: cast_nullable_to_non_nullable
as int?,narrator: freezed == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,primaryFileType: freezed == primaryFileType ? _self.primaryFileType : primaryFileType // ignore: cast_nullable_to_non_nullable
as String?,readProgress: freezed == readProgress ? _self.readProgress : readProgress // ignore: cast_nullable_to_non_nullable
as double?,readStatus: freezed == readStatus ? _self.readStatus : readStatus // ignore: cast_nullable_to_non_nullable
as String?,addedOn: freezed == addedOn ? _self.addedOn : addedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadTime: freezed == lastReadTime ? _self.lastReadTime : lastReadTime // ignore: cast_nullable_to_non_nullable
as DateTime?,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<BookFile>,
  ));
}


}


/// @nodoc
mixin _$BookFile {

 int get id; String? get bookType;@JsonKey(name: 'primary') bool get isPrimary; bool get folderBased;
/// Create a copy of BookFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookFileCopyWith<BookFile> get copyWith => _$BookFileCopyWithImpl<BookFile>(this as BookFile, _$identity);

  /// Serializes this BookFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookFile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookFile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.bookType, _this.bookType) || other.bookType == _this.bookType)&&(identical(other.isPrimary, _this.isPrimary) || other.isPrimary == _this.isPrimary)&&(identical(other.folderBased, _this.folderBased) || other.folderBased == _this.folderBased));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookFile;
  return Object.hash(runtimeType,_this.id,_this.bookType,_this.isPrimary,_this.folderBased);
}

@override
String toString() {
  final _this = this as BookFile;
  return 'BookFile(id: ${_this.id}, bookType: ${_this.bookType}, isPrimary: ${_this.isPrimary}, folderBased: ${_this.folderBased})';
}


}

/// @nodoc
abstract mixin class $BookFileCopyWith<$Res>  {
  factory $BookFileCopyWith(BookFile value, $Res Function(BookFile) _then) = _$BookFileCopyWithImpl;
@useResult
$Res call({
 int id, String? bookType,@JsonKey(name: 'primary') bool isPrimary, bool folderBased
});




}
/// @nodoc
class _$BookFileCopyWithImpl<$Res>
    implements $BookFileCopyWith<$Res> {
  _$BookFileCopyWithImpl(this._self, this._then);

  final BookFile _self;
  final $Res Function(BookFile) _then;

/// Create a copy of BookFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookType = freezed,Object? isPrimary = null,Object? folderBased = null,}) {
  return _then(BookFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookType: freezed == bookType ? _self.bookType : bookType // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,folderBased: null == folderBased ? _self.folderBased : folderBased // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BookFile].
extension BookFilePatterns on BookFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookFile value)  $default,){
final _that = this;
switch (_that) {
case _BookFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookFile value)?  $default,){
final _that = this;
switch (_that) {
case _BookFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? bookType, @JsonKey(name: 'primary')  bool isPrimary,  bool folderBased)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookFile() when $default != null:
return $default(_that.id,_that.bookType,_that.isPrimary,_that.folderBased);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? bookType, @JsonKey(name: 'primary')  bool isPrimary,  bool folderBased)  $default,) {final _that = this;
switch (_that) {
case _BookFile():
return $default(_that.id,_that.bookType,_that.isPrimary,_that.folderBased);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? bookType, @JsonKey(name: 'primary')  bool isPrimary,  bool folderBased)?  $default,) {final _that = this;
switch (_that) {
case _BookFile() when $default != null:
return $default(_that.id,_that.bookType,_that.isPrimary,_that.folderBased);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookFile implements BookFile {
  const _BookFile({required this.id, this.bookType, @JsonKey(name: 'primary') this.isPrimary = false, this.folderBased = false});
  factory _BookFile.fromJson(Map<String, dynamic> json) => _$BookFileFromJson(json);

@override final  int id;
@override final  String? bookType;
@override@JsonKey(name: 'primary') final  bool isPrimary;
@override@JsonKey() final  bool folderBased;

/// Create a copy of BookFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookFileCopyWith<_BookFile> get copyWith => __$BookFileCopyWithImpl<_BookFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookFileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookFile&&(identical(other.id, id) || other.id == id)&&(identical(other.bookType, bookType) || other.bookType == bookType)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.folderBased, folderBased) || other.folderBased == folderBased));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,bookType,isPrimary,folderBased);
}

@override
String toString() {
    return 'BookFile(id: $id, bookType: $bookType, isPrimary: $isPrimary, folderBased: $folderBased)';
}


}

/// @nodoc
abstract mixin class _$BookFileCopyWith<$Res> implements $BookFileCopyWith<$Res> {
  factory _$BookFileCopyWith(_BookFile value, $Res Function(_BookFile) _then) = __$BookFileCopyWithImpl;
@override @useResult
$Res call({
 int id, String? bookType,@JsonKey(name: 'primary') bool isPrimary, bool folderBased
});




}
/// @nodoc
class __$BookFileCopyWithImpl<$Res>
    implements _$BookFileCopyWith<$Res> {
  __$BookFileCopyWithImpl(this._self, this._then);

  final _BookFile _self;
  final $Res Function(_BookFile) _then;

/// Create a copy of BookFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookType = freezed,Object? isPrimary = null,Object? folderBased = null,}) {
  return _then(_BookFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookType: freezed == bookType ? _self.bookType : bookType // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,folderBased: null == folderBased ? _self.folderBased : folderBased // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AudiobookInfo {

 int get bookId; int? get bookFileId; String? get narrator; int get durationMs; bool get folderBased; List<AudiobookChapter> get chapters; List<AudiobookTrack> get tracks;
/// Create a copy of AudiobookInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudiobookInfoCopyWith<AudiobookInfo> get copyWith => _$AudiobookInfoCopyWithImpl<AudiobookInfo>(this as AudiobookInfo, _$identity);

  /// Serializes this AudiobookInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AudiobookInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudiobookInfo&&(identical(other.bookId, _this.bookId) || other.bookId == _this.bookId)&&(identical(other.bookFileId, _this.bookFileId) || other.bookFileId == _this.bookFileId)&&(identical(other.narrator, _this.narrator) || other.narrator == _this.narrator)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.folderBased, _this.folderBased) || other.folderBased == _this.folderBased)&&const DeepCollectionEquality().equals(other.chapters, _this.chapters)&&const DeepCollectionEquality().equals(other.tracks, _this.tracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AudiobookInfo;
  return Object.hash(runtimeType,_this.bookId,_this.bookFileId,_this.narrator,_this.durationMs,_this.folderBased,const DeepCollectionEquality().hash(_this.chapters),const DeepCollectionEquality().hash(_this.tracks));
}

@override
String toString() {
  final _this = this as AudiobookInfo;
  return 'AudiobookInfo(bookId: ${_this.bookId}, bookFileId: ${_this.bookFileId}, narrator: ${_this.narrator}, durationMs: ${_this.durationMs}, folderBased: ${_this.folderBased}, chapters: ${_this.chapters}, tracks: ${_this.tracks})';
}


}

/// @nodoc
abstract mixin class $AudiobookInfoCopyWith<$Res>  {
  factory $AudiobookInfoCopyWith(AudiobookInfo value, $Res Function(AudiobookInfo) _then) = _$AudiobookInfoCopyWithImpl;
@useResult
$Res call({
 int bookId, int? bookFileId, String? narrator, int durationMs, bool folderBased, List<AudiobookChapter> chapters, List<AudiobookTrack> tracks
});




}
/// @nodoc
class _$AudiobookInfoCopyWithImpl<$Res>
    implements $AudiobookInfoCopyWith<$Res> {
  _$AudiobookInfoCopyWithImpl(this._self, this._then);

  final AudiobookInfo _self;
  final $Res Function(AudiobookInfo) _then;

/// Create a copy of AudiobookInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? bookFileId = freezed,Object? narrator = freezed,Object? durationMs = null,Object? folderBased = null,Object? chapters = null,Object? tracks = null,}) {
  return _then(AudiobookInfo(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,bookFileId: freezed == bookFileId ? _self.bookFileId : bookFileId // ignore: cast_nullable_to_non_nullable
as int?,narrator: freezed == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
as String?,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,folderBased: null == folderBased ? _self.folderBased : folderBased // ignore: cast_nullable_to_non_nullable
as bool,chapters: null == chapters ? _self.chapters : chapters // ignore: cast_nullable_to_non_nullable
as List<AudiobookChapter>,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<AudiobookTrack>,
  ));
}

}


/// Adds pattern-matching-related methods to [AudiobookInfo].
extension AudiobookInfoPatterns on AudiobookInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudiobookInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudiobookInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudiobookInfo value)  $default,){
final _that = this;
switch (_that) {
case _AudiobookInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudiobookInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AudiobookInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookId,  int? bookFileId,  String? narrator,  int durationMs,  bool folderBased,  List<AudiobookChapter> chapters,  List<AudiobookTrack> tracks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudiobookInfo() when $default != null:
return $default(_that.bookId,_that.bookFileId,_that.narrator,_that.durationMs,_that.folderBased,_that.chapters,_that.tracks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookId,  int? bookFileId,  String? narrator,  int durationMs,  bool folderBased,  List<AudiobookChapter> chapters,  List<AudiobookTrack> tracks)  $default,) {final _that = this;
switch (_that) {
case _AudiobookInfo():
return $default(_that.bookId,_that.bookFileId,_that.narrator,_that.durationMs,_that.folderBased,_that.chapters,_that.tracks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookId,  int? bookFileId,  String? narrator,  int durationMs,  bool folderBased,  List<AudiobookChapter> chapters,  List<AudiobookTrack> tracks)?  $default,) {final _that = this;
switch (_that) {
case _AudiobookInfo() when $default != null:
return $default(_that.bookId,_that.bookFileId,_that.narrator,_that.durationMs,_that.folderBased,_that.chapters,_that.tracks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AudiobookInfo implements AudiobookInfo {
  const _AudiobookInfo({required this.bookId, this.bookFileId, this.narrator, required this.durationMs, this.folderBased = false,  List<AudiobookChapter> chapters = const [],  List<AudiobookTrack> tracks = const []}): _chapters = chapters,_tracks = tracks;
  factory _AudiobookInfo.fromJson(Map<String, dynamic> json) => _$AudiobookInfoFromJson(json);

@override final  int bookId;
@override final  int? bookFileId;
@override final  String? narrator;
@override final  int durationMs;
@override@JsonKey() final  bool folderBased;
 final  List<AudiobookChapter> _chapters;
@override@JsonKey() List<AudiobookChapter> get chapters {
  if (_chapters is EqualUnmodifiableListView) return _chapters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chapters);
}

 final  List<AudiobookTrack> _tracks;
@override@JsonKey() List<AudiobookTrack> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}


/// Create a copy of AudiobookInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudiobookInfoCopyWith<_AudiobookInfo> get copyWith => __$AudiobookInfoCopyWithImpl<_AudiobookInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AudiobookInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudiobookInfo&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.bookFileId, bookFileId) || other.bookFileId == bookFileId)&&(identical(other.narrator, narrator) || other.narrator == narrator)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.folderBased, folderBased) || other.folderBased == folderBased)&&const DeepCollectionEquality().equals(other.chapters, _chapters)&&const DeepCollectionEquality().equals(other.tracks, _tracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookId,bookFileId,narrator,durationMs,folderBased,const DeepCollectionEquality().hash(_chapters),const DeepCollectionEquality().hash(_tracks));
}

@override
String toString() {
    return 'AudiobookInfo(bookId: $bookId, bookFileId: $bookFileId, narrator: $narrator, durationMs: $durationMs, folderBased: $folderBased, chapters: $chapters, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class _$AudiobookInfoCopyWith<$Res> implements $AudiobookInfoCopyWith<$Res> {
  factory _$AudiobookInfoCopyWith(_AudiobookInfo value, $Res Function(_AudiobookInfo) _then) = __$AudiobookInfoCopyWithImpl;
@override @useResult
$Res call({
 int bookId, int? bookFileId, String? narrator, int durationMs, bool folderBased, List<AudiobookChapter> chapters, List<AudiobookTrack> tracks
});




}
/// @nodoc
class __$AudiobookInfoCopyWithImpl<$Res>
    implements _$AudiobookInfoCopyWith<$Res> {
  __$AudiobookInfoCopyWithImpl(this._self, this._then);

  final _AudiobookInfo _self;
  final $Res Function(_AudiobookInfo) _then;

/// Create a copy of AudiobookInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? bookFileId = freezed,Object? narrator = freezed,Object? durationMs = null,Object? folderBased = null,Object? chapters = null,Object? tracks = null,}) {
  return _then(_AudiobookInfo(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,bookFileId: freezed == bookFileId ? _self.bookFileId : bookFileId // ignore: cast_nullable_to_non_nullable
as int?,narrator: freezed == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
as String?,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,folderBased: null == folderBased ? _self.folderBased : folderBased // ignore: cast_nullable_to_non_nullable
as bool,chapters: null == chapters ? _self._chapters : chapters // ignore: cast_nullable_to_non_nullable
as List<AudiobookChapter>,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<AudiobookTrack>,
  ));
}


}


/// @nodoc
mixin _$AudiobookChapter {

 int get index; String get title; int get startTimeMs; int get endTimeMs; int get durationMs;
/// Create a copy of AudiobookChapter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudiobookChapterCopyWith<AudiobookChapter> get copyWith => _$AudiobookChapterCopyWithImpl<AudiobookChapter>(this as AudiobookChapter, _$identity);

  /// Serializes this AudiobookChapter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AudiobookChapter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudiobookChapter&&(identical(other.index, _this.index) || other.index == _this.index)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.startTimeMs, _this.startTimeMs) || other.startTimeMs == _this.startTimeMs)&&(identical(other.endTimeMs, _this.endTimeMs) || other.endTimeMs == _this.endTimeMs)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AudiobookChapter;
  return Object.hash(runtimeType,_this.index,_this.title,_this.startTimeMs,_this.endTimeMs,_this.durationMs);
}

@override
String toString() {
  final _this = this as AudiobookChapter;
  return 'AudiobookChapter(index: ${_this.index}, title: ${_this.title}, startTimeMs: ${_this.startTimeMs}, endTimeMs: ${_this.endTimeMs}, durationMs: ${_this.durationMs})';
}


}

/// @nodoc
abstract mixin class $AudiobookChapterCopyWith<$Res>  {
  factory $AudiobookChapterCopyWith(AudiobookChapter value, $Res Function(AudiobookChapter) _then) = _$AudiobookChapterCopyWithImpl;
@useResult
$Res call({
 int index, String title, int startTimeMs, int endTimeMs, int durationMs
});




}
/// @nodoc
class _$AudiobookChapterCopyWithImpl<$Res>
    implements $AudiobookChapterCopyWith<$Res> {
  _$AudiobookChapterCopyWithImpl(this._self, this._then);

  final AudiobookChapter _self;
  final $Res Function(AudiobookChapter) _then;

/// Create a copy of AudiobookChapter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? title = null,Object? startTimeMs = null,Object? endTimeMs = null,Object? durationMs = null,}) {
  return _then(AudiobookChapter(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startTimeMs: null == startTimeMs ? _self.startTimeMs : startTimeMs // ignore: cast_nullable_to_non_nullable
as int,endTimeMs: null == endTimeMs ? _self.endTimeMs : endTimeMs // ignore: cast_nullable_to_non_nullable
as int,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AudiobookChapter].
extension AudiobookChapterPatterns on AudiobookChapter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudiobookChapter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudiobookChapter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudiobookChapter value)  $default,){
final _that = this;
switch (_that) {
case _AudiobookChapter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudiobookChapter value)?  $default,){
final _that = this;
switch (_that) {
case _AudiobookChapter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  String title,  int startTimeMs,  int endTimeMs,  int durationMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudiobookChapter() when $default != null:
return $default(_that.index,_that.title,_that.startTimeMs,_that.endTimeMs,_that.durationMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  String title,  int startTimeMs,  int endTimeMs,  int durationMs)  $default,) {final _that = this;
switch (_that) {
case _AudiobookChapter():
return $default(_that.index,_that.title,_that.startTimeMs,_that.endTimeMs,_that.durationMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  String title,  int startTimeMs,  int endTimeMs,  int durationMs)?  $default,) {final _that = this;
switch (_that) {
case _AudiobookChapter() when $default != null:
return $default(_that.index,_that.title,_that.startTimeMs,_that.endTimeMs,_that.durationMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AudiobookChapter implements AudiobookChapter {
  const _AudiobookChapter({required this.index, required this.title, required this.startTimeMs, required this.endTimeMs, required this.durationMs});
  factory _AudiobookChapter.fromJson(Map<String, dynamic> json) => _$AudiobookChapterFromJson(json);

@override final  int index;
@override final  String title;
@override final  int startTimeMs;
@override final  int endTimeMs;
@override final  int durationMs;

/// Create a copy of AudiobookChapter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudiobookChapterCopyWith<_AudiobookChapter> get copyWith => __$AudiobookChapterCopyWithImpl<_AudiobookChapter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AudiobookChapterToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudiobookChapter&&(identical(other.index, index) || other.index == index)&&(identical(other.title, title) || other.title == title)&&(identical(other.startTimeMs, startTimeMs) || other.startTimeMs == startTimeMs)&&(identical(other.endTimeMs, endTimeMs) || other.endTimeMs == endTimeMs)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,index,title,startTimeMs,endTimeMs,durationMs);
}

@override
String toString() {
    return 'AudiobookChapter(index: $index, title: $title, startTimeMs: $startTimeMs, endTimeMs: $endTimeMs, durationMs: $durationMs)';
}


}

/// @nodoc
abstract mixin class _$AudiobookChapterCopyWith<$Res> implements $AudiobookChapterCopyWith<$Res> {
  factory _$AudiobookChapterCopyWith(_AudiobookChapter value, $Res Function(_AudiobookChapter) _then) = __$AudiobookChapterCopyWithImpl;
@override @useResult
$Res call({
 int index, String title, int startTimeMs, int endTimeMs, int durationMs
});




}
/// @nodoc
class __$AudiobookChapterCopyWithImpl<$Res>
    implements _$AudiobookChapterCopyWith<$Res> {
  __$AudiobookChapterCopyWithImpl(this._self, this._then);

  final _AudiobookChapter _self;
  final $Res Function(_AudiobookChapter) _then;

/// Create a copy of AudiobookChapter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? title = null,Object? startTimeMs = null,Object? endTimeMs = null,Object? durationMs = null,}) {
  return _then(_AudiobookChapter(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startTimeMs: null == startTimeMs ? _self.startTimeMs : startTimeMs // ignore: cast_nullable_to_non_nullable
as int,endTimeMs: null == endTimeMs ? _self.endTimeMs : endTimeMs // ignore: cast_nullable_to_non_nullable
as int,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AudiobookTrack {

 int get index; String get fileName; String get title; int get durationMs; int? get fileSizeBytes; int get cumulativeStartMs;
/// Create a copy of AudiobookTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudiobookTrackCopyWith<AudiobookTrack> get copyWith => _$AudiobookTrackCopyWithImpl<AudiobookTrack>(this as AudiobookTrack, _$identity);

  /// Serializes this AudiobookTrack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AudiobookTrack;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudiobookTrack&&(identical(other.index, _this.index) || other.index == _this.index)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.fileSizeBytes, _this.fileSizeBytes) || other.fileSizeBytes == _this.fileSizeBytes)&&(identical(other.cumulativeStartMs, _this.cumulativeStartMs) || other.cumulativeStartMs == _this.cumulativeStartMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AudiobookTrack;
  return Object.hash(runtimeType,_this.index,_this.fileName,_this.title,_this.durationMs,_this.fileSizeBytes,_this.cumulativeStartMs);
}

@override
String toString() {
  final _this = this as AudiobookTrack;
  return 'AudiobookTrack(index: ${_this.index}, fileName: ${_this.fileName}, title: ${_this.title}, durationMs: ${_this.durationMs}, fileSizeBytes: ${_this.fileSizeBytes}, cumulativeStartMs: ${_this.cumulativeStartMs})';
}


}

/// @nodoc
abstract mixin class $AudiobookTrackCopyWith<$Res>  {
  factory $AudiobookTrackCopyWith(AudiobookTrack value, $Res Function(AudiobookTrack) _then) = _$AudiobookTrackCopyWithImpl;
@useResult
$Res call({
 int index, String fileName, String title, int durationMs, int? fileSizeBytes, int cumulativeStartMs
});




}
/// @nodoc
class _$AudiobookTrackCopyWithImpl<$Res>
    implements $AudiobookTrackCopyWith<$Res> {
  _$AudiobookTrackCopyWithImpl(this._self, this._then);

  final AudiobookTrack _self;
  final $Res Function(AudiobookTrack) _then;

/// Create a copy of AudiobookTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? fileName = null,Object? title = null,Object? durationMs = null,Object? fileSizeBytes = freezed,Object? cumulativeStartMs = null,}) {
  return _then(AudiobookTrack(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,cumulativeStartMs: null == cumulativeStartMs ? _self.cumulativeStartMs : cumulativeStartMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AudiobookTrack].
extension AudiobookTrackPatterns on AudiobookTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudiobookTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudiobookTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudiobookTrack value)  $default,){
final _that = this;
switch (_that) {
case _AudiobookTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudiobookTrack value)?  $default,){
final _that = this;
switch (_that) {
case _AudiobookTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  String fileName,  String title,  int durationMs,  int? fileSizeBytes,  int cumulativeStartMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudiobookTrack() when $default != null:
return $default(_that.index,_that.fileName,_that.title,_that.durationMs,_that.fileSizeBytes,_that.cumulativeStartMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  String fileName,  String title,  int durationMs,  int? fileSizeBytes,  int cumulativeStartMs)  $default,) {final _that = this;
switch (_that) {
case _AudiobookTrack():
return $default(_that.index,_that.fileName,_that.title,_that.durationMs,_that.fileSizeBytes,_that.cumulativeStartMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  String fileName,  String title,  int durationMs,  int? fileSizeBytes,  int cumulativeStartMs)?  $default,) {final _that = this;
switch (_that) {
case _AudiobookTrack() when $default != null:
return $default(_that.index,_that.fileName,_that.title,_that.durationMs,_that.fileSizeBytes,_that.cumulativeStartMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AudiobookTrack implements AudiobookTrack {
  const _AudiobookTrack({required this.index, required this.fileName, required this.title, required this.durationMs, this.fileSizeBytes, required this.cumulativeStartMs});
  factory _AudiobookTrack.fromJson(Map<String, dynamic> json) => _$AudiobookTrackFromJson(json);

@override final  int index;
@override final  String fileName;
@override final  String title;
@override final  int durationMs;
@override final  int? fileSizeBytes;
@override final  int cumulativeStartMs;

/// Create a copy of AudiobookTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudiobookTrackCopyWith<_AudiobookTrack> get copyWith => __$AudiobookTrackCopyWithImpl<_AudiobookTrack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AudiobookTrackToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudiobookTrack&&(identical(other.index, index) || other.index == index)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.title, title) || other.title == title)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.cumulativeStartMs, cumulativeStartMs) || other.cumulativeStartMs == cumulativeStartMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,index,fileName,title,durationMs,fileSizeBytes,cumulativeStartMs);
}

@override
String toString() {
    return 'AudiobookTrack(index: $index, fileName: $fileName, title: $title, durationMs: $durationMs, fileSizeBytes: $fileSizeBytes, cumulativeStartMs: $cumulativeStartMs)';
}


}

/// @nodoc
abstract mixin class _$AudiobookTrackCopyWith<$Res> implements $AudiobookTrackCopyWith<$Res> {
  factory _$AudiobookTrackCopyWith(_AudiobookTrack value, $Res Function(_AudiobookTrack) _then) = __$AudiobookTrackCopyWithImpl;
@override @useResult
$Res call({
 int index, String fileName, String title, int durationMs, int? fileSizeBytes, int cumulativeStartMs
});




}
/// @nodoc
class __$AudiobookTrackCopyWithImpl<$Res>
    implements _$AudiobookTrackCopyWith<$Res> {
  __$AudiobookTrackCopyWithImpl(this._self, this._then);

  final _AudiobookTrack _self;
  final $Res Function(_AudiobookTrack) _then;

/// Create a copy of AudiobookTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? fileName = null,Object? title = null,Object? durationMs = null,Object? fileSizeBytes = freezed,Object? cumulativeStartMs = null,}) {
  return _then(_AudiobookTrack(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,cumulativeStartMs: null == cumulativeStartMs ? _self.cumulativeStartMs : cumulativeStartMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AudiobookProgress {

 int get positionMs; int? get trackIndex; int? get trackPositionMs; double get percentage;
/// Create a copy of AudiobookProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudiobookProgressCopyWith<AudiobookProgress> get copyWith => _$AudiobookProgressCopyWithImpl<AudiobookProgress>(this as AudiobookProgress, _$identity);

  /// Serializes this AudiobookProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AudiobookProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudiobookProgress&&(identical(other.positionMs, _this.positionMs) || other.positionMs == _this.positionMs)&&(identical(other.trackIndex, _this.trackIndex) || other.trackIndex == _this.trackIndex)&&(identical(other.trackPositionMs, _this.trackPositionMs) || other.trackPositionMs == _this.trackPositionMs)&&(identical(other.percentage, _this.percentage) || other.percentage == _this.percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AudiobookProgress;
  return Object.hash(runtimeType,_this.positionMs,_this.trackIndex,_this.trackPositionMs,_this.percentage);
}

@override
String toString() {
  final _this = this as AudiobookProgress;
  return 'AudiobookProgress(positionMs: ${_this.positionMs}, trackIndex: ${_this.trackIndex}, trackPositionMs: ${_this.trackPositionMs}, percentage: ${_this.percentage})';
}


}

/// @nodoc
abstract mixin class $AudiobookProgressCopyWith<$Res>  {
  factory $AudiobookProgressCopyWith(AudiobookProgress value, $Res Function(AudiobookProgress) _then) = _$AudiobookProgressCopyWithImpl;
@useResult
$Res call({
 int positionMs, int? trackIndex, int? trackPositionMs, double percentage
});




}
/// @nodoc
class _$AudiobookProgressCopyWithImpl<$Res>
    implements $AudiobookProgressCopyWith<$Res> {
  _$AudiobookProgressCopyWithImpl(this._self, this._then);

  final AudiobookProgress _self;
  final $Res Function(AudiobookProgress) _then;

/// Create a copy of AudiobookProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? positionMs = null,Object? trackIndex = freezed,Object? trackPositionMs = freezed,Object? percentage = null,}) {
  return _then(AudiobookProgress(
positionMs: null == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
as int,trackIndex: freezed == trackIndex ? _self.trackIndex : trackIndex // ignore: cast_nullable_to_non_nullable
as int?,trackPositionMs: freezed == trackPositionMs ? _self.trackPositionMs : trackPositionMs // ignore: cast_nullable_to_non_nullable
as int?,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AudiobookProgress].
extension AudiobookProgressPatterns on AudiobookProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudiobookProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudiobookProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudiobookProgress value)  $default,){
final _that = this;
switch (_that) {
case _AudiobookProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudiobookProgress value)?  $default,){
final _that = this;
switch (_that) {
case _AudiobookProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int positionMs,  int? trackIndex,  int? trackPositionMs,  double percentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudiobookProgress() when $default != null:
return $default(_that.positionMs,_that.trackIndex,_that.trackPositionMs,_that.percentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int positionMs,  int? trackIndex,  int? trackPositionMs,  double percentage)  $default,) {final _that = this;
switch (_that) {
case _AudiobookProgress():
return $default(_that.positionMs,_that.trackIndex,_that.trackPositionMs,_that.percentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int positionMs,  int? trackIndex,  int? trackPositionMs,  double percentage)?  $default,) {final _that = this;
switch (_that) {
case _AudiobookProgress() when $default != null:
return $default(_that.positionMs,_that.trackIndex,_that.trackPositionMs,_that.percentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AudiobookProgress implements AudiobookProgress {
  const _AudiobookProgress({required this.positionMs, this.trackIndex, this.trackPositionMs, required this.percentage});
  factory _AudiobookProgress.fromJson(Map<String, dynamic> json) => _$AudiobookProgressFromJson(json);

@override final  int positionMs;
@override final  int? trackIndex;
@override final  int? trackPositionMs;
@override final  double percentage;

/// Create a copy of AudiobookProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudiobookProgressCopyWith<_AudiobookProgress> get copyWith => __$AudiobookProgressCopyWithImpl<_AudiobookProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AudiobookProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudiobookProgress&&(identical(other.positionMs, positionMs) || other.positionMs == positionMs)&&(identical(other.trackIndex, trackIndex) || other.trackIndex == trackIndex)&&(identical(other.trackPositionMs, trackPositionMs) || other.trackPositionMs == trackPositionMs)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,positionMs,trackIndex,trackPositionMs,percentage);
}

@override
String toString() {
    return 'AudiobookProgress(positionMs: $positionMs, trackIndex: $trackIndex, trackPositionMs: $trackPositionMs, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class _$AudiobookProgressCopyWith<$Res> implements $AudiobookProgressCopyWith<$Res> {
  factory _$AudiobookProgressCopyWith(_AudiobookProgress value, $Res Function(_AudiobookProgress) _then) = __$AudiobookProgressCopyWithImpl;
@override @useResult
$Res call({
 int positionMs, int? trackIndex, int? trackPositionMs, double percentage
});




}
/// @nodoc
class __$AudiobookProgressCopyWithImpl<$Res>
    implements _$AudiobookProgressCopyWith<$Res> {
  __$AudiobookProgressCopyWithImpl(this._self, this._then);

  final _AudiobookProgress _self;
  final $Res Function(_AudiobookProgress) _then;

/// Create a copy of AudiobookProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? positionMs = null,Object? trackIndex = freezed,Object? trackPositionMs = freezed,Object? percentage = null,}) {
  return _then(_AudiobookProgress(
positionMs: null == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
as int,trackIndex: freezed == trackIndex ? _self.trackIndex : trackIndex // ignore: cast_nullable_to_non_nullable
as int?,trackPositionMs: freezed == trackPositionMs ? _self.trackPositionMs : trackPositionMs // ignore: cast_nullable_to_non_nullable
as int?,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$EpubProgress {

 String? get cfi; String? get href; double get percentage;
/// Create a copy of EpubProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpubProgressCopyWith<EpubProgress> get copyWith => _$EpubProgressCopyWithImpl<EpubProgress>(this as EpubProgress, _$identity);

  /// Serializes this EpubProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EpubProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EpubProgress&&(identical(other.cfi, _this.cfi) || other.cfi == _this.cfi)&&(identical(other.href, _this.href) || other.href == _this.href)&&(identical(other.percentage, _this.percentage) || other.percentage == _this.percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EpubProgress;
  return Object.hash(runtimeType,_this.cfi,_this.href,_this.percentage);
}

@override
String toString() {
  final _this = this as EpubProgress;
  return 'EpubProgress(cfi: ${_this.cfi}, href: ${_this.href}, percentage: ${_this.percentage})';
}


}

/// @nodoc
abstract mixin class $EpubProgressCopyWith<$Res>  {
  factory $EpubProgressCopyWith(EpubProgress value, $Res Function(EpubProgress) _then) = _$EpubProgressCopyWithImpl;
@useResult
$Res call({
 String? cfi, String? href, double percentage
});




}
/// @nodoc
class _$EpubProgressCopyWithImpl<$Res>
    implements $EpubProgressCopyWith<$Res> {
  _$EpubProgressCopyWithImpl(this._self, this._then);

  final EpubProgress _self;
  final $Res Function(EpubProgress) _then;

/// Create a copy of EpubProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cfi = freezed,Object? href = freezed,Object? percentage = null,}) {
  return _then(EpubProgress(
cfi: freezed == cfi ? _self.cfi : cfi // ignore: cast_nullable_to_non_nullable
as String?,href: freezed == href ? _self.href : href // ignore: cast_nullable_to_non_nullable
as String?,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EpubProgress].
extension EpubProgressPatterns on EpubProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EpubProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EpubProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EpubProgress value)  $default,){
final _that = this;
switch (_that) {
case _EpubProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EpubProgress value)?  $default,){
final _that = this;
switch (_that) {
case _EpubProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? cfi,  String? href,  double percentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EpubProgress() when $default != null:
return $default(_that.cfi,_that.href,_that.percentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? cfi,  String? href,  double percentage)  $default,) {final _that = this;
switch (_that) {
case _EpubProgress():
return $default(_that.cfi,_that.href,_that.percentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? cfi,  String? href,  double percentage)?  $default,) {final _that = this;
switch (_that) {
case _EpubProgress() when $default != null:
return $default(_that.cfi,_that.href,_that.percentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EpubProgress implements EpubProgress {
  const _EpubProgress({this.cfi, this.href, required this.percentage});
  factory _EpubProgress.fromJson(Map<String, dynamic> json) => _$EpubProgressFromJson(json);

@override final  String? cfi;
@override final  String? href;
@override final  double percentage;

/// Create a copy of EpubProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpubProgressCopyWith<_EpubProgress> get copyWith => __$EpubProgressCopyWithImpl<_EpubProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpubProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EpubProgress&&(identical(other.cfi, cfi) || other.cfi == cfi)&&(identical(other.href, href) || other.href == href)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,cfi,href,percentage);
}

@override
String toString() {
    return 'EpubProgress(cfi: $cfi, href: $href, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class _$EpubProgressCopyWith<$Res> implements $EpubProgressCopyWith<$Res> {
  factory _$EpubProgressCopyWith(_EpubProgress value, $Res Function(_EpubProgress) _then) = __$EpubProgressCopyWithImpl;
@override @useResult
$Res call({
 String? cfi, String? href, double percentage
});




}
/// @nodoc
class __$EpubProgressCopyWithImpl<$Res>
    implements _$EpubProgressCopyWith<$Res> {
  __$EpubProgressCopyWithImpl(this._self, this._then);

  final _EpubProgress _self;
  final $Res Function(_EpubProgress) _then;

/// Create a copy of EpubProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cfi = freezed,Object? href = freezed,Object? percentage = null,}) {
  return _then(_EpubProgress(
cfi: freezed == cfi ? _self.cfi : cfi // ignore: cast_nullable_to_non_nullable
as String?,href: freezed == href ? _self.href : href // ignore: cast_nullable_to_non_nullable
as String?,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PageProgress {

 int get page; double get percentage; DateTime? get updatedAt;
/// Create a copy of PageProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageProgressCopyWith<PageProgress> get copyWith => _$PageProgressCopyWithImpl<PageProgress>(this as PageProgress, _$identity);

  /// Serializes this PageProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PageProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageProgress&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.percentage, _this.percentage) || other.percentage == _this.percentage)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PageProgress;
  return Object.hash(runtimeType,_this.page,_this.percentage,_this.updatedAt);
}

@override
String toString() {
  final _this = this as PageProgress;
  return 'PageProgress(page: ${_this.page}, percentage: ${_this.percentage}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $PageProgressCopyWith<$Res>  {
  factory $PageProgressCopyWith(PageProgress value, $Res Function(PageProgress) _then) = _$PageProgressCopyWithImpl;
@useResult
$Res call({
 int page, double percentage, DateTime? updatedAt
});




}
/// @nodoc
class _$PageProgressCopyWithImpl<$Res>
    implements $PageProgressCopyWith<$Res> {
  _$PageProgressCopyWithImpl(this._self, this._then);

  final PageProgress _self;
  final $Res Function(PageProgress) _then;

/// Create a copy of PageProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? percentage = null,Object? updatedAt = freezed,}) {
  return _then(PageProgress(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PageProgress].
extension PageProgressPatterns on PageProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageProgress value)  $default,){
final _that = this;
switch (_that) {
case _PageProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageProgress value)?  $default,){
final _that = this;
switch (_that) {
case _PageProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int page,  double percentage,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageProgress() when $default != null:
return $default(_that.page,_that.percentage,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int page,  double percentage,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PageProgress():
return $default(_that.page,_that.percentage,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int page,  double percentage,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PageProgress() when $default != null:
return $default(_that.page,_that.percentage,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PageProgress implements PageProgress {
  const _PageProgress({required this.page, required this.percentage, this.updatedAt});
  factory _PageProgress.fromJson(Map<String, dynamic> json) => _$PageProgressFromJson(json);

@override final  int page;
@override final  double percentage;
@override final  DateTime? updatedAt;

/// Create a copy of PageProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageProgressCopyWith<_PageProgress> get copyWith => __$PageProgressCopyWithImpl<_PageProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PageProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageProgress&&(identical(other.page, page) || other.page == page)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,page,percentage,updatedAt);
}

@override
String toString() {
    return 'PageProgress(page: $page, percentage: $percentage, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PageProgressCopyWith<$Res> implements $PageProgressCopyWith<$Res> {
  factory _$PageProgressCopyWith(_PageProgress value, $Res Function(_PageProgress) _then) = __$PageProgressCopyWithImpl;
@override @useResult
$Res call({
 int page, double percentage, DateTime? updatedAt
});




}
/// @nodoc
class __$PageProgressCopyWithImpl<$Res>
    implements _$PageProgressCopyWith<$Res> {
  __$PageProgressCopyWithImpl(this._self, this._then);

  final _PageProgress _self;
  final $Res Function(_PageProgress) _then;

/// Create a copy of PageProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? percentage = null,Object? updatedAt = freezed,}) {
  return _then(_PageProgress(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Series {

 String get seriesName; int get bookCount; List<String> get authors; int? get seriesTotal; int get booksRead; DateTime? get latestAddedOn; List<SeriesCoverBook> get coverBooks;
/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesCopyWith<Series> get copyWith => _$SeriesCopyWithImpl<Series>(this as Series, _$identity);

  /// Serializes this Series to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Series;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Series&&(identical(other.seriesName, _this.seriesName) || other.seriesName == _this.seriesName)&&(identical(other.bookCount, _this.bookCount) || other.bookCount == _this.bookCount)&&const DeepCollectionEquality().equals(other.authors, _this.authors)&&(identical(other.seriesTotal, _this.seriesTotal) || other.seriesTotal == _this.seriesTotal)&&(identical(other.booksRead, _this.booksRead) || other.booksRead == _this.booksRead)&&(identical(other.latestAddedOn, _this.latestAddedOn) || other.latestAddedOn == _this.latestAddedOn)&&const DeepCollectionEquality().equals(other.coverBooks, _this.coverBooks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Series;
  return Object.hash(runtimeType,_this.seriesName,_this.bookCount,const DeepCollectionEquality().hash(_this.authors),_this.seriesTotal,_this.booksRead,_this.latestAddedOn,const DeepCollectionEquality().hash(_this.coverBooks));
}

@override
String toString() {
  final _this = this as Series;
  return 'Series(seriesName: ${_this.seriesName}, bookCount: ${_this.bookCount}, authors: ${_this.authors}, seriesTotal: ${_this.seriesTotal}, booksRead: ${_this.booksRead}, latestAddedOn: ${_this.latestAddedOn}, coverBooks: ${_this.coverBooks})';
}


}

/// @nodoc
abstract mixin class $SeriesCopyWith<$Res>  {
  factory $SeriesCopyWith(Series value, $Res Function(Series) _then) = _$SeriesCopyWithImpl;
@useResult
$Res call({
 String seriesName, int bookCount, List<String> authors, int? seriesTotal, int booksRead, DateTime? latestAddedOn, List<SeriesCoverBook> coverBooks
});




}
/// @nodoc
class _$SeriesCopyWithImpl<$Res>
    implements $SeriesCopyWith<$Res> {
  _$SeriesCopyWithImpl(this._self, this._then);

  final Series _self;
  final $Res Function(Series) _then;

/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seriesName = null,Object? bookCount = null,Object? authors = null,Object? seriesTotal = freezed,Object? booksRead = null,Object? latestAddedOn = freezed,Object? coverBooks = null,}) {
  return _then(Series(
seriesName: null == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,seriesTotal: freezed == seriesTotal ? _self.seriesTotal : seriesTotal // ignore: cast_nullable_to_non_nullable
as int?,booksRead: null == booksRead ? _self.booksRead : booksRead // ignore: cast_nullable_to_non_nullable
as int,latestAddedOn: freezed == latestAddedOn ? _self.latestAddedOn : latestAddedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,coverBooks: null == coverBooks ? _self.coverBooks : coverBooks // ignore: cast_nullable_to_non_nullable
as List<SeriesCoverBook>,
  ));
}

}


/// Adds pattern-matching-related methods to [Series].
extension SeriesPatterns on Series {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Series value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Series() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Series value)  $default,){
final _that = this;
switch (_that) {
case _Series():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Series value)?  $default,){
final _that = this;
switch (_that) {
case _Series() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String seriesName,  int bookCount,  List<String> authors,  int? seriesTotal,  int booksRead,  DateTime? latestAddedOn,  List<SeriesCoverBook> coverBooks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Series() when $default != null:
return $default(_that.seriesName,_that.bookCount,_that.authors,_that.seriesTotal,_that.booksRead,_that.latestAddedOn,_that.coverBooks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String seriesName,  int bookCount,  List<String> authors,  int? seriesTotal,  int booksRead,  DateTime? latestAddedOn,  List<SeriesCoverBook> coverBooks)  $default,) {final _that = this;
switch (_that) {
case _Series():
return $default(_that.seriesName,_that.bookCount,_that.authors,_that.seriesTotal,_that.booksRead,_that.latestAddedOn,_that.coverBooks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String seriesName,  int bookCount,  List<String> authors,  int? seriesTotal,  int booksRead,  DateTime? latestAddedOn,  List<SeriesCoverBook> coverBooks)?  $default,) {final _that = this;
switch (_that) {
case _Series() when $default != null:
return $default(_that.seriesName,_that.bookCount,_that.authors,_that.seriesTotal,_that.booksRead,_that.latestAddedOn,_that.coverBooks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Series implements Series {
  const _Series({required this.seriesName, required this.bookCount,  List<String> authors = const [], this.seriesTotal, this.booksRead = 0, this.latestAddedOn,  List<SeriesCoverBook> coverBooks = const []}): _authors = authors,_coverBooks = coverBooks;
  factory _Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);

@override final  String seriesName;
@override final  int bookCount;
 final  List<String> _authors;
@override@JsonKey() List<String> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

@override final  int? seriesTotal;
@override@JsonKey() final  int booksRead;
@override final  DateTime? latestAddedOn;
 final  List<SeriesCoverBook> _coverBooks;
@override@JsonKey() List<SeriesCoverBook> get coverBooks {
  if (_coverBooks is EqualUnmodifiableListView) return _coverBooks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coverBooks);
}


/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesCopyWith<_Series> get copyWith => __$SeriesCopyWithImpl<_Series>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeriesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Series&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.bookCount, bookCount) || other.bookCount == bookCount)&&const DeepCollectionEquality().equals(other.authors, _authors)&&(identical(other.seriesTotal, seriesTotal) || other.seriesTotal == seriesTotal)&&(identical(other.booksRead, booksRead) || other.booksRead == booksRead)&&(identical(other.latestAddedOn, latestAddedOn) || other.latestAddedOn == latestAddedOn)&&const DeepCollectionEquality().equals(other.coverBooks, _coverBooks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,seriesName,bookCount,const DeepCollectionEquality().hash(_authors),seriesTotal,booksRead,latestAddedOn,const DeepCollectionEquality().hash(_coverBooks));
}

@override
String toString() {
    return 'Series(seriesName: $seriesName, bookCount: $bookCount, authors: $authors, seriesTotal: $seriesTotal, booksRead: $booksRead, latestAddedOn: $latestAddedOn, coverBooks: $coverBooks)';
}


}

/// @nodoc
abstract mixin class _$SeriesCopyWith<$Res> implements $SeriesCopyWith<$Res> {
  factory _$SeriesCopyWith(_Series value, $Res Function(_Series) _then) = __$SeriesCopyWithImpl;
@override @useResult
$Res call({
 String seriesName, int bookCount, List<String> authors, int? seriesTotal, int booksRead, DateTime? latestAddedOn, List<SeriesCoverBook> coverBooks
});




}
/// @nodoc
class __$SeriesCopyWithImpl<$Res>
    implements _$SeriesCopyWith<$Res> {
  __$SeriesCopyWithImpl(this._self, this._then);

  final _Series _self;
  final $Res Function(_Series) _then;

/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seriesName = null,Object? bookCount = null,Object? authors = null,Object? seriesTotal = freezed,Object? booksRead = null,Object? latestAddedOn = freezed,Object? coverBooks = null,}) {
  return _then(_Series(
seriesName: null == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,seriesTotal: freezed == seriesTotal ? _self.seriesTotal : seriesTotal // ignore: cast_nullable_to_non_nullable
as int?,booksRead: null == booksRead ? _self.booksRead : booksRead // ignore: cast_nullable_to_non_nullable
as int,latestAddedOn: freezed == latestAddedOn ? _self.latestAddedOn : latestAddedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,coverBooks: null == coverBooks ? _self._coverBooks : coverBooks // ignore: cast_nullable_to_non_nullable
as List<SeriesCoverBook>,
  ));
}


}


/// @nodoc
mixin _$SeriesCoverBook {

 int get bookId; DateTime? get coverUpdatedOn; double? get seriesNumber; String? get primaryFileType;
/// Create a copy of SeriesCoverBook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesCoverBookCopyWith<SeriesCoverBook> get copyWith => _$SeriesCoverBookCopyWithImpl<SeriesCoverBook>(this as SeriesCoverBook, _$identity);

  /// Serializes this SeriesCoverBook to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SeriesCoverBook;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesCoverBook&&(identical(other.bookId, _this.bookId) || other.bookId == _this.bookId)&&(identical(other.coverUpdatedOn, _this.coverUpdatedOn) || other.coverUpdatedOn == _this.coverUpdatedOn)&&(identical(other.seriesNumber, _this.seriesNumber) || other.seriesNumber == _this.seriesNumber)&&(identical(other.primaryFileType, _this.primaryFileType) || other.primaryFileType == _this.primaryFileType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SeriesCoverBook;
  return Object.hash(runtimeType,_this.bookId,_this.coverUpdatedOn,_this.seriesNumber,_this.primaryFileType);
}

@override
String toString() {
  final _this = this as SeriesCoverBook;
  return 'SeriesCoverBook(bookId: ${_this.bookId}, coverUpdatedOn: ${_this.coverUpdatedOn}, seriesNumber: ${_this.seriesNumber}, primaryFileType: ${_this.primaryFileType})';
}


}

/// @nodoc
abstract mixin class $SeriesCoverBookCopyWith<$Res>  {
  factory $SeriesCoverBookCopyWith(SeriesCoverBook value, $Res Function(SeriesCoverBook) _then) = _$SeriesCoverBookCopyWithImpl;
@useResult
$Res call({
 int bookId, DateTime? coverUpdatedOn, double? seriesNumber, String? primaryFileType
});




}
/// @nodoc
class _$SeriesCoverBookCopyWithImpl<$Res>
    implements $SeriesCoverBookCopyWith<$Res> {
  _$SeriesCoverBookCopyWithImpl(this._self, this._then);

  final SeriesCoverBook _self;
  final $Res Function(SeriesCoverBook) _then;

/// Create a copy of SeriesCoverBook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? coverUpdatedOn = freezed,Object? seriesNumber = freezed,Object? primaryFileType = freezed,}) {
  return _then(SeriesCoverBook(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,coverUpdatedOn: freezed == coverUpdatedOn ? _self.coverUpdatedOn : coverUpdatedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,seriesNumber: freezed == seriesNumber ? _self.seriesNumber : seriesNumber // ignore: cast_nullable_to_non_nullable
as double?,primaryFileType: freezed == primaryFileType ? _self.primaryFileType : primaryFileType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SeriesCoverBook].
extension SeriesCoverBookPatterns on SeriesCoverBook {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeriesCoverBook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeriesCoverBook() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeriesCoverBook value)  $default,){
final _that = this;
switch (_that) {
case _SeriesCoverBook():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeriesCoverBook value)?  $default,){
final _that = this;
switch (_that) {
case _SeriesCoverBook() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookId,  DateTime? coverUpdatedOn,  double? seriesNumber,  String? primaryFileType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesCoverBook() when $default != null:
return $default(_that.bookId,_that.coverUpdatedOn,_that.seriesNumber,_that.primaryFileType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookId,  DateTime? coverUpdatedOn,  double? seriesNumber,  String? primaryFileType)  $default,) {final _that = this;
switch (_that) {
case _SeriesCoverBook():
return $default(_that.bookId,_that.coverUpdatedOn,_that.seriesNumber,_that.primaryFileType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookId,  DateTime? coverUpdatedOn,  double? seriesNumber,  String? primaryFileType)?  $default,) {final _that = this;
switch (_that) {
case _SeriesCoverBook() when $default != null:
return $default(_that.bookId,_that.coverUpdatedOn,_that.seriesNumber,_that.primaryFileType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeriesCoverBook implements SeriesCoverBook {
  const _SeriesCoverBook({required this.bookId, this.coverUpdatedOn, this.seriesNumber, this.primaryFileType});
  factory _SeriesCoverBook.fromJson(Map<String, dynamic> json) => _$SeriesCoverBookFromJson(json);

@override final  int bookId;
@override final  DateTime? coverUpdatedOn;
@override final  double? seriesNumber;
@override final  String? primaryFileType;

/// Create a copy of SeriesCoverBook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesCoverBookCopyWith<_SeriesCoverBook> get copyWith => __$SeriesCoverBookCopyWithImpl<_SeriesCoverBook>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeriesCoverBookToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesCoverBook&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.coverUpdatedOn, coverUpdatedOn) || other.coverUpdatedOn == coverUpdatedOn)&&(identical(other.seriesNumber, seriesNumber) || other.seriesNumber == seriesNumber)&&(identical(other.primaryFileType, primaryFileType) || other.primaryFileType == primaryFileType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookId,coverUpdatedOn,seriesNumber,primaryFileType);
}

@override
String toString() {
    return 'SeriesCoverBook(bookId: $bookId, coverUpdatedOn: $coverUpdatedOn, seriesNumber: $seriesNumber, primaryFileType: $primaryFileType)';
}


}

/// @nodoc
abstract mixin class _$SeriesCoverBookCopyWith<$Res> implements $SeriesCoverBookCopyWith<$Res> {
  factory _$SeriesCoverBookCopyWith(_SeriesCoverBook value, $Res Function(_SeriesCoverBook) _then) = __$SeriesCoverBookCopyWithImpl;
@override @useResult
$Res call({
 int bookId, DateTime? coverUpdatedOn, double? seriesNumber, String? primaryFileType
});




}
/// @nodoc
class __$SeriesCoverBookCopyWithImpl<$Res>
    implements _$SeriesCoverBookCopyWith<$Res> {
  __$SeriesCoverBookCopyWithImpl(this._self, this._then);

  final _SeriesCoverBook _self;
  final $Res Function(_SeriesCoverBook) _then;

/// Create a copy of SeriesCoverBook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? coverUpdatedOn = freezed,Object? seriesNumber = freezed,Object? primaryFileType = freezed,}) {
  return _then(_SeriesCoverBook(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,coverUpdatedOn: freezed == coverUpdatedOn ? _self.coverUpdatedOn : coverUpdatedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,seriesNumber: freezed == seriesNumber ? _self.seriesNumber : seriesNumber // ignore: cast_nullable_to_non_nullable
as double?,primaryFileType: freezed == primaryFileType ? _self.primaryFileType : primaryFileType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Bookmark {

 int get id; int get bookId; String? get cfi; int? get positionMs; int? get trackIndex; String? get title; String? get notes; DateTime? get createdAt;
/// Create a copy of Bookmark
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkCopyWith<Bookmark> get copyWith => _$BookmarkCopyWithImpl<Bookmark>(this as Bookmark, _$identity);

  /// Serializes this Bookmark to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Bookmark;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bookmark&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.bookId, _this.bookId) || other.bookId == _this.bookId)&&(identical(other.cfi, _this.cfi) || other.cfi == _this.cfi)&&(identical(other.positionMs, _this.positionMs) || other.positionMs == _this.positionMs)&&(identical(other.trackIndex, _this.trackIndex) || other.trackIndex == _this.trackIndex)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Bookmark;
  return Object.hash(runtimeType,_this.id,_this.bookId,_this.cfi,_this.positionMs,_this.trackIndex,_this.title,_this.notes,_this.createdAt);
}

@override
String toString() {
  final _this = this as Bookmark;
  return 'Bookmark(id: ${_this.id}, bookId: ${_this.bookId}, cfi: ${_this.cfi}, positionMs: ${_this.positionMs}, trackIndex: ${_this.trackIndex}, title: ${_this.title}, notes: ${_this.notes}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $BookmarkCopyWith<$Res>  {
  factory $BookmarkCopyWith(Bookmark value, $Res Function(Bookmark) _then) = _$BookmarkCopyWithImpl;
@useResult
$Res call({
 int id, int bookId, String? cfi, int? positionMs, int? trackIndex, String? title, String? notes, DateTime? createdAt
});




}
/// @nodoc
class _$BookmarkCopyWithImpl<$Res>
    implements $BookmarkCopyWith<$Res> {
  _$BookmarkCopyWithImpl(this._self, this._then);

  final Bookmark _self;
  final $Res Function(Bookmark) _then;

/// Create a copy of Bookmark
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookId = null,Object? cfi = freezed,Object? positionMs = freezed,Object? trackIndex = freezed,Object? title = freezed,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(Bookmark(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,cfi: freezed == cfi ? _self.cfi : cfi // ignore: cast_nullable_to_non_nullable
as String?,positionMs: freezed == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
as int?,trackIndex: freezed == trackIndex ? _self.trackIndex : trackIndex // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Bookmark].
extension BookmarkPatterns on Bookmark {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bookmark value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bookmark value)  $default,){
final _that = this;
switch (_that) {
case _Bookmark():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bookmark value)?  $default,){
final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int bookId,  String? cfi,  int? positionMs,  int? trackIndex,  String? title,  String? notes,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
return $default(_that.id,_that.bookId,_that.cfi,_that.positionMs,_that.trackIndex,_that.title,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int bookId,  String? cfi,  int? positionMs,  int? trackIndex,  String? title,  String? notes,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Bookmark():
return $default(_that.id,_that.bookId,_that.cfi,_that.positionMs,_that.trackIndex,_that.title,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int bookId,  String? cfi,  int? positionMs,  int? trackIndex,  String? title,  String? notes,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
return $default(_that.id,_that.bookId,_that.cfi,_that.positionMs,_that.trackIndex,_that.title,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bookmark implements Bookmark {
  const _Bookmark({required this.id, required this.bookId, this.cfi, this.positionMs, this.trackIndex, this.title, this.notes, this.createdAt});
  factory _Bookmark.fromJson(Map<String, dynamic> json) => _$BookmarkFromJson(json);

@override final  int id;
@override final  int bookId;
@override final  String? cfi;
@override final  int? positionMs;
@override final  int? trackIndex;
@override final  String? title;
@override final  String? notes;
@override final  DateTime? createdAt;

/// Create a copy of Bookmark
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarkCopyWith<_Bookmark> get copyWith => __$BookmarkCopyWithImpl<_Bookmark>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookmarkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bookmark&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.cfi, cfi) || other.cfi == cfi)&&(identical(other.positionMs, positionMs) || other.positionMs == positionMs)&&(identical(other.trackIndex, trackIndex) || other.trackIndex == trackIndex)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,bookId,cfi,positionMs,trackIndex,title,notes,createdAt);
}

@override
String toString() {
    return 'Bookmark(id: $id, bookId: $bookId, cfi: $cfi, positionMs: $positionMs, trackIndex: $trackIndex, title: $title, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookmarkCopyWith<$Res> implements $BookmarkCopyWith<$Res> {
  factory _$BookmarkCopyWith(_Bookmark value, $Res Function(_Bookmark) _then) = __$BookmarkCopyWithImpl;
@override @useResult
$Res call({
 int id, int bookId, String? cfi, int? positionMs, int? trackIndex, String? title, String? notes, DateTime? createdAt
});




}
/// @nodoc
class __$BookmarkCopyWithImpl<$Res>
    implements _$BookmarkCopyWith<$Res> {
  __$BookmarkCopyWithImpl(this._self, this._then);

  final _Bookmark _self;
  final $Res Function(_Bookmark) _then;

/// Create a copy of Bookmark
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookId = null,Object? cfi = freezed,Object? positionMs = freezed,Object? trackIndex = freezed,Object? title = freezed,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(_Bookmark(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,cfi: freezed == cfi ? _self.cfi : cfi // ignore: cast_nullable_to_non_nullable
as String?,positionMs: freezed == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
as int?,trackIndex: freezed == trackIndex ? _self.trackIndex : trackIndex // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Author {

 int get id; String get name; int get bookCount; String? get description; bool get hasPhoto;
/// Create a copy of Author
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorCopyWith<Author> get copyWith => _$AuthorCopyWithImpl<Author>(this as Author, _$identity);

  /// Serializes this Author to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Author;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Author&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.bookCount, _this.bookCount) || other.bookCount == _this.bookCount)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.hasPhoto, _this.hasPhoto) || other.hasPhoto == _this.hasPhoto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Author;
  return Object.hash(runtimeType,_this.id,_this.name,_this.bookCount,_this.description,_this.hasPhoto);
}

@override
String toString() {
  final _this = this as Author;
  return 'Author(id: ${_this.id}, name: ${_this.name}, bookCount: ${_this.bookCount}, description: ${_this.description}, hasPhoto: ${_this.hasPhoto})';
}


}

/// @nodoc
abstract mixin class $AuthorCopyWith<$Res>  {
  factory $AuthorCopyWith(Author value, $Res Function(Author) _then) = _$AuthorCopyWithImpl;
@useResult
$Res call({
 int id, String name, int bookCount, String? description, bool hasPhoto
});




}
/// @nodoc
class _$AuthorCopyWithImpl<$Res>
    implements $AuthorCopyWith<$Res> {
  _$AuthorCopyWithImpl(this._self, this._then);

  final Author _self;
  final $Res Function(Author) _then;

/// Create a copy of Author
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? bookCount = null,Object? description = freezed,Object? hasPhoto = null,}) {
  return _then(Author(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,hasPhoto: null == hasPhoto ? _self.hasPhoto : hasPhoto // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Author].
extension AuthorPatterns on Author {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Author value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Author() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Author value)  $default,){
final _that = this;
switch (_that) {
case _Author():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Author value)?  $default,){
final _that = this;
switch (_that) {
case _Author() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int bookCount,  String? description,  bool hasPhoto)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Author() when $default != null:
return $default(_that.id,_that.name,_that.bookCount,_that.description,_that.hasPhoto);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int bookCount,  String? description,  bool hasPhoto)  $default,) {final _that = this;
switch (_that) {
case _Author():
return $default(_that.id,_that.name,_that.bookCount,_that.description,_that.hasPhoto);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int bookCount,  String? description,  bool hasPhoto)?  $default,) {final _that = this;
switch (_that) {
case _Author() when $default != null:
return $default(_that.id,_that.name,_that.bookCount,_that.description,_that.hasPhoto);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Author implements Author {
  const _Author({required this.id, required this.name, this.bookCount = 0, this.description, this.hasPhoto = false});
  factory _Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey() final  int bookCount;
@override final  String? description;
@override@JsonKey() final  bool hasPhoto;

/// Create a copy of Author
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthorCopyWith<_Author> get copyWith => __$AuthorCopyWithImpl<_Author>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Author&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.bookCount, bookCount) || other.bookCount == bookCount)&&(identical(other.description, description) || other.description == description)&&(identical(other.hasPhoto, hasPhoto) || other.hasPhoto == hasPhoto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,bookCount,description,hasPhoto);
}

@override
String toString() {
    return 'Author(id: $id, name: $name, bookCount: $bookCount, description: $description, hasPhoto: $hasPhoto)';
}


}

/// @nodoc
abstract mixin class _$AuthorCopyWith<$Res> implements $AuthorCopyWith<$Res> {
  factory _$AuthorCopyWith(_Author value, $Res Function(_Author) _then) = __$AuthorCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int bookCount, String? description, bool hasPhoto
});




}
/// @nodoc
class __$AuthorCopyWithImpl<$Res>
    implements _$AuthorCopyWith<$Res> {
  __$AuthorCopyWithImpl(this._self, this._then);

  final _Author _self;
  final $Res Function(_Author) _then;

/// Create a copy of Author
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? bookCount = null,Object? description = freezed,Object? hasPhoto = null,}) {
  return _then(_Author(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,hasPhoto: null == hasPhoto ? _self.hasPhoto : hasPhoto // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Shelf {

 int get id; String get name; int get bookCount; String? get icon; bool get publicShelf;
/// Create a copy of Shelf
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfCopyWith<Shelf> get copyWith => _$ShelfCopyWithImpl<Shelf>(this as Shelf, _$identity);

  /// Serializes this Shelf to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Shelf;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Shelf&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.bookCount, _this.bookCount) || other.bookCount == _this.bookCount)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.publicShelf, _this.publicShelf) || other.publicShelf == _this.publicShelf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Shelf;
  return Object.hash(runtimeType,_this.id,_this.name,_this.bookCount,_this.icon,_this.publicShelf);
}

@override
String toString() {
  final _this = this as Shelf;
  return 'Shelf(id: ${_this.id}, name: ${_this.name}, bookCount: ${_this.bookCount}, icon: ${_this.icon}, publicShelf: ${_this.publicShelf})';
}


}

/// @nodoc
abstract mixin class $ShelfCopyWith<$Res>  {
  factory $ShelfCopyWith(Shelf value, $Res Function(Shelf) _then) = _$ShelfCopyWithImpl;
@useResult
$Res call({
 int id, String name, int bookCount, String? icon, bool publicShelf
});




}
/// @nodoc
class _$ShelfCopyWithImpl<$Res>
    implements $ShelfCopyWith<$Res> {
  _$ShelfCopyWithImpl(this._self, this._then);

  final Shelf _self;
  final $Res Function(Shelf) _then;

/// Create a copy of Shelf
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? bookCount = null,Object? icon = freezed,Object? publicShelf = null,}) {
  return _then(Shelf(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,publicShelf: null == publicShelf ? _self.publicShelf : publicShelf // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Shelf].
extension ShelfPatterns on Shelf {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Shelf value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Shelf() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Shelf value)  $default,){
final _that = this;
switch (_that) {
case _Shelf():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Shelf value)?  $default,){
final _that = this;
switch (_that) {
case _Shelf() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int bookCount,  String? icon,  bool publicShelf)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Shelf() when $default != null:
return $default(_that.id,_that.name,_that.bookCount,_that.icon,_that.publicShelf);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int bookCount,  String? icon,  bool publicShelf)  $default,) {final _that = this;
switch (_that) {
case _Shelf():
return $default(_that.id,_that.name,_that.bookCount,_that.icon,_that.publicShelf);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int bookCount,  String? icon,  bool publicShelf)?  $default,) {final _that = this;
switch (_that) {
case _Shelf() when $default != null:
return $default(_that.id,_that.name,_that.bookCount,_that.icon,_that.publicShelf);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Shelf implements Shelf {
  const _Shelf({required this.id, required this.name, this.bookCount = 0, this.icon, this.publicShelf = false});
  factory _Shelf.fromJson(Map<String, dynamic> json) => _$ShelfFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey() final  int bookCount;
@override final  String? icon;
@override@JsonKey() final  bool publicShelf;

/// Create a copy of Shelf
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfCopyWith<_Shelf> get copyWith => __$ShelfCopyWithImpl<_Shelf>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Shelf&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.bookCount, bookCount) || other.bookCount == bookCount)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.publicShelf, publicShelf) || other.publicShelf == publicShelf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,bookCount,icon,publicShelf);
}

@override
String toString() {
    return 'Shelf(id: $id, name: $name, bookCount: $bookCount, icon: $icon, publicShelf: $publicShelf)';
}


}

/// @nodoc
abstract mixin class _$ShelfCopyWith<$Res> implements $ShelfCopyWith<$Res> {
  factory _$ShelfCopyWith(_Shelf value, $Res Function(_Shelf) _then) = __$ShelfCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int bookCount, String? icon, bool publicShelf
});




}
/// @nodoc
class __$ShelfCopyWithImpl<$Res>
    implements _$ShelfCopyWith<$Res> {
  __$ShelfCopyWithImpl(this._self, this._then);

  final _Shelf _self;
  final $Res Function(_Shelf) _then;

/// Create a copy of Shelf
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? bookCount = null,Object? icon = freezed,Object? publicShelf = null,}) {
  return _then(_Shelf(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,publicShelf: null == publicShelf ? _self.publicShelf : publicShelf // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CurrentUser {

 int get id; String get username; String? get name; String? get email; String? get provisioningMethod; UserPermissions? get permissions; UserSettings? get userSettings;
/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentUserCopyWith<CurrentUser> get copyWith => _$CurrentUserCopyWithImpl<CurrentUser>(this as CurrentUser, _$identity);

  /// Serializes this CurrentUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurrentUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentUser&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.provisioningMethod, _this.provisioningMethod) || other.provisioningMethod == _this.provisioningMethod)&&(identical(other.permissions, _this.permissions) || other.permissions == _this.permissions)&&(identical(other.userSettings, _this.userSettings) || other.userSettings == _this.userSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurrentUser;
  return Object.hash(runtimeType,_this.id,_this.username,_this.name,_this.email,_this.provisioningMethod,_this.permissions,_this.userSettings);
}

@override
String toString() {
  final _this = this as CurrentUser;
  return 'CurrentUser(id: ${_this.id}, username: ${_this.username}, name: ${_this.name}, email: ${_this.email}, provisioningMethod: ${_this.provisioningMethod}, permissions: ${_this.permissions}, userSettings: ${_this.userSettings})';
}


}

/// @nodoc
abstract mixin class $CurrentUserCopyWith<$Res>  {
  factory $CurrentUserCopyWith(CurrentUser value, $Res Function(CurrentUser) _then) = _$CurrentUserCopyWithImpl;
@useResult
$Res call({
 int id, String username, String? name, String? email, String? provisioningMethod, UserPermissions? permissions, UserSettings? userSettings
});


$UserPermissionsCopyWith<$Res>? get permissions;$UserSettingsCopyWith<$Res>? get userSettings;

}
/// @nodoc
class _$CurrentUserCopyWithImpl<$Res>
    implements $CurrentUserCopyWith<$Res> {
  _$CurrentUserCopyWithImpl(this._self, this._then);

  final CurrentUser _self;
  final $Res Function(CurrentUser) _then;

/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? name = freezed,Object? email = freezed,Object? provisioningMethod = freezed,Object? permissions = freezed,Object? userSettings = freezed,}) {
  return _then(CurrentUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,provisioningMethod: freezed == provisioningMethod ? _self.provisioningMethod : provisioningMethod // ignore: cast_nullable_to_non_nullable
as String?,permissions: freezed == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as UserPermissions?,userSettings: freezed == userSettings ? _self.userSettings : userSettings // ignore: cast_nullable_to_non_nullable
as UserSettings?,
  ));
}
/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPermissionsCopyWith<$Res>? get permissions {
    if (_self.permissions == null) {
    return null;
  }

  return $UserPermissionsCopyWith<$Res>(_self.permissions!, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<$Res>? get userSettings {
    if (_self.userSettings == null) {
    return null;
  }

  return $UserSettingsCopyWith<$Res>(_self.userSettings!, (value) {
    return _then(_self.copyWith(userSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurrentUser].
extension CurrentUserPatterns on CurrentUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentUser value)  $default,){
final _that = this;
switch (_that) {
case _CurrentUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentUser value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String username,  String? name,  String? email,  String? provisioningMethod,  UserPermissions? permissions,  UserSettings? userSettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentUser() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.email,_that.provisioningMethod,_that.permissions,_that.userSettings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String username,  String? name,  String? email,  String? provisioningMethod,  UserPermissions? permissions,  UserSettings? userSettings)  $default,) {final _that = this;
switch (_that) {
case _CurrentUser():
return $default(_that.id,_that.username,_that.name,_that.email,_that.provisioningMethod,_that.permissions,_that.userSettings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String username,  String? name,  String? email,  String? provisioningMethod,  UserPermissions? permissions,  UserSettings? userSettings)?  $default,) {final _that = this;
switch (_that) {
case _CurrentUser() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.email,_that.provisioningMethod,_that.permissions,_that.userSettings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrentUser implements CurrentUser {
  const _CurrentUser({required this.id, required this.username, this.name, this.email, this.provisioningMethod, this.permissions, this.userSettings});
  factory _CurrentUser.fromJson(Map<String, dynamic> json) => _$CurrentUserFromJson(json);

@override final  int id;
@override final  String username;
@override final  String? name;
@override final  String? email;
@override final  String? provisioningMethod;
@override final  UserPermissions? permissions;
@override final  UserSettings? userSettings;

/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentUserCopyWith<_CurrentUser> get copyWith => __$CurrentUserCopyWithImpl<_CurrentUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.provisioningMethod, provisioningMethod) || other.provisioningMethod == provisioningMethod)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.userSettings, userSettings) || other.userSettings == userSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,username,name,email,provisioningMethod,permissions,userSettings);
}

@override
String toString() {
    return 'CurrentUser(id: $id, username: $username, name: $name, email: $email, provisioningMethod: $provisioningMethod, permissions: $permissions, userSettings: $userSettings)';
}


}

/// @nodoc
abstract mixin class _$CurrentUserCopyWith<$Res> implements $CurrentUserCopyWith<$Res> {
  factory _$CurrentUserCopyWith(_CurrentUser value, $Res Function(_CurrentUser) _then) = __$CurrentUserCopyWithImpl;
@override @useResult
$Res call({
 int id, String username, String? name, String? email, String? provisioningMethod, UserPermissions? permissions, UserSettings? userSettings
});


@override $UserPermissionsCopyWith<$Res>? get permissions;@override $UserSettingsCopyWith<$Res>? get userSettings;

}
/// @nodoc
class __$CurrentUserCopyWithImpl<$Res>
    implements _$CurrentUserCopyWith<$Res> {
  __$CurrentUserCopyWithImpl(this._self, this._then);

  final _CurrentUser _self;
  final $Res Function(_CurrentUser) _then;

/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? name = freezed,Object? email = freezed,Object? provisioningMethod = freezed,Object? permissions = freezed,Object? userSettings = freezed,}) {
  return _then(_CurrentUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,provisioningMethod: freezed == provisioningMethod ? _self.provisioningMethod : provisioningMethod // ignore: cast_nullable_to_non_nullable
as String?,permissions: freezed == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as UserPermissions?,userSettings: freezed == userSettings ? _self.userSettings : userSettings // ignore: cast_nullable_to_non_nullable
as UserSettings?,
  ));
}

/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPermissionsCopyWith<$Res>? get permissions {
    if (_self.permissions == null) {
    return null;
  }

  return $UserPermissionsCopyWith<$Res>(_self.permissions!, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<$Res>? get userSettings {
    if (_self.userSettings == null) {
    return null;
  }

  return $UserSettingsCopyWith<$Res>(_self.userSettings!, (value) {
    return _then(_self.copyWith(userSettings: value));
  });
}
}


/// @nodoc
mixin _$UserPermissions {

@JsonKey(name: 'admin') bool get isAdmin; bool get canDownload; bool get canUpload;
/// Create a copy of UserPermissions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPermissionsCopyWith<UserPermissions> get copyWith => _$UserPermissionsCopyWithImpl<UserPermissions>(this as UserPermissions, _$identity);

  /// Serializes this UserPermissions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserPermissions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPermissions&&(identical(other.isAdmin, _this.isAdmin) || other.isAdmin == _this.isAdmin)&&(identical(other.canDownload, _this.canDownload) || other.canDownload == _this.canDownload)&&(identical(other.canUpload, _this.canUpload) || other.canUpload == _this.canUpload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserPermissions;
  return Object.hash(runtimeType,_this.isAdmin,_this.canDownload,_this.canUpload);
}

@override
String toString() {
  final _this = this as UserPermissions;
  return 'UserPermissions(isAdmin: ${_this.isAdmin}, canDownload: ${_this.canDownload}, canUpload: ${_this.canUpload})';
}


}

/// @nodoc
abstract mixin class $UserPermissionsCopyWith<$Res>  {
  factory $UserPermissionsCopyWith(UserPermissions value, $Res Function(UserPermissions) _then) = _$UserPermissionsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'admin') bool isAdmin, bool canDownload, bool canUpload
});




}
/// @nodoc
class _$UserPermissionsCopyWithImpl<$Res>
    implements $UserPermissionsCopyWith<$Res> {
  _$UserPermissionsCopyWithImpl(this._self, this._then);

  final UserPermissions _self;
  final $Res Function(UserPermissions) _then;

/// Create a copy of UserPermissions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isAdmin = null,Object? canDownload = null,Object? canUpload = null,}) {
  return _then(UserPermissions(
isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,canDownload: null == canDownload ? _self.canDownload : canDownload // ignore: cast_nullable_to_non_nullable
as bool,canUpload: null == canUpload ? _self.canUpload : canUpload // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPermissions].
extension UserPermissionsPatterns on UserPermissions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPermissions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPermissions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPermissions value)  $default,){
final _that = this;
switch (_that) {
case _UserPermissions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPermissions value)?  $default,){
final _that = this;
switch (_that) {
case _UserPermissions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'admin')  bool isAdmin,  bool canDownload,  bool canUpload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPermissions() when $default != null:
return $default(_that.isAdmin,_that.canDownload,_that.canUpload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'admin')  bool isAdmin,  bool canDownload,  bool canUpload)  $default,) {final _that = this;
switch (_that) {
case _UserPermissions():
return $default(_that.isAdmin,_that.canDownload,_that.canUpload);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'admin')  bool isAdmin,  bool canDownload,  bool canUpload)?  $default,) {final _that = this;
switch (_that) {
case _UserPermissions() when $default != null:
return $default(_that.isAdmin,_that.canDownload,_that.canUpload);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPermissions implements UserPermissions {
  const _UserPermissions({@JsonKey(name: 'admin') this.isAdmin = false, this.canDownload = false, this.canUpload = false});
  factory _UserPermissions.fromJson(Map<String, dynamic> json) => _$UserPermissionsFromJson(json);

@override@JsonKey(name: 'admin') final  bool isAdmin;
@override@JsonKey() final  bool canDownload;
@override@JsonKey() final  bool canUpload;

/// Create a copy of UserPermissions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPermissionsCopyWith<_UserPermissions> get copyWith => __$UserPermissionsCopyWithImpl<_UserPermissions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPermissionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPermissions&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.canDownload, canDownload) || other.canDownload == canDownload)&&(identical(other.canUpload, canUpload) || other.canUpload == canUpload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,isAdmin,canDownload,canUpload);
}

@override
String toString() {
    return 'UserPermissions(isAdmin: $isAdmin, canDownload: $canDownload, canUpload: $canUpload)';
}


}

/// @nodoc
abstract mixin class _$UserPermissionsCopyWith<$Res> implements $UserPermissionsCopyWith<$Res> {
  factory _$UserPermissionsCopyWith(_UserPermissions value, $Res Function(_UserPermissions) _then) = __$UserPermissionsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'admin') bool isAdmin, bool canDownload, bool canUpload
});




}
/// @nodoc
class __$UserPermissionsCopyWithImpl<$Res>
    implements _$UserPermissionsCopyWith<$Res> {
  __$UserPermissionsCopyWithImpl(this._self, this._then);

  final _UserPermissions _self;
  final $Res Function(_UserPermissions) _then;

/// Create a copy of UserPermissions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isAdmin = null,Object? canDownload = null,Object? canUpload = null,}) {
  return _then(_UserPermissions(
isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,canDownload: null == canDownload ? _self.canDownload : canDownload // ignore: cast_nullable_to_non_nullable
as bool,canUpload: null == canUpload ? _self.canUpload : canUpload // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UserSettings {

 DashboardConfig? get dashboardConfig;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.dashboardConfig, _this.dashboardConfig) || other.dashboardConfig == _this.dashboardConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserSettings;
  return Object.hash(runtimeType,_this.dashboardConfig);
}

@override
String toString() {
  final _this = this as UserSettings;
  return 'UserSettings(dashboardConfig: ${_this.dashboardConfig})';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 DashboardConfig? dashboardConfig
});


$DashboardConfigCopyWith<$Res>? get dashboardConfig;

}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dashboardConfig = freezed,}) {
  return _then(UserSettings(
dashboardConfig: freezed == dashboardConfig ? _self.dashboardConfig : dashboardConfig // ignore: cast_nullable_to_non_nullable
as DashboardConfig?,
  ));
}
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardConfigCopyWith<$Res>? get dashboardConfig {
    if (_self.dashboardConfig == null) {
    return null;
  }

  return $DashboardConfigCopyWith<$Res>(_self.dashboardConfig!, (value) {
    return _then(_self.copyWith(dashboardConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserSettings].
extension UserSettingsPatterns on UserSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettings value)  $default,){
final _that = this;
switch (_that) {
case _UserSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DashboardConfig? dashboardConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.dashboardConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DashboardConfig? dashboardConfig)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.dashboardConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DashboardConfig? dashboardConfig)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.dashboardConfig);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettings implements UserSettings {
  const _UserSettings({this.dashboardConfig});
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

@override final  DashboardConfig? dashboardConfig;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.dashboardConfig, dashboardConfig) || other.dashboardConfig == dashboardConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,dashboardConfig);
}

@override
String toString() {
    return 'UserSettings(dashboardConfig: $dashboardConfig)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 DashboardConfig? dashboardConfig
});


@override $DashboardConfigCopyWith<$Res>? get dashboardConfig;

}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dashboardConfig = freezed,}) {
  return _then(_UserSettings(
dashboardConfig: freezed == dashboardConfig ? _self.dashboardConfig : dashboardConfig // ignore: cast_nullable_to_non_nullable
as DashboardConfig?,
  ));
}

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardConfigCopyWith<$Res>? get dashboardConfig {
    if (_self.dashboardConfig == null) {
    return null;
  }

  return $DashboardConfigCopyWith<$Res>(_self.dashboardConfig!, (value) {
    return _then(_self.copyWith(dashboardConfig: value));
  });
}
}


/// @nodoc
mixin _$DashboardScroller {

 String? get id; String get type; String? get title; bool get enabled; int get order; int? get maxItems; int? get magicShelfId; String? get sortField; String? get sortDirection;
/// Create a copy of DashboardScroller
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardScrollerCopyWith<DashboardScroller> get copyWith => _$DashboardScrollerCopyWithImpl<DashboardScroller>(this as DashboardScroller, _$identity);

  /// Serializes this DashboardScroller to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DashboardScroller;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardScroller&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.maxItems, _this.maxItems) || other.maxItems == _this.maxItems)&&(identical(other.magicShelfId, _this.magicShelfId) || other.magicShelfId == _this.magicShelfId)&&(identical(other.sortField, _this.sortField) || other.sortField == _this.sortField)&&(identical(other.sortDirection, _this.sortDirection) || other.sortDirection == _this.sortDirection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardScroller;
  return Object.hash(runtimeType,_this.id,_this.type,_this.title,_this.enabled,_this.order,_this.maxItems,_this.magicShelfId,_this.sortField,_this.sortDirection);
}

@override
String toString() {
  final _this = this as DashboardScroller;
  return 'DashboardScroller(id: ${_this.id}, type: ${_this.type}, title: ${_this.title}, enabled: ${_this.enabled}, order: ${_this.order}, maxItems: ${_this.maxItems}, magicShelfId: ${_this.magicShelfId}, sortField: ${_this.sortField}, sortDirection: ${_this.sortDirection})';
}


}

/// @nodoc
abstract mixin class $DashboardScrollerCopyWith<$Res>  {
  factory $DashboardScrollerCopyWith(DashboardScroller value, $Res Function(DashboardScroller) _then) = _$DashboardScrollerCopyWithImpl;
@useResult
$Res call({
 String? id, String type, String? title, bool enabled, int order, int? maxItems, int? magicShelfId, String? sortField, String? sortDirection
});




}
/// @nodoc
class _$DashboardScrollerCopyWithImpl<$Res>
    implements $DashboardScrollerCopyWith<$Res> {
  _$DashboardScrollerCopyWithImpl(this._self, this._then);

  final DashboardScroller _self;
  final $Res Function(DashboardScroller) _then;

/// Create a copy of DashboardScroller
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? type = null,Object? title = freezed,Object? enabled = null,Object? order = null,Object? maxItems = freezed,Object? magicShelfId = freezed,Object? sortField = freezed,Object? sortDirection = freezed,}) {
  return _then(DashboardScroller(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,maxItems: freezed == maxItems ? _self.maxItems : maxItems // ignore: cast_nullable_to_non_nullable
as int?,magicShelfId: freezed == magicShelfId ? _self.magicShelfId : magicShelfId // ignore: cast_nullable_to_non_nullable
as int?,sortField: freezed == sortField ? _self.sortField : sortField // ignore: cast_nullable_to_non_nullable
as String?,sortDirection: freezed == sortDirection ? _self.sortDirection : sortDirection // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardScroller].
extension DashboardScrollerPatterns on DashboardScroller {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardScroller value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardScroller() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardScroller value)  $default,){
final _that = this;
switch (_that) {
case _DashboardScroller():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardScroller value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardScroller() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String type,  String? title,  bool enabled,  int order,  int? maxItems,  int? magicShelfId,  String? sortField,  String? sortDirection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardScroller() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.enabled,_that.order,_that.maxItems,_that.magicShelfId,_that.sortField,_that.sortDirection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String type,  String? title,  bool enabled,  int order,  int? maxItems,  int? magicShelfId,  String? sortField,  String? sortDirection)  $default,) {final _that = this;
switch (_that) {
case _DashboardScroller():
return $default(_that.id,_that.type,_that.title,_that.enabled,_that.order,_that.maxItems,_that.magicShelfId,_that.sortField,_that.sortDirection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String type,  String? title,  bool enabled,  int order,  int? maxItems,  int? magicShelfId,  String? sortField,  String? sortDirection)?  $default,) {final _that = this;
switch (_that) {
case _DashboardScroller() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.enabled,_that.order,_that.maxItems,_that.magicShelfId,_that.sortField,_that.sortDirection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardScroller implements DashboardScroller {
  const _DashboardScroller({this.id, required this.type, this.title, this.enabled = true, this.order = 0, this.maxItems, this.magicShelfId, this.sortField, this.sortDirection});
  factory _DashboardScroller.fromJson(Map<String, dynamic> json) => _$DashboardScrollerFromJson(json);

@override final  String? id;
@override final  String type;
@override final  String? title;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  int order;
@override final  int? maxItems;
@override final  int? magicShelfId;
@override final  String? sortField;
@override final  String? sortDirection;

/// Create a copy of DashboardScroller
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardScrollerCopyWith<_DashboardScroller> get copyWith => __$DashboardScrollerCopyWithImpl<_DashboardScroller>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardScrollerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardScroller&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.order, order) || other.order == order)&&(identical(other.maxItems, maxItems) || other.maxItems == maxItems)&&(identical(other.magicShelfId, magicShelfId) || other.magicShelfId == magicShelfId)&&(identical(other.sortField, sortField) || other.sortField == sortField)&&(identical(other.sortDirection, sortDirection) || other.sortDirection == sortDirection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,title,enabled,order,maxItems,magicShelfId,sortField,sortDirection);
}

@override
String toString() {
    return 'DashboardScroller(id: $id, type: $type, title: $title, enabled: $enabled, order: $order, maxItems: $maxItems, magicShelfId: $magicShelfId, sortField: $sortField, sortDirection: $sortDirection)';
}


}

/// @nodoc
abstract mixin class _$DashboardScrollerCopyWith<$Res> implements $DashboardScrollerCopyWith<$Res> {
  factory _$DashboardScrollerCopyWith(_DashboardScroller value, $Res Function(_DashboardScroller) _then) = __$DashboardScrollerCopyWithImpl;
@override @useResult
$Res call({
 String? id, String type, String? title, bool enabled, int order, int? maxItems, int? magicShelfId, String? sortField, String? sortDirection
});




}
/// @nodoc
class __$DashboardScrollerCopyWithImpl<$Res>
    implements _$DashboardScrollerCopyWith<$Res> {
  __$DashboardScrollerCopyWithImpl(this._self, this._then);

  final _DashboardScroller _self;
  final $Res Function(_DashboardScroller) _then;

/// Create a copy of DashboardScroller
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? type = null,Object? title = freezed,Object? enabled = null,Object? order = null,Object? maxItems = freezed,Object? magicShelfId = freezed,Object? sortField = freezed,Object? sortDirection = freezed,}) {
  return _then(_DashboardScroller(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,maxItems: freezed == maxItems ? _self.maxItems : maxItems // ignore: cast_nullable_to_non_nullable
as int?,magicShelfId: freezed == magicShelfId ? _self.magicShelfId : magicShelfId // ignore: cast_nullable_to_non_nullable
as int?,sortField: freezed == sortField ? _self.sortField : sortField // ignore: cast_nullable_to_non_nullable
as String?,sortDirection: freezed == sortDirection ? _self.sortDirection : sortDirection // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DashboardConfig {

 List<DashboardScroller> get scrollers;
/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardConfigCopyWith<DashboardConfig> get copyWith => _$DashboardConfigCopyWithImpl<DashboardConfig>(this as DashboardConfig, _$identity);

  /// Serializes this DashboardConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DashboardConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardConfig&&const DeepCollectionEquality().equals(other.scrollers, _this.scrollers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardConfig;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.scrollers));
}

@override
String toString() {
  final _this = this as DashboardConfig;
  return 'DashboardConfig(scrollers: ${_this.scrollers})';
}


}

/// @nodoc
abstract mixin class $DashboardConfigCopyWith<$Res>  {
  factory $DashboardConfigCopyWith(DashboardConfig value, $Res Function(DashboardConfig) _then) = _$DashboardConfigCopyWithImpl;
@useResult
$Res call({
 List<DashboardScroller> scrollers
});




}
/// @nodoc
class _$DashboardConfigCopyWithImpl<$Res>
    implements $DashboardConfigCopyWith<$Res> {
  _$DashboardConfigCopyWithImpl(this._self, this._then);

  final DashboardConfig _self;
  final $Res Function(DashboardConfig) _then;

/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scrollers = null,}) {
  return _then(DashboardConfig(
scrollers: null == scrollers ? _self.scrollers : scrollers // ignore: cast_nullable_to_non_nullable
as List<DashboardScroller>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardConfig].
extension DashboardConfigPatterns on DashboardConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardConfig value)  $default,){
final _that = this;
switch (_that) {
case _DashboardConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DashboardScroller> scrollers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
return $default(_that.scrollers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DashboardScroller> scrollers)  $default,) {final _that = this;
switch (_that) {
case _DashboardConfig():
return $default(_that.scrollers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DashboardScroller> scrollers)?  $default,) {final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
return $default(_that.scrollers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardConfig implements DashboardConfig {
  const _DashboardConfig({ List<DashboardScroller> scrollers = const []}): _scrollers = scrollers;
  factory _DashboardConfig.fromJson(Map<String, dynamic> json) => _$DashboardConfigFromJson(json);

 final  List<DashboardScroller> _scrollers;
@override@JsonKey() List<DashboardScroller> get scrollers {
  if (_scrollers is EqualUnmodifiableListView) return _scrollers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scrollers);
}


/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardConfigCopyWith<_DashboardConfig> get copyWith => __$DashboardConfigCopyWithImpl<_DashboardConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardConfig&&const DeepCollectionEquality().equals(other.scrollers, _scrollers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_scrollers));
}

@override
String toString() {
    return 'DashboardConfig(scrollers: $scrollers)';
}


}

/// @nodoc
abstract mixin class _$DashboardConfigCopyWith<$Res> implements $DashboardConfigCopyWith<$Res> {
  factory _$DashboardConfigCopyWith(_DashboardConfig value, $Res Function(_DashboardConfig) _then) = __$DashboardConfigCopyWithImpl;
@override @useResult
$Res call({
 List<DashboardScroller> scrollers
});




}
/// @nodoc
class __$DashboardConfigCopyWithImpl<$Res>
    implements _$DashboardConfigCopyWith<$Res> {
  __$DashboardConfigCopyWithImpl(this._self, this._then);

  final _DashboardConfig _self;
  final $Res Function(_DashboardConfig) _then;

/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scrollers = null,}) {
  return _then(_DashboardConfig(
scrollers: null == scrollers ? _self._scrollers : scrollers // ignore: cast_nullable_to_non_nullable
as List<DashboardScroller>,
  ));
}


}


/// @nodoc
mixin _$MagicShelf {

 int get id; String get name; String? get icon; String? get iconType; bool get publicShelf;
/// Create a copy of MagicShelf
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MagicShelfCopyWith<MagicShelf> get copyWith => _$MagicShelfCopyWithImpl<MagicShelf>(this as MagicShelf, _$identity);

  /// Serializes this MagicShelf to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MagicShelf;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MagicShelf&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.iconType, _this.iconType) || other.iconType == _this.iconType)&&(identical(other.publicShelf, _this.publicShelf) || other.publicShelf == _this.publicShelf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MagicShelf;
  return Object.hash(runtimeType,_this.id,_this.name,_this.icon,_this.iconType,_this.publicShelf);
}

@override
String toString() {
  final _this = this as MagicShelf;
  return 'MagicShelf(id: ${_this.id}, name: ${_this.name}, icon: ${_this.icon}, iconType: ${_this.iconType}, publicShelf: ${_this.publicShelf})';
}


}

/// @nodoc
abstract mixin class $MagicShelfCopyWith<$Res>  {
  factory $MagicShelfCopyWith(MagicShelf value, $Res Function(MagicShelf) _then) = _$MagicShelfCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? icon, String? iconType, bool publicShelf
});




}
/// @nodoc
class _$MagicShelfCopyWithImpl<$Res>
    implements $MagicShelfCopyWith<$Res> {
  _$MagicShelfCopyWithImpl(this._self, this._then);

  final MagicShelf _self;
  final $Res Function(MagicShelf) _then;

/// Create a copy of MagicShelf
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? iconType = freezed,Object? publicShelf = null,}) {
  return _then(MagicShelf(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconType: freezed == iconType ? _self.iconType : iconType // ignore: cast_nullable_to_non_nullable
as String?,publicShelf: null == publicShelf ? _self.publicShelf : publicShelf // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MagicShelf].
extension MagicShelfPatterns on MagicShelf {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MagicShelf value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MagicShelf() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MagicShelf value)  $default,){
final _that = this;
switch (_that) {
case _MagicShelf():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MagicShelf value)?  $default,){
final _that = this;
switch (_that) {
case _MagicShelf() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? icon,  String? iconType,  bool publicShelf)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MagicShelf() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.iconType,_that.publicShelf);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? icon,  String? iconType,  bool publicShelf)  $default,) {final _that = this;
switch (_that) {
case _MagicShelf():
return $default(_that.id,_that.name,_that.icon,_that.iconType,_that.publicShelf);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? icon,  String? iconType,  bool publicShelf)?  $default,) {final _that = this;
switch (_that) {
case _MagicShelf() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.iconType,_that.publicShelf);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MagicShelf implements MagicShelf {
  const _MagicShelf({required this.id, required this.name, this.icon, this.iconType, this.publicShelf = false});
  factory _MagicShelf.fromJson(Map<String, dynamic> json) => _$MagicShelfFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? icon;
@override final  String? iconType;
@override@JsonKey() final  bool publicShelf;

/// Create a copy of MagicShelf
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MagicShelfCopyWith<_MagicShelf> get copyWith => __$MagicShelfCopyWithImpl<_MagicShelf>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MagicShelfToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MagicShelf&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.iconType, iconType) || other.iconType == iconType)&&(identical(other.publicShelf, publicShelf) || other.publicShelf == publicShelf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,icon,iconType,publicShelf);
}

@override
String toString() {
    return 'MagicShelf(id: $id, name: $name, icon: $icon, iconType: $iconType, publicShelf: $publicShelf)';
}


}

/// @nodoc
abstract mixin class _$MagicShelfCopyWith<$Res> implements $MagicShelfCopyWith<$Res> {
  factory _$MagicShelfCopyWith(_MagicShelf value, $Res Function(_MagicShelf) _then) = __$MagicShelfCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? icon, String? iconType, bool publicShelf
});




}
/// @nodoc
class __$MagicShelfCopyWithImpl<$Res>
    implements _$MagicShelfCopyWith<$Res> {
  __$MagicShelfCopyWithImpl(this._self, this._then);

  final _MagicShelf _self;
  final $Res Function(_MagicShelf) _then;

/// Create a copy of MagicShelf
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? iconType = freezed,Object? publicShelf = null,}) {
  return _then(_MagicShelf(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,iconType: freezed == iconType ? _self.iconType : iconType // ignore: cast_nullable_to_non_nullable
as String?,publicShelf: null == publicShelf ? _self.publicShelf : publicShelf // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CountedOption {

 String get name; int get count;
/// Create a copy of CountedOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountedOptionCopyWith<CountedOption> get copyWith => _$CountedOptionCopyWithImpl<CountedOption>(this as CountedOption, _$identity);

  /// Serializes this CountedOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CountedOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountedOption&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.count, _this.count) || other.count == _this.count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CountedOption;
  return Object.hash(runtimeType,_this.name,_this.count);
}

@override
String toString() {
  final _this = this as CountedOption;
  return 'CountedOption(name: ${_this.name}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $CountedOptionCopyWith<$Res>  {
  factory $CountedOptionCopyWith(CountedOption value, $Res Function(CountedOption) _then) = _$CountedOptionCopyWithImpl;
@useResult
$Res call({
 String name, int count
});




}
/// @nodoc
class _$CountedOptionCopyWithImpl<$Res>
    implements $CountedOptionCopyWith<$Res> {
  _$CountedOptionCopyWithImpl(this._self, this._then);

  final CountedOption _self;
  final $Res Function(CountedOption) _then;

/// Create a copy of CountedOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? count = null,}) {
  return _then(CountedOption(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CountedOption].
extension CountedOptionPatterns on CountedOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountedOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountedOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountedOption value)  $default,){
final _that = this;
switch (_that) {
case _CountedOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountedOption value)?  $default,){
final _that = this;
switch (_that) {
case _CountedOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountedOption() when $default != null:
return $default(_that.name,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int count)  $default,) {final _that = this;
switch (_that) {
case _CountedOption():
return $default(_that.name,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int count)?  $default,) {final _that = this;
switch (_that) {
case _CountedOption() when $default != null:
return $default(_that.name,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountedOption implements CountedOption {
  const _CountedOption({required this.name, this.count = 0});
  factory _CountedOption.fromJson(Map<String, dynamic> json) => _$CountedOptionFromJson(json);

@override final  String name;
@override@JsonKey() final  int count;

/// Create a copy of CountedOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountedOptionCopyWith<_CountedOption> get copyWith => __$CountedOptionCopyWithImpl<_CountedOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountedOptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountedOption&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,count);
}

@override
String toString() {
    return 'CountedOption(name: $name, count: $count)';
}


}

/// @nodoc
abstract mixin class _$CountedOptionCopyWith<$Res> implements $CountedOptionCopyWith<$Res> {
  factory _$CountedOptionCopyWith(_CountedOption value, $Res Function(_CountedOption) _then) = __$CountedOptionCopyWithImpl;
@override @useResult
$Res call({
 String name, int count
});




}
/// @nodoc
class __$CountedOptionCopyWithImpl<$Res>
    implements _$CountedOptionCopyWith<$Res> {
  __$CountedOptionCopyWithImpl(this._self, this._then);

  final _CountedOption _self;
  final $Res Function(_CountedOption) _then;

/// Create a copy of CountedOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? count = null,}) {
  return _then(_CountedOption(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FilterOptions {

 List<CountedOption> get authors; List<CountedOption> get fileTypes; List<CountedOption> get readStatuses; List<CountedOption> get series; List<CountedOption> get narrators;
/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterOptionsCopyWith<FilterOptions> get copyWith => _$FilterOptionsCopyWithImpl<FilterOptions>(this as FilterOptions, _$identity);

  /// Serializes this FilterOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FilterOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterOptions&&const DeepCollectionEquality().equals(other.authors, _this.authors)&&const DeepCollectionEquality().equals(other.fileTypes, _this.fileTypes)&&const DeepCollectionEquality().equals(other.readStatuses, _this.readStatuses)&&const DeepCollectionEquality().equals(other.series, _this.series)&&const DeepCollectionEquality().equals(other.narrators, _this.narrators));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FilterOptions;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.authors),const DeepCollectionEquality().hash(_this.fileTypes),const DeepCollectionEquality().hash(_this.readStatuses),const DeepCollectionEquality().hash(_this.series),const DeepCollectionEquality().hash(_this.narrators));
}

@override
String toString() {
  final _this = this as FilterOptions;
  return 'FilterOptions(authors: ${_this.authors}, fileTypes: ${_this.fileTypes}, readStatuses: ${_this.readStatuses}, series: ${_this.series}, narrators: ${_this.narrators})';
}


}

/// @nodoc
abstract mixin class $FilterOptionsCopyWith<$Res>  {
  factory $FilterOptionsCopyWith(FilterOptions value, $Res Function(FilterOptions) _then) = _$FilterOptionsCopyWithImpl;
@useResult
$Res call({
 List<CountedOption> authors, List<CountedOption> fileTypes, List<CountedOption> readStatuses, List<CountedOption> series, List<CountedOption> narrators
});




}
/// @nodoc
class _$FilterOptionsCopyWithImpl<$Res>
    implements $FilterOptionsCopyWith<$Res> {
  _$FilterOptionsCopyWithImpl(this._self, this._then);

  final FilterOptions _self;
  final $Res Function(FilterOptions) _then;

/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authors = null,Object? fileTypes = null,Object? readStatuses = null,Object? series = null,Object? narrators = null,}) {
  return _then(FilterOptions(
authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,fileTypes: null == fileTypes ? _self.fileTypes : fileTypes // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,readStatuses: null == readStatuses ? _self.readStatuses : readStatuses // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,narrators: null == narrators ? _self.narrators : narrators // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,
  ));
}

}


/// Adds pattern-matching-related methods to [FilterOptions].
extension FilterOptionsPatterns on FilterOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilterOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilterOptions value)  $default,){
final _that = this;
switch (_that) {
case _FilterOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilterOptions value)?  $default,){
final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CountedOption> authors,  List<CountedOption> fileTypes,  List<CountedOption> readStatuses,  List<CountedOption> series,  List<CountedOption> narrators)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
return $default(_that.authors,_that.fileTypes,_that.readStatuses,_that.series,_that.narrators);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CountedOption> authors,  List<CountedOption> fileTypes,  List<CountedOption> readStatuses,  List<CountedOption> series,  List<CountedOption> narrators)  $default,) {final _that = this;
switch (_that) {
case _FilterOptions():
return $default(_that.authors,_that.fileTypes,_that.readStatuses,_that.series,_that.narrators);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CountedOption> authors,  List<CountedOption> fileTypes,  List<CountedOption> readStatuses,  List<CountedOption> series,  List<CountedOption> narrators)?  $default,) {final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
return $default(_that.authors,_that.fileTypes,_that.readStatuses,_that.series,_that.narrators);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FilterOptions implements FilterOptions {
  const _FilterOptions({ List<CountedOption> authors = const [],  List<CountedOption> fileTypes = const [],  List<CountedOption> readStatuses = const [],  List<CountedOption> series = const [],  List<CountedOption> narrators = const []}): _authors = authors,_fileTypes = fileTypes,_readStatuses = readStatuses,_series = series,_narrators = narrators;
  factory _FilterOptions.fromJson(Map<String, dynamic> json) => _$FilterOptionsFromJson(json);

 final  List<CountedOption> _authors;
@override@JsonKey() List<CountedOption> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

 final  List<CountedOption> _fileTypes;
@override@JsonKey() List<CountedOption> get fileTypes {
  if (_fileTypes is EqualUnmodifiableListView) return _fileTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fileTypes);
}

 final  List<CountedOption> _readStatuses;
@override@JsonKey() List<CountedOption> get readStatuses {
  if (_readStatuses is EqualUnmodifiableListView) return _readStatuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readStatuses);
}

 final  List<CountedOption> _series;
@override@JsonKey() List<CountedOption> get series {
  if (_series is EqualUnmodifiableListView) return _series;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_series);
}

 final  List<CountedOption> _narrators;
@override@JsonKey() List<CountedOption> get narrators {
  if (_narrators is EqualUnmodifiableListView) return _narrators;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_narrators);
}


/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterOptionsCopyWith<_FilterOptions> get copyWith => __$FilterOptionsCopyWithImpl<_FilterOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilterOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterOptions&&const DeepCollectionEquality().equals(other.authors, _authors)&&const DeepCollectionEquality().equals(other.fileTypes, _fileTypes)&&const DeepCollectionEquality().equals(other.readStatuses, _readStatuses)&&const DeepCollectionEquality().equals(other.series, _series)&&const DeepCollectionEquality().equals(other.narrators, _narrators));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_authors),const DeepCollectionEquality().hash(_fileTypes),const DeepCollectionEquality().hash(_readStatuses),const DeepCollectionEquality().hash(_series),const DeepCollectionEquality().hash(_narrators));
}

@override
String toString() {
    return 'FilterOptions(authors: $authors, fileTypes: $fileTypes, readStatuses: $readStatuses, series: $series, narrators: $narrators)';
}


}

/// @nodoc
abstract mixin class _$FilterOptionsCopyWith<$Res> implements $FilterOptionsCopyWith<$Res> {
  factory _$FilterOptionsCopyWith(_FilterOptions value, $Res Function(_FilterOptions) _then) = __$FilterOptionsCopyWithImpl;
@override @useResult
$Res call({
 List<CountedOption> authors, List<CountedOption> fileTypes, List<CountedOption> readStatuses, List<CountedOption> series, List<CountedOption> narrators
});




}
/// @nodoc
class __$FilterOptionsCopyWithImpl<$Res>
    implements _$FilterOptionsCopyWith<$Res> {
  __$FilterOptionsCopyWithImpl(this._self, this._then);

  final _FilterOptions _self;
  final $Res Function(_FilterOptions) _then;

/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authors = null,Object? fileTypes = null,Object? readStatuses = null,Object? series = null,Object? narrators = null,}) {
  return _then(_FilterOptions(
authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,fileTypes: null == fileTypes ? _self._fileTypes : fileTypes // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,readStatuses: null == readStatuses ? _self._readStatuses : readStatuses // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,series: null == series ? _self._series : series // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,narrators: null == narrators ? _self._narrators : narrators // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,
  ));
}


}

// dart format on
