// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retaining_wall_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Address {

/// Street address line.
 String get street;/// City name.
/// Note: JSON key is "City" (capitalized) to match server schema.
@JsonKey(name: 'City') String get city;/// State abbreviation (e.g., "UT", "CA").
/// Note: JSON key is "State" (capitalized) to match server schema.
@JsonKey(name: 'State') String get state;/// ZIP code as integer.
/// Note: JSON key is "Zip Code" to match server schema.
@JsonKey(name: 'Zip Code') int get zipCode;
/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressCopyWith<Address> get copyWith => _$AddressCopyWithImpl<Address>(this as Address, _$identity);

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Address&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,city,state,zipCode);

@override
String toString() {
  return 'Address(street: $street, city: $city, state: $state, zipCode: $zipCode)';
}


}

/// @nodoc
abstract mixin class $AddressCopyWith<$Res>  {
  factory $AddressCopyWith(Address value, $Res Function(Address) _then) = _$AddressCopyWithImpl;
@useResult
$Res call({
 String street,@JsonKey(name: 'City') String city,@JsonKey(name: 'State') String state,@JsonKey(name: 'Zip Code') int zipCode
});




}
/// @nodoc
class _$AddressCopyWithImpl<$Res>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._self, this._then);

  final Address _self;
  final $Res Function(Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? street = null,Object? city = null,Object? state = null,Object? zipCode = null,}) {
  return _then(_self.copyWith(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,zipCode: null == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Address].
extension AddressPatterns on Address {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Address value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Address value)  $default,){
final _that = this;
switch (_that) {
case _Address():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Address value)?  $default,){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String street, @JsonKey(name: 'City')  String city, @JsonKey(name: 'State')  String state, @JsonKey(name: 'Zip Code')  int zipCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.street,_that.city,_that.state,_that.zipCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String street, @JsonKey(name: 'City')  String city, @JsonKey(name: 'State')  String state, @JsonKey(name: 'Zip Code')  int zipCode)  $default,) {final _that = this;
switch (_that) {
case _Address():
return $default(_that.street,_that.city,_that.state,_that.zipCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String street, @JsonKey(name: 'City')  String city, @JsonKey(name: 'State')  String state, @JsonKey(name: 'Zip Code')  int zipCode)?  $default,) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.street,_that.city,_that.state,_that.zipCode);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Address implements Address {
  const _Address({this.street = '', @JsonKey(name: 'City') this.city = '', @JsonKey(name: 'State') this.state = '', @JsonKey(name: 'Zip Code') this.zipCode = 0});
  factory _Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

/// Street address line.
@override@JsonKey() final  String street;
/// City name.
/// Note: JSON key is "City" (capitalized) to match server schema.
@override@JsonKey(name: 'City') final  String city;
/// State abbreviation (e.g., "UT", "CA").
/// Note: JSON key is "State" (capitalized) to match server schema.
@override@JsonKey(name: 'State') final  String state;
/// ZIP code as integer.
/// Note: JSON key is "Zip Code" to match server schema.
@override@JsonKey(name: 'Zip Code') final  int zipCode;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressCopyWith<_Address> get copyWith => __$AddressCopyWithImpl<_Address>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Address&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,city,state,zipCode);

@override
String toString() {
  return 'Address(street: $street, city: $city, state: $state, zipCode: $zipCode)';
}


}

/// @nodoc
abstract mixin class _$AddressCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$AddressCopyWith(_Address value, $Res Function(_Address) _then) = __$AddressCopyWithImpl;
@override @useResult
$Res call({
 String street,@JsonKey(name: 'City') String city,@JsonKey(name: 'State') String state,@JsonKey(name: 'Zip Code') int zipCode
});




}
/// @nodoc
class __$AddressCopyWithImpl<$Res>
    implements _$AddressCopyWith<$Res> {
  __$AddressCopyWithImpl(this._self, this._then);

  final _Address _self;
  final $Res Function(_Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = null,Object? city = null,Object? state = null,Object? zipCode = null,}) {
  return _then(_Address(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,zipCode: null == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CustomerInfo {

/// Customer's full name.
 String get name;/// Customer's email address.
 String get email;/// Customer's phone number.
 String get phone;/// Customer's mailing address for document delivery.
@JsonKey(name: 'mailing_address') Address get mailingAddress;
/// Create a copy of CustomerInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerInfoCopyWith<CustomerInfo> get copyWith => _$CustomerInfoCopyWithImpl<CustomerInfo>(this as CustomerInfo, _$identity);

  /// Serializes this CustomerInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.mailingAddress, mailingAddress) || other.mailingAddress == mailingAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,mailingAddress);

@override
String toString() {
  return 'CustomerInfo(name: $name, email: $email, phone: $phone, mailingAddress: $mailingAddress)';
}


}

/// @nodoc
abstract mixin class $CustomerInfoCopyWith<$Res>  {
  factory $CustomerInfoCopyWith(CustomerInfo value, $Res Function(CustomerInfo) _then) = _$CustomerInfoCopyWithImpl;
@useResult
$Res call({
 String name, String email, String phone,@JsonKey(name: 'mailing_address') Address mailingAddress
});


$AddressCopyWith<$Res> get mailingAddress;

}
/// @nodoc
class _$CustomerInfoCopyWithImpl<$Res>
    implements $CustomerInfoCopyWith<$Res> {
  _$CustomerInfoCopyWithImpl(this._self, this._then);

  final CustomerInfo _self;
  final $Res Function(CustomerInfo) _then;

/// Create a copy of CustomerInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,Object? phone = null,Object? mailingAddress = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,mailingAddress: null == mailingAddress ? _self.mailingAddress : mailingAddress // ignore: cast_nullable_to_non_nullable
as Address,
  ));
}
/// Create a copy of CustomerInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get mailingAddress {
  
  return $AddressCopyWith<$Res>(_self.mailingAddress, (value) {
    return _then(_self.copyWith(mailingAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomerInfo].
extension CustomerInfoPatterns on CustomerInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerInfo value)  $default,){
final _that = this;
switch (_that) {
case _CustomerInfo():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email,  String phone, @JsonKey(name: 'mailing_address')  Address mailingAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerInfo() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.mailingAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email,  String phone, @JsonKey(name: 'mailing_address')  Address mailingAddress)  $default,) {final _that = this;
switch (_that) {
case _CustomerInfo():
return $default(_that.name,_that.email,_that.phone,_that.mailingAddress);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email,  String phone, @JsonKey(name: 'mailing_address')  Address mailingAddress)?  $default,) {final _that = this;
switch (_that) {
case _CustomerInfo() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.mailingAddress);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CustomerInfo implements CustomerInfo {
  const _CustomerInfo({this.name = '', this.email = '', this.phone = '', @JsonKey(name: 'mailing_address') this.mailingAddress = const Address()});
  factory _CustomerInfo.fromJson(Map<String, dynamic> json) => _$CustomerInfoFromJson(json);

/// Customer's full name.
@override@JsonKey() final  String name;
/// Customer's email address.
@override@JsonKey() final  String email;
/// Customer's phone number.
@override@JsonKey() final  String phone;
/// Customer's mailing address for document delivery.
@override@JsonKey(name: 'mailing_address') final  Address mailingAddress;

/// Create a copy of CustomerInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerInfoCopyWith<_CustomerInfo> get copyWith => __$CustomerInfoCopyWithImpl<_CustomerInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.mailingAddress, mailingAddress) || other.mailingAddress == mailingAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,mailingAddress);

@override
String toString() {
  return 'CustomerInfo(name: $name, email: $email, phone: $phone, mailingAddress: $mailingAddress)';
}


}

/// @nodoc
abstract mixin class _$CustomerInfoCopyWith<$Res> implements $CustomerInfoCopyWith<$Res> {
  factory _$CustomerInfoCopyWith(_CustomerInfo value, $Res Function(_CustomerInfo) _then) = __$CustomerInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String email, String phone,@JsonKey(name: 'mailing_address') Address mailingAddress
});


@override $AddressCopyWith<$Res> get mailingAddress;

}
/// @nodoc
class __$CustomerInfoCopyWithImpl<$Res>
    implements _$CustomerInfoCopyWith<$Res> {
  __$CustomerInfoCopyWithImpl(this._self, this._then);

  final _CustomerInfo _self;
  final $Res Function(_CustomerInfo) _then;

/// Create a copy of CustomerInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,Object? phone = null,Object? mailingAddress = null,}) {
  return _then(_CustomerInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,mailingAddress: null == mailingAddress ? _self.mailingAddress : mailingAddress // ignore: cast_nullable_to_non_nullable
as Address,
  ));
}

/// Create a copy of CustomerInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get mailingAddress {
  
  return $AddressCopyWith<$Res>(_self.mailingAddress, (value) {
    return _then(_self.copyWith(mailingAddress: value));
  });
}
}


/// @nodoc
mixin _$RetainingWallInput {

/// Wall height in inches (24-144).
 double get height;/// Material type (0=concrete, 1=CMU).
 int get material;/// Surcharge/slope condition (0=flat, 1=1:1, 2=1:2, 4=1:4).
 int get surcharge;/// Optimization parameter (0=excavation, 1=footing).
@JsonKey(name: 'optimization_parameter') int get optimizationParameter;/// Soil stiffness (0=stiff, 1=soft).
@JsonKey(name: 'soil_stiffness') int get soilStiffness;/// Topsoil thickness in inches.
 int get topping;/// Whether the wall has a slab.
@JsonKey(name: 'has_slab') bool get hasSlab;/// Toe length in inches.
 int get toe;/// Site address where the wall will be built.
@JsonKey(name: 'site_address') Address get siteAddress;/// Customer contact and mailing information.
@JsonKey(name: 'customer_info') CustomerInfo get customerInfo;
/// Create a copy of RetainingWallInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RetainingWallInputCopyWith<RetainingWallInput> get copyWith => _$RetainingWallInputCopyWithImpl<RetainingWallInput>(this as RetainingWallInput, _$identity);

  /// Serializes this RetainingWallInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RetainingWallInput&&(identical(other.height, height) || other.height == height)&&(identical(other.material, material) || other.material == material)&&(identical(other.surcharge, surcharge) || other.surcharge == surcharge)&&(identical(other.optimizationParameter, optimizationParameter) || other.optimizationParameter == optimizationParameter)&&(identical(other.soilStiffness, soilStiffness) || other.soilStiffness == soilStiffness)&&(identical(other.topping, topping) || other.topping == topping)&&(identical(other.hasSlab, hasSlab) || other.hasSlab == hasSlab)&&(identical(other.toe, toe) || other.toe == toe)&&(identical(other.siteAddress, siteAddress) || other.siteAddress == siteAddress)&&(identical(other.customerInfo, customerInfo) || other.customerInfo == customerInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,height,material,surcharge,optimizationParameter,soilStiffness,topping,hasSlab,toe,siteAddress,customerInfo);

@override
String toString() {
  return 'RetainingWallInput(height: $height, material: $material, surcharge: $surcharge, optimizationParameter: $optimizationParameter, soilStiffness: $soilStiffness, topping: $topping, hasSlab: $hasSlab, toe: $toe, siteAddress: $siteAddress, customerInfo: $customerInfo)';
}


}

/// @nodoc
abstract mixin class $RetainingWallInputCopyWith<$Res>  {
  factory $RetainingWallInputCopyWith(RetainingWallInput value, $Res Function(RetainingWallInput) _then) = _$RetainingWallInputCopyWithImpl;
@useResult
$Res call({
 double height, int material, int surcharge,@JsonKey(name: 'optimization_parameter') int optimizationParameter,@JsonKey(name: 'soil_stiffness') int soilStiffness, int topping,@JsonKey(name: 'has_slab') bool hasSlab, int toe,@JsonKey(name: 'site_address') Address siteAddress,@JsonKey(name: 'customer_info') CustomerInfo customerInfo
});


$AddressCopyWith<$Res> get siteAddress;$CustomerInfoCopyWith<$Res> get customerInfo;

}
/// @nodoc
class _$RetainingWallInputCopyWithImpl<$Res>
    implements $RetainingWallInputCopyWith<$Res> {
  _$RetainingWallInputCopyWithImpl(this._self, this._then);

  final RetainingWallInput _self;
  final $Res Function(RetainingWallInput) _then;

/// Create a copy of RetainingWallInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? height = null,Object? material = null,Object? surcharge = null,Object? optimizationParameter = null,Object? soilStiffness = null,Object? topping = null,Object? hasSlab = null,Object? toe = null,Object? siteAddress = null,Object? customerInfo = null,}) {
  return _then(_self.copyWith(
height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,material: null == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as int,surcharge: null == surcharge ? _self.surcharge : surcharge // ignore: cast_nullable_to_non_nullable
as int,optimizationParameter: null == optimizationParameter ? _self.optimizationParameter : optimizationParameter // ignore: cast_nullable_to_non_nullable
as int,soilStiffness: null == soilStiffness ? _self.soilStiffness : soilStiffness // ignore: cast_nullable_to_non_nullable
as int,topping: null == topping ? _self.topping : topping // ignore: cast_nullable_to_non_nullable
as int,hasSlab: null == hasSlab ? _self.hasSlab : hasSlab // ignore: cast_nullable_to_non_nullable
as bool,toe: null == toe ? _self.toe : toe // ignore: cast_nullable_to_non_nullable
as int,siteAddress: null == siteAddress ? _self.siteAddress : siteAddress // ignore: cast_nullable_to_non_nullable
as Address,customerInfo: null == customerInfo ? _self.customerInfo : customerInfo // ignore: cast_nullable_to_non_nullable
as CustomerInfo,
  ));
}
/// Create a copy of RetainingWallInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get siteAddress {
  
  return $AddressCopyWith<$Res>(_self.siteAddress, (value) {
    return _then(_self.copyWith(siteAddress: value));
  });
}/// Create a copy of RetainingWallInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerInfoCopyWith<$Res> get customerInfo {
  
  return $CustomerInfoCopyWith<$Res>(_self.customerInfo, (value) {
    return _then(_self.copyWith(customerInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [RetainingWallInput].
extension RetainingWallInputPatterns on RetainingWallInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RetainingWallInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RetainingWallInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RetainingWallInput value)  $default,){
final _that = this;
switch (_that) {
case _RetainingWallInput():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RetainingWallInput value)?  $default,){
final _that = this;
switch (_that) {
case _RetainingWallInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double height,  int material,  int surcharge, @JsonKey(name: 'optimization_parameter')  int optimizationParameter, @JsonKey(name: 'soil_stiffness')  int soilStiffness,  int topping, @JsonKey(name: 'has_slab')  bool hasSlab,  int toe, @JsonKey(name: 'site_address')  Address siteAddress, @JsonKey(name: 'customer_info')  CustomerInfo customerInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RetainingWallInput() when $default != null:
return $default(_that.height,_that.material,_that.surcharge,_that.optimizationParameter,_that.soilStiffness,_that.topping,_that.hasSlab,_that.toe,_that.siteAddress,_that.customerInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double height,  int material,  int surcharge, @JsonKey(name: 'optimization_parameter')  int optimizationParameter, @JsonKey(name: 'soil_stiffness')  int soilStiffness,  int topping, @JsonKey(name: 'has_slab')  bool hasSlab,  int toe, @JsonKey(name: 'site_address')  Address siteAddress, @JsonKey(name: 'customer_info')  CustomerInfo customerInfo)  $default,) {final _that = this;
switch (_that) {
case _RetainingWallInput():
return $default(_that.height,_that.material,_that.surcharge,_that.optimizationParameter,_that.soilStiffness,_that.topping,_that.hasSlab,_that.toe,_that.siteAddress,_that.customerInfo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double height,  int material,  int surcharge, @JsonKey(name: 'optimization_parameter')  int optimizationParameter, @JsonKey(name: 'soil_stiffness')  int soilStiffness,  int topping, @JsonKey(name: 'has_slab')  bool hasSlab,  int toe, @JsonKey(name: 'site_address')  Address siteAddress, @JsonKey(name: 'customer_info')  CustomerInfo customerInfo)?  $default,) {final _that = this;
switch (_that) {
case _RetainingWallInput() when $default != null:
return $default(_that.height,_that.material,_that.surcharge,_that.optimizationParameter,_that.soilStiffness,_that.topping,_that.hasSlab,_that.toe,_that.siteAddress,_that.customerInfo);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RetainingWallInput implements RetainingWallInput {
  const _RetainingWallInput({this.height = WallConstraints.defaultHeight, this.material = WallMaterialType.cmu, this.surcharge = SurchargeType.flat, @JsonKey(name: 'optimization_parameter') this.optimizationParameter = OptimizationType.excavation, @JsonKey(name: 'soil_stiffness') this.soilStiffness = SoilStiffnessType.stiff, this.topping = WallConstraints.defaultTopping, @JsonKey(name: 'has_slab') this.hasSlab = false, this.toe = WallConstraints.defaultToe, @JsonKey(name: 'site_address') this.siteAddress = const Address(), @JsonKey(name: 'customer_info') this.customerInfo = const CustomerInfo()});
  factory _RetainingWallInput.fromJson(Map<String, dynamic> json) => _$RetainingWallInputFromJson(json);

/// Wall height in inches (24-144).
@override@JsonKey() final  double height;
/// Material type (0=concrete, 1=CMU).
@override@JsonKey() final  int material;
/// Surcharge/slope condition (0=flat, 1=1:1, 2=1:2, 4=1:4).
@override@JsonKey() final  int surcharge;
/// Optimization parameter (0=excavation, 1=footing).
@override@JsonKey(name: 'optimization_parameter') final  int optimizationParameter;
/// Soil stiffness (0=stiff, 1=soft).
@override@JsonKey(name: 'soil_stiffness') final  int soilStiffness;
/// Topsoil thickness in inches.
@override@JsonKey() final  int topping;
/// Whether the wall has a slab.
@override@JsonKey(name: 'has_slab') final  bool hasSlab;
/// Toe length in inches.
@override@JsonKey() final  int toe;
/// Site address where the wall will be built.
@override@JsonKey(name: 'site_address') final  Address siteAddress;
/// Customer contact and mailing information.
@override@JsonKey(name: 'customer_info') final  CustomerInfo customerInfo;

/// Create a copy of RetainingWallInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RetainingWallInputCopyWith<_RetainingWallInput> get copyWith => __$RetainingWallInputCopyWithImpl<_RetainingWallInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RetainingWallInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RetainingWallInput&&(identical(other.height, height) || other.height == height)&&(identical(other.material, material) || other.material == material)&&(identical(other.surcharge, surcharge) || other.surcharge == surcharge)&&(identical(other.optimizationParameter, optimizationParameter) || other.optimizationParameter == optimizationParameter)&&(identical(other.soilStiffness, soilStiffness) || other.soilStiffness == soilStiffness)&&(identical(other.topping, topping) || other.topping == topping)&&(identical(other.hasSlab, hasSlab) || other.hasSlab == hasSlab)&&(identical(other.toe, toe) || other.toe == toe)&&(identical(other.siteAddress, siteAddress) || other.siteAddress == siteAddress)&&(identical(other.customerInfo, customerInfo) || other.customerInfo == customerInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,height,material,surcharge,optimizationParameter,soilStiffness,topping,hasSlab,toe,siteAddress,customerInfo);

@override
String toString() {
  return 'RetainingWallInput(height: $height, material: $material, surcharge: $surcharge, optimizationParameter: $optimizationParameter, soilStiffness: $soilStiffness, topping: $topping, hasSlab: $hasSlab, toe: $toe, siteAddress: $siteAddress, customerInfo: $customerInfo)';
}


}

/// @nodoc
abstract mixin class _$RetainingWallInputCopyWith<$Res> implements $RetainingWallInputCopyWith<$Res> {
  factory _$RetainingWallInputCopyWith(_RetainingWallInput value, $Res Function(_RetainingWallInput) _then) = __$RetainingWallInputCopyWithImpl;
@override @useResult
$Res call({
 double height, int material, int surcharge,@JsonKey(name: 'optimization_parameter') int optimizationParameter,@JsonKey(name: 'soil_stiffness') int soilStiffness, int topping,@JsonKey(name: 'has_slab') bool hasSlab, int toe,@JsonKey(name: 'site_address') Address siteAddress,@JsonKey(name: 'customer_info') CustomerInfo customerInfo
});


@override $AddressCopyWith<$Res> get siteAddress;@override $CustomerInfoCopyWith<$Res> get customerInfo;

}
/// @nodoc
class __$RetainingWallInputCopyWithImpl<$Res>
    implements _$RetainingWallInputCopyWith<$Res> {
  __$RetainingWallInputCopyWithImpl(this._self, this._then);

  final _RetainingWallInput _self;
  final $Res Function(_RetainingWallInput) _then;

/// Create a copy of RetainingWallInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? height = null,Object? material = null,Object? surcharge = null,Object? optimizationParameter = null,Object? soilStiffness = null,Object? topping = null,Object? hasSlab = null,Object? toe = null,Object? siteAddress = null,Object? customerInfo = null,}) {
  return _then(_RetainingWallInput(
height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,material: null == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as int,surcharge: null == surcharge ? _self.surcharge : surcharge // ignore: cast_nullable_to_non_nullable
as int,optimizationParameter: null == optimizationParameter ? _self.optimizationParameter : optimizationParameter // ignore: cast_nullable_to_non_nullable
as int,soilStiffness: null == soilStiffness ? _self.soilStiffness : soilStiffness // ignore: cast_nullable_to_non_nullable
as int,topping: null == topping ? _self.topping : topping // ignore: cast_nullable_to_non_nullable
as int,hasSlab: null == hasSlab ? _self.hasSlab : hasSlab // ignore: cast_nullable_to_non_nullable
as bool,toe: null == toe ? _self.toe : toe // ignore: cast_nullable_to_non_nullable
as int,siteAddress: null == siteAddress ? _self.siteAddress : siteAddress // ignore: cast_nullable_to_non_nullable
as Address,customerInfo: null == customerInfo ? _self.customerInfo : customerInfo // ignore: cast_nullable_to_non_nullable
as CustomerInfo,
  ));
}

/// Create a copy of RetainingWallInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get siteAddress {
  
  return $AddressCopyWith<$Res>(_self.siteAddress, (value) {
    return _then(_self.copyWith(siteAddress: value));
  });
}/// Create a copy of RetainingWallInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerInfoCopyWith<$Res> get customerInfo {
  
  return $CustomerInfoCopyWith<$Res>(_self.customerInfo, (value) {
    return _then(_self.copyWith(customerInfo: value));
  });
}
}

// dart format on
