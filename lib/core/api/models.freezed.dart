// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthTokens {

 String get accessToken; String get refreshToken;
/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthTokensCopyWith<AuthTokens> get copyWith => _$AuthTokensCopyWithImpl<AuthTokens>(this as AuthTokens, _$identity);

  /// Serializes this AuthTokens to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthTokens&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken);

@override
String toString() {
  return 'AuthTokens(accessToken: $accessToken, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $AuthTokensCopyWith<$Res>  {
  factory $AuthTokensCopyWith(AuthTokens value, $Res Function(AuthTokens) _then) = _$AuthTokensCopyWithImpl;
@useResult
$Res call({
 String accessToken, String refreshToken
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
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.accessToken,_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _AuthTokens():
return $default(_that.accessToken,_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.accessToken,_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthTokens implements AuthTokens {
  const _AuthTokens({required this.accessToken, required this.refreshToken});
  factory _AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);

@override final  String accessToken;
@override final  String refreshToken;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthTokens&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken);

@override
String toString() {
  return 'AuthTokens(accessToken: $accessToken, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$AuthTokensCopyWith<$Res> implements $AuthTokensCopyWith<$Res> {
  factory _$AuthTokensCopyWith(_AuthTokens value, $Res Function(_AuthTokens) _then) = __$AuthTokensCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, String refreshToken
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
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,}) {
  return _then(_AuthTokens(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Library&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.bookCount, bookCount) || other.bookCount == bookCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,bookCount);

@override
String toString() {
  return 'Library(id: $id, name: $name, icon: $icon, bookCount: $bookCount)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,id,name,icon,bookCount);

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

 int get id; String get title; List<String> get authors; String? get seriesName; double? get seriesNumber; int? get libraryId; String? get narrator; String? get description;
/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookCopyWith<Book> get copyWith => _$BookCopyWithImpl<Book>(this as Book, _$identity);

  /// Serializes this Book to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Book&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.authors, authors)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.seriesNumber, seriesNumber) || other.seriesNumber == seriesNumber)&&(identical(other.libraryId, libraryId) || other.libraryId == libraryId)&&(identical(other.narrator, narrator) || other.narrator == narrator)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(authors),seriesName,seriesNumber,libraryId,narrator,description);

@override
String toString() {
  return 'Book(id: $id, title: $title, authors: $authors, seriesName: $seriesName, seriesNumber: $seriesNumber, libraryId: $libraryId, narrator: $narrator, description: $description)';
}


}

/// @nodoc
abstract mixin class $BookCopyWith<$Res>  {
  factory $BookCopyWith(Book value, $Res Function(Book) _then) = _$BookCopyWithImpl;
@useResult
$Res call({
 int id, String title, List<String> authors, String? seriesName, double? seriesNumber, int? libraryId, String? narrator, String? description
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? authors = null,Object? seriesName = freezed,Object? seriesNumber = freezed,Object? libraryId = freezed,Object? narrator = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,seriesNumber: freezed == seriesNumber ? _self.seriesNumber : seriesNumber // ignore: cast_nullable_to_non_nullable
as double?,libraryId: freezed == libraryId ? _self.libraryId : libraryId // ignore: cast_nullable_to_non_nullable
as int?,narrator: freezed == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  List<String> authors,  String? seriesName,  double? seriesNumber,  int? libraryId,  String? narrator,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.authors,_that.seriesName,_that.seriesNumber,_that.libraryId,_that.narrator,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  List<String> authors,  String? seriesName,  double? seriesNumber,  int? libraryId,  String? narrator,  String? description)  $default,) {final _that = this;
switch (_that) {
case _Book():
return $default(_that.id,_that.title,_that.authors,_that.seriesName,_that.seriesNumber,_that.libraryId,_that.narrator,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  List<String> authors,  String? seriesName,  double? seriesNumber,  int? libraryId,  String? narrator,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.authors,_that.seriesName,_that.seriesNumber,_that.libraryId,_that.narrator,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Book implements Book {
  const _Book({required this.id, required this.title, final  List<String> authors = const [], this.seriesName, this.seriesNumber, this.libraryId, this.narrator, this.description}): _authors = authors;
  factory _Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

@override final  int id;
@override final  String title;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Book&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._authors, _authors)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.seriesNumber, seriesNumber) || other.seriesNumber == seriesNumber)&&(identical(other.libraryId, libraryId) || other.libraryId == libraryId)&&(identical(other.narrator, narrator) || other.narrator == narrator)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(_authors),seriesName,seriesNumber,libraryId,narrator,description);

@override
String toString() {
  return 'Book(id: $id, title: $title, authors: $authors, seriesName: $seriesName, seriesNumber: $seriesNumber, libraryId: $libraryId, narrator: $narrator, description: $description)';
}


}

/// @nodoc
abstract mixin class _$BookCopyWith<$Res> implements $BookCopyWith<$Res> {
  factory _$BookCopyWith(_Book value, $Res Function(_Book) _then) = __$BookCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, List<String> authors, String? seriesName, double? seriesNumber, int? libraryId, String? narrator, String? description
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? authors = null,Object? seriesName = freezed,Object? seriesNumber = freezed,Object? libraryId = freezed,Object? narrator = freezed,Object? description = freezed,}) {
  return _then(_Book(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,seriesNumber: freezed == seriesNumber ? _self.seriesNumber : seriesNumber // ignore: cast_nullable_to_non_nullable
as double?,libraryId: freezed == libraryId ? _self.libraryId : libraryId // ignore: cast_nullable_to_non_nullable
as int?,narrator: freezed == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AudiobookInfo {

 int get bookId; String? get narrator; int get durationMs;// Whether this audiobook is stored as multiple files (one AudioSource
// per track) vs. a single file — determines which stream endpoint(s) to
// use. There's no separate "track count" field; folderBased plus
// tracks.length is the only way to know.
 bool get folderBased; List<AudiobookChapter> get chapters; List<AudiobookTrack> get tracks;
/// Create a copy of AudiobookInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudiobookInfoCopyWith<AudiobookInfo> get copyWith => _$AudiobookInfoCopyWithImpl<AudiobookInfo>(this as AudiobookInfo, _$identity);

  /// Serializes this AudiobookInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudiobookInfo&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.narrator, narrator) || other.narrator == narrator)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.folderBased, folderBased) || other.folderBased == folderBased)&&const DeepCollectionEquality().equals(other.chapters, chapters)&&const DeepCollectionEquality().equals(other.tracks, tracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,narrator,durationMs,folderBased,const DeepCollectionEquality().hash(chapters),const DeepCollectionEquality().hash(tracks));

@override
String toString() {
  return 'AudiobookInfo(bookId: $bookId, narrator: $narrator, durationMs: $durationMs, folderBased: $folderBased, chapters: $chapters, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class $AudiobookInfoCopyWith<$Res>  {
  factory $AudiobookInfoCopyWith(AudiobookInfo value, $Res Function(AudiobookInfo) _then) = _$AudiobookInfoCopyWithImpl;
@useResult
$Res call({
 int bookId, String? narrator, int durationMs, bool folderBased, List<AudiobookChapter> chapters, List<AudiobookTrack> tracks
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
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? narrator = freezed,Object? durationMs = null,Object? folderBased = null,Object? chapters = null,Object? tracks = null,}) {
  return _then(_self.copyWith(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,narrator: freezed == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookId,  String? narrator,  int durationMs,  bool folderBased,  List<AudiobookChapter> chapters,  List<AudiobookTrack> tracks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudiobookInfo() when $default != null:
return $default(_that.bookId,_that.narrator,_that.durationMs,_that.folderBased,_that.chapters,_that.tracks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookId,  String? narrator,  int durationMs,  bool folderBased,  List<AudiobookChapter> chapters,  List<AudiobookTrack> tracks)  $default,) {final _that = this;
switch (_that) {
case _AudiobookInfo():
return $default(_that.bookId,_that.narrator,_that.durationMs,_that.folderBased,_that.chapters,_that.tracks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookId,  String? narrator,  int durationMs,  bool folderBased,  List<AudiobookChapter> chapters,  List<AudiobookTrack> tracks)?  $default,) {final _that = this;
switch (_that) {
case _AudiobookInfo() when $default != null:
return $default(_that.bookId,_that.narrator,_that.durationMs,_that.folderBased,_that.chapters,_that.tracks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AudiobookInfo implements AudiobookInfo {
  const _AudiobookInfo({required this.bookId, this.narrator, required this.durationMs, this.folderBased = false, final  List<AudiobookChapter> chapters = const [], final  List<AudiobookTrack> tracks = const []}): _chapters = chapters,_tracks = tracks;
  factory _AudiobookInfo.fromJson(Map<String, dynamic> json) => _$AudiobookInfoFromJson(json);

@override final  int bookId;
@override final  String? narrator;
@override final  int durationMs;
// Whether this audiobook is stored as multiple files (one AudioSource
// per track) vs. a single file — determines which stream endpoint(s) to
// use. There's no separate "track count" field; folderBased plus
// tracks.length is the only way to know.
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudiobookInfo&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.narrator, narrator) || other.narrator == narrator)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.folderBased, folderBased) || other.folderBased == folderBased)&&const DeepCollectionEquality().equals(other._chapters, _chapters)&&const DeepCollectionEquality().equals(other._tracks, _tracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookId,narrator,durationMs,folderBased,const DeepCollectionEquality().hash(_chapters),const DeepCollectionEquality().hash(_tracks));

@override
String toString() {
  return 'AudiobookInfo(bookId: $bookId, narrator: $narrator, durationMs: $durationMs, folderBased: $folderBased, chapters: $chapters, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class _$AudiobookInfoCopyWith<$Res> implements $AudiobookInfoCopyWith<$Res> {
  factory _$AudiobookInfoCopyWith(_AudiobookInfo value, $Res Function(_AudiobookInfo) _then) = __$AudiobookInfoCopyWithImpl;
@override @useResult
$Res call({
 int bookId, String? narrator, int durationMs, bool folderBased, List<AudiobookChapter> chapters, List<AudiobookTrack> tracks
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
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? narrator = freezed,Object? durationMs = null,Object? folderBased = null,Object? chapters = null,Object? tracks = null,}) {
  return _then(_AudiobookInfo(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,narrator: freezed == narrator ? _self.narrator : narrator // ignore: cast_nullable_to_non_nullable
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudiobookChapter&&(identical(other.index, index) || other.index == index)&&(identical(other.title, title) || other.title == title)&&(identical(other.startTimeMs, startTimeMs) || other.startTimeMs == startTimeMs)&&(identical(other.endTimeMs, endTimeMs) || other.endTimeMs == endTimeMs)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,title,startTimeMs,endTimeMs,durationMs);

@override
String toString() {
  return 'AudiobookChapter(index: $index, title: $title, startTimeMs: $startTimeMs, endTimeMs: $endTimeMs, durationMs: $durationMs)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,index,title,startTimeMs,endTimeMs,durationMs);

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudiobookTrack&&(identical(other.index, index) || other.index == index)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.title, title) || other.title == title)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.cumulativeStartMs, cumulativeStartMs) || other.cumulativeStartMs == cumulativeStartMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,fileName,title,durationMs,fileSizeBytes,cumulativeStartMs);

@override
String toString() {
  return 'AudiobookTrack(index: $index, fileName: $fileName, title: $title, durationMs: $durationMs, fileSizeBytes: $fileSizeBytes, cumulativeStartMs: $cumulativeStartMs)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,index,fileName,title,durationMs,fileSizeBytes,cumulativeStartMs);

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudiobookProgress&&(identical(other.positionMs, positionMs) || other.positionMs == positionMs)&&(identical(other.trackIndex, trackIndex) || other.trackIndex == trackIndex)&&(identical(other.trackPositionMs, trackPositionMs) || other.trackPositionMs == trackPositionMs)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,positionMs,trackIndex,trackPositionMs,percentage);

@override
String toString() {
  return 'AudiobookProgress(positionMs: $positionMs, trackIndex: $trackIndex, trackPositionMs: $trackPositionMs, percentage: $percentage)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,positionMs,trackIndex,trackPositionMs,percentage);

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
mixin _$Series {

 String get seriesName; int get bookCount; List<String> get authors;
/// Create a copy of Series
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesCopyWith<Series> get copyWith => _$SeriesCopyWithImpl<Series>(this as Series, _$identity);

  /// Serializes this Series to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Series&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.bookCount, bookCount) || other.bookCount == bookCount)&&const DeepCollectionEquality().equals(other.authors, authors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seriesName,bookCount,const DeepCollectionEquality().hash(authors));

@override
String toString() {
  return 'Series(seriesName: $seriesName, bookCount: $bookCount, authors: $authors)';
}


}

/// @nodoc
abstract mixin class $SeriesCopyWith<$Res>  {
  factory $SeriesCopyWith(Series value, $Res Function(Series) _then) = _$SeriesCopyWithImpl;
@useResult
$Res call({
 String seriesName, int bookCount, List<String> authors
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
@pragma('vm:prefer-inline') @override $Res call({Object? seriesName = null,Object? bookCount = null,Object? authors = null,}) {
  return _then(_self.copyWith(
seriesName: null == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String seriesName,  int bookCount,  List<String> authors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Series() when $default != null:
return $default(_that.seriesName,_that.bookCount,_that.authors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String seriesName,  int bookCount,  List<String> authors)  $default,) {final _that = this;
switch (_that) {
case _Series():
return $default(_that.seriesName,_that.bookCount,_that.authors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String seriesName,  int bookCount,  List<String> authors)?  $default,) {final _that = this;
switch (_that) {
case _Series() when $default != null:
return $default(_that.seriesName,_that.bookCount,_that.authors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Series implements Series {
  const _Series({required this.seriesName, required this.bookCount, final  List<String> authors = const []}): _authors = authors;
  factory _Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);

@override final  String seriesName;
@override final  int bookCount;
 final  List<String> _authors;
@override@JsonKey() List<String> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Series&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.bookCount, bookCount) || other.bookCount == bookCount)&&const DeepCollectionEquality().equals(other._authors, _authors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seriesName,bookCount,const DeepCollectionEquality().hash(_authors));

@override
String toString() {
  return 'Series(seriesName: $seriesName, bookCount: $bookCount, authors: $authors)';
}


}

/// @nodoc
abstract mixin class _$SeriesCopyWith<$Res> implements $SeriesCopyWith<$Res> {
  factory _$SeriesCopyWith(_Series value, $Res Function(_Series) _then) = __$SeriesCopyWithImpl;
@override @useResult
$Res call({
 String seriesName, int bookCount, List<String> authors
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
@override @pragma('vm:prefer-inline') $Res call({Object? seriesName = null,Object? bookCount = null,Object? authors = null,}) {
  return _then(_Series(
seriesName: null == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String,bookCount: null == bookCount ? _self.bookCount : bookCount // ignore: cast_nullable_to_non_nullable
as int,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$Bookmark {

 int get id; int get bookId; int? get positionMs; int? get trackIndex; String? get title; String? get notes; DateTime? get createdAt;
/// Create a copy of Bookmark
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkCopyWith<Bookmark> get copyWith => _$BookmarkCopyWithImpl<Bookmark>(this as Bookmark, _$identity);

  /// Serializes this Bookmark to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bookmark&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.positionMs, positionMs) || other.positionMs == positionMs)&&(identical(other.trackIndex, trackIndex) || other.trackIndex == trackIndex)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookId,positionMs,trackIndex,title,notes,createdAt);

@override
String toString() {
  return 'Bookmark(id: $id, bookId: $bookId, positionMs: $positionMs, trackIndex: $trackIndex, title: $title, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BookmarkCopyWith<$Res>  {
  factory $BookmarkCopyWith(Bookmark value, $Res Function(Bookmark) _then) = _$BookmarkCopyWithImpl;
@useResult
$Res call({
 int id, int bookId, int? positionMs, int? trackIndex, String? title, String? notes, DateTime? createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookId = null,Object? positionMs = freezed,Object? trackIndex = freezed,Object? title = freezed,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,positionMs: freezed == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int bookId,  int? positionMs,  int? trackIndex,  String? title,  String? notes,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
return $default(_that.id,_that.bookId,_that.positionMs,_that.trackIndex,_that.title,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int bookId,  int? positionMs,  int? trackIndex,  String? title,  String? notes,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Bookmark():
return $default(_that.id,_that.bookId,_that.positionMs,_that.trackIndex,_that.title,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int bookId,  int? positionMs,  int? trackIndex,  String? title,  String? notes,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
return $default(_that.id,_that.bookId,_that.positionMs,_that.trackIndex,_that.title,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bookmark implements Bookmark {
  const _Bookmark({required this.id, required this.bookId, this.positionMs, this.trackIndex, this.title, this.notes, this.createdAt});
  factory _Bookmark.fromJson(Map<String, dynamic> json) => _$BookmarkFromJson(json);

@override final  int id;
@override final  int bookId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bookmark&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.positionMs, positionMs) || other.positionMs == positionMs)&&(identical(other.trackIndex, trackIndex) || other.trackIndex == trackIndex)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookId,positionMs,trackIndex,title,notes,createdAt);

@override
String toString() {
  return 'Bookmark(id: $id, bookId: $bookId, positionMs: $positionMs, trackIndex: $trackIndex, title: $title, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookmarkCopyWith<$Res> implements $BookmarkCopyWith<$Res> {
  factory _$BookmarkCopyWith(_Bookmark value, $Res Function(_Bookmark) _then) = __$BookmarkCopyWithImpl;
@override @useResult
$Res call({
 int id, int bookId, int? positionMs, int? trackIndex, String? title, String? notes, DateTime? createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookId = null,Object? positionMs = freezed,Object? trackIndex = freezed,Object? title = freezed,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(_Bookmark(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,positionMs: freezed == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
as int?,trackIndex: freezed == trackIndex ? _self.trackIndex : trackIndex // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountedOption&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,count);

@override
String toString() {
  return 'CountedOption(name: $name, count: $count)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,name,count);

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

 List<CountedOption> get authors;
/// Create a copy of FilterOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterOptionsCopyWith<FilterOptions> get copyWith => _$FilterOptionsCopyWithImpl<FilterOptions>(this as FilterOptions, _$identity);

  /// Serializes this FilterOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterOptions&&const DeepCollectionEquality().equals(other.authors, authors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(authors));

@override
String toString() {
  return 'FilterOptions(authors: $authors)';
}


}

/// @nodoc
abstract mixin class $FilterOptionsCopyWith<$Res>  {
  factory $FilterOptionsCopyWith(FilterOptions value, $Res Function(FilterOptions) _then) = _$FilterOptionsCopyWithImpl;
@useResult
$Res call({
 List<CountedOption> authors
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
@pragma('vm:prefer-inline') @override $Res call({Object? authors = null,}) {
  return _then(_self.copyWith(
authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CountedOption> authors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
return $default(_that.authors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CountedOption> authors)  $default,) {final _that = this;
switch (_that) {
case _FilterOptions():
return $default(_that.authors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CountedOption> authors)?  $default,) {final _that = this;
switch (_that) {
case _FilterOptions() when $default != null:
return $default(_that.authors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FilterOptions implements FilterOptions {
  const _FilterOptions({final  List<CountedOption> authors = const []}): _authors = authors;
  factory _FilterOptions.fromJson(Map<String, dynamic> json) => _$FilterOptionsFromJson(json);

 final  List<CountedOption> _authors;
@override@JsonKey() List<CountedOption> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterOptions&&const DeepCollectionEquality().equals(other._authors, _authors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_authors));

@override
String toString() {
  return 'FilterOptions(authors: $authors)';
}


}

/// @nodoc
abstract mixin class _$FilterOptionsCopyWith<$Res> implements $FilterOptionsCopyWith<$Res> {
  factory _$FilterOptionsCopyWith(_FilterOptions value, $Res Function(_FilterOptions) _then) = __$FilterOptionsCopyWithImpl;
@override @useResult
$Res call({
 List<CountedOption> authors
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
@override @pragma('vm:prefer-inline') $Res call({Object? authors = null,}) {
  return _then(_FilterOptions(
authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<CountedOption>,
  ));
}


}

// dart format on
