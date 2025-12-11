// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retaining_wall_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Address _$AddressFromJson(Map<String, dynamic> json) {
  return _Address.fromJson(json);
}

/// @nodoc
mixin _$Address {
  /// Street address line.
  String get street => throw _privateConstructorUsedError;

  /// City name.
  /// Note: JSON key is "City" (capitalized) to match server schema.
  @JsonKey(name: 'City')
  String get city => throw _privateConstructorUsedError;

  /// State abbreviation (e.g., "UT", "CA").
  /// Note: JSON key is "State" (capitalized) to match server schema.
  @JsonKey(name: 'State')
  String get state => throw _privateConstructorUsedError;

  /// ZIP code as integer.
  /// Note: JSON key is "Zip Code" to match server schema.
  @JsonKey(name: 'Zip Code')
  int get zipCode => throw _privateConstructorUsedError;

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressCopyWith<Address> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressCopyWith<$Res> {
  factory $AddressCopyWith(Address value, $Res Function(Address) then) =
      _$AddressCopyWithImpl<$Res, Address>;
  @useResult
  $Res call({
    String street,
    @JsonKey(name: 'City') String city,
    @JsonKey(name: 'State') String state,
    @JsonKey(name: 'Zip Code') int zipCode,
  });
}

/// @nodoc
class _$AddressCopyWithImpl<$Res, $Val extends Address>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? street = null,
    Object? city = null,
    Object? state = null,
    Object? zipCode = null,
  }) {
    return _then(
      _value.copyWith(
            street: null == street
                ? _value.street
                : street // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String,
            zipCode: null == zipCode
                ? _value.zipCode
                : zipCode // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddressImplCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$$AddressImplCopyWith(
    _$AddressImpl value,
    $Res Function(_$AddressImpl) then,
  ) = __$$AddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String street,
    @JsonKey(name: 'City') String city,
    @JsonKey(name: 'State') String state,
    @JsonKey(name: 'Zip Code') int zipCode,
  });
}

/// @nodoc
class __$$AddressImplCopyWithImpl<$Res>
    extends _$AddressCopyWithImpl<$Res, _$AddressImpl>
    implements _$$AddressImplCopyWith<$Res> {
  __$$AddressImplCopyWithImpl(
    _$AddressImpl _value,
    $Res Function(_$AddressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? street = null,
    Object? city = null,
    Object? state = null,
    Object? zipCode = null,
  }) {
    return _then(
      _$AddressImpl(
        street: null == street
            ? _value.street
            : street // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        zipCode: null == zipCode
            ? _value.zipCode
            : zipCode // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressImpl implements _Address {
  const _$AddressImpl({
    this.street = '',
    @JsonKey(name: 'City') this.city = '',
    @JsonKey(name: 'State') this.state = '',
    @JsonKey(name: 'Zip Code') this.zipCode = 0,
  });

  factory _$AddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressImplFromJson(json);

  /// Street address line.
  @override
  @JsonKey()
  final String street;

  /// City name.
  /// Note: JSON key is "City" (capitalized) to match server schema.
  @override
  @JsonKey(name: 'City')
  final String city;

  /// State abbreviation (e.g., "UT", "CA").
  /// Note: JSON key is "State" (capitalized) to match server schema.
  @override
  @JsonKey(name: 'State')
  final String state;

  /// ZIP code as integer.
  /// Note: JSON key is "Zip Code" to match server schema.
  @override
  @JsonKey(name: 'Zip Code')
  final int zipCode;

  @override
  String toString() {
    return 'Address(street: $street, city: $city, state: $state, zipCode: $zipCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressImpl &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, street, city, state, zipCode);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      __$$AddressImplCopyWithImpl<_$AddressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressImplToJson(this);
  }
}

abstract class _Address implements Address {
  const factory _Address({
    final String street,
    @JsonKey(name: 'City') final String city,
    @JsonKey(name: 'State') final String state,
    @JsonKey(name: 'Zip Code') final int zipCode,
  }) = _$AddressImpl;

  factory _Address.fromJson(Map<String, dynamic> json) = _$AddressImpl.fromJson;

  /// Street address line.
  @override
  String get street;

  /// City name.
  /// Note: JSON key is "City" (capitalized) to match server schema.
  @override
  @JsonKey(name: 'City')
  String get city;

  /// State abbreviation (e.g., "UT", "CA").
  /// Note: JSON key is "State" (capitalized) to match server schema.
  @override
  @JsonKey(name: 'State')
  String get state;

  /// ZIP code as integer.
  /// Note: JSON key is "Zip Code" to match server schema.
  @override
  @JsonKey(name: 'Zip Code')
  int get zipCode;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerInfo _$CustomerInfoFromJson(Map<String, dynamic> json) {
  return _CustomerInfo.fromJson(json);
}

/// @nodoc
mixin _$CustomerInfo {
  /// Customer's full name.
  String get name => throw _privateConstructorUsedError;

  /// Customer's email address.
  String get email => throw _privateConstructorUsedError;

  /// Customer's phone number.
  String get phone => throw _privateConstructorUsedError;

  /// Customer's mailing address for document delivery.
  @JsonKey(name: 'mailing_address')
  Address get mailingAddress => throw _privateConstructorUsedError;

  /// Serializes this CustomerInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerInfoCopyWith<CustomerInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerInfoCopyWith<$Res> {
  factory $CustomerInfoCopyWith(
    CustomerInfo value,
    $Res Function(CustomerInfo) then,
  ) = _$CustomerInfoCopyWithImpl<$Res, CustomerInfo>;
  @useResult
  $Res call({
    String name,
    String email,
    String phone,
    @JsonKey(name: 'mailing_address') Address mailingAddress,
  });

  $AddressCopyWith<$Res> get mailingAddress;
}

/// @nodoc
class _$CustomerInfoCopyWithImpl<$Res, $Val extends CustomerInfo>
    implements $CustomerInfoCopyWith<$Res> {
  _$CustomerInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? mailingAddress = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            mailingAddress: null == mailingAddress
                ? _value.mailingAddress
                : mailingAddress // ignore: cast_nullable_to_non_nullable
                      as Address,
          )
          as $Val,
    );
  }

  /// Create a copy of CustomerInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res> get mailingAddress {
    return $AddressCopyWith<$Res>(_value.mailingAddress, (value) {
      return _then(_value.copyWith(mailingAddress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CustomerInfoImplCopyWith<$Res>
    implements $CustomerInfoCopyWith<$Res> {
  factory _$$CustomerInfoImplCopyWith(
    _$CustomerInfoImpl value,
    $Res Function(_$CustomerInfoImpl) then,
  ) = __$$CustomerInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String email,
    String phone,
    @JsonKey(name: 'mailing_address') Address mailingAddress,
  });

  @override
  $AddressCopyWith<$Res> get mailingAddress;
}

/// @nodoc
class __$$CustomerInfoImplCopyWithImpl<$Res>
    extends _$CustomerInfoCopyWithImpl<$Res, _$CustomerInfoImpl>
    implements _$$CustomerInfoImplCopyWith<$Res> {
  __$$CustomerInfoImplCopyWithImpl(
    _$CustomerInfoImpl _value,
    $Res Function(_$CustomerInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? mailingAddress = null,
  }) {
    return _then(
      _$CustomerInfoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        mailingAddress: null == mailingAddress
            ? _value.mailingAddress
            : mailingAddress // ignore: cast_nullable_to_non_nullable
                  as Address,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerInfoImpl implements _CustomerInfo {
  const _$CustomerInfoImpl({
    this.name = '',
    this.email = '',
    this.phone = '',
    @JsonKey(name: 'mailing_address') this.mailingAddress = const Address(),
  });

  factory _$CustomerInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerInfoImplFromJson(json);

  /// Customer's full name.
  @override
  @JsonKey()
  final String name;

  /// Customer's email address.
  @override
  @JsonKey()
  final String email;

  /// Customer's phone number.
  @override
  @JsonKey()
  final String phone;

  /// Customer's mailing address for document delivery.
  @override
  @JsonKey(name: 'mailing_address')
  final Address mailingAddress;

  @override
  String toString() {
    return 'CustomerInfo(name: $name, email: $email, phone: $phone, mailingAddress: $mailingAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerInfoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.mailingAddress, mailingAddress) ||
                other.mailingAddress == mailingAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, email, phone, mailingAddress);

  /// Create a copy of CustomerInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerInfoImplCopyWith<_$CustomerInfoImpl> get copyWith =>
      __$$CustomerInfoImplCopyWithImpl<_$CustomerInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerInfoImplToJson(this);
  }
}

abstract class _CustomerInfo implements CustomerInfo {
  const factory _CustomerInfo({
    final String name,
    final String email,
    final String phone,
    @JsonKey(name: 'mailing_address') final Address mailingAddress,
  }) = _$CustomerInfoImpl;

  factory _CustomerInfo.fromJson(Map<String, dynamic> json) =
      _$CustomerInfoImpl.fromJson;

  /// Customer's full name.
  @override
  String get name;

  /// Customer's email address.
  @override
  String get email;

  /// Customer's phone number.
  @override
  String get phone;

  /// Customer's mailing address for document delivery.
  @override
  @JsonKey(name: 'mailing_address')
  Address get mailingAddress;

  /// Create a copy of CustomerInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerInfoImplCopyWith<_$CustomerInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RetainingWallInput _$RetainingWallInputFromJson(Map<String, dynamic> json) {
  return _RetainingWallInput.fromJson(json);
}

/// @nodoc
mixin _$RetainingWallInput {
  /// Wall height in inches (24-144).
  double get height => throw _privateConstructorUsedError;

  /// Material type (0=concrete, 1=CMU).
  int get material => throw _privateConstructorUsedError;

  /// Surcharge/slope condition (0=flat, 1=1:1, 2=1:2, 4=1:4).
  int get surcharge => throw _privateConstructorUsedError;

  /// Optimization parameter (0=excavation, 1=footing).
  @JsonKey(name: 'optimization_parameter')
  int get optimizationParameter => throw _privateConstructorUsedError;

  /// Soil stiffness (0=stiff, 1=soft).
  @JsonKey(name: 'soil_stiffness')
  int get soilStiffness => throw _privateConstructorUsedError;

  /// Topsoil thickness in inches.
  int get topping => throw _privateConstructorUsedError;

  /// Whether the wall has a slab.
  @JsonKey(name: 'has_slab')
  bool get hasSlab => throw _privateConstructorUsedError;

  /// Toe length in inches.
  int get toe => throw _privateConstructorUsedError;

  /// Site address where the wall will be built.
  @JsonKey(name: 'site_address')
  Address get siteAddress => throw _privateConstructorUsedError;

  /// Customer contact and mailing information.
  @JsonKey(name: 'customer_info')
  CustomerInfo get customerInfo => throw _privateConstructorUsedError;

  /// Serializes this RetainingWallInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RetainingWallInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RetainingWallInputCopyWith<RetainingWallInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RetainingWallInputCopyWith<$Res> {
  factory $RetainingWallInputCopyWith(
    RetainingWallInput value,
    $Res Function(RetainingWallInput) then,
  ) = _$RetainingWallInputCopyWithImpl<$Res, RetainingWallInput>;
  @useResult
  $Res call({
    double height,
    int material,
    int surcharge,
    @JsonKey(name: 'optimization_parameter') int optimizationParameter,
    @JsonKey(name: 'soil_stiffness') int soilStiffness,
    int topping,
    @JsonKey(name: 'has_slab') bool hasSlab,
    int toe,
    @JsonKey(name: 'site_address') Address siteAddress,
    @JsonKey(name: 'customer_info') CustomerInfo customerInfo,
  });

  $AddressCopyWith<$Res> get siteAddress;
  $CustomerInfoCopyWith<$Res> get customerInfo;
}

/// @nodoc
class _$RetainingWallInputCopyWithImpl<$Res, $Val extends RetainingWallInput>
    implements $RetainingWallInputCopyWith<$Res> {
  _$RetainingWallInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RetainingWallInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = null,
    Object? material = null,
    Object? surcharge = null,
    Object? optimizationParameter = null,
    Object? soilStiffness = null,
    Object? topping = null,
    Object? hasSlab = null,
    Object? toe = null,
    Object? siteAddress = null,
    Object? customerInfo = null,
  }) {
    return _then(
      _value.copyWith(
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as double,
            material: null == material
                ? _value.material
                : material // ignore: cast_nullable_to_non_nullable
                      as int,
            surcharge: null == surcharge
                ? _value.surcharge
                : surcharge // ignore: cast_nullable_to_non_nullable
                      as int,
            optimizationParameter: null == optimizationParameter
                ? _value.optimizationParameter
                : optimizationParameter // ignore: cast_nullable_to_non_nullable
                      as int,
            soilStiffness: null == soilStiffness
                ? _value.soilStiffness
                : soilStiffness // ignore: cast_nullable_to_non_nullable
                      as int,
            topping: null == topping
                ? _value.topping
                : topping // ignore: cast_nullable_to_non_nullable
                      as int,
            hasSlab: null == hasSlab
                ? _value.hasSlab
                : hasSlab // ignore: cast_nullable_to_non_nullable
                      as bool,
            toe: null == toe
                ? _value.toe
                : toe // ignore: cast_nullable_to_non_nullable
                      as int,
            siteAddress: null == siteAddress
                ? _value.siteAddress
                : siteAddress // ignore: cast_nullable_to_non_nullable
                      as Address,
            customerInfo: null == customerInfo
                ? _value.customerInfo
                : customerInfo // ignore: cast_nullable_to_non_nullable
                      as CustomerInfo,
          )
          as $Val,
    );
  }

  /// Create a copy of RetainingWallInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res> get siteAddress {
    return $AddressCopyWith<$Res>(_value.siteAddress, (value) {
      return _then(_value.copyWith(siteAddress: value) as $Val);
    });
  }

  /// Create a copy of RetainingWallInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerInfoCopyWith<$Res> get customerInfo {
    return $CustomerInfoCopyWith<$Res>(_value.customerInfo, (value) {
      return _then(_value.copyWith(customerInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RetainingWallInputImplCopyWith<$Res>
    implements $RetainingWallInputCopyWith<$Res> {
  factory _$$RetainingWallInputImplCopyWith(
    _$RetainingWallInputImpl value,
    $Res Function(_$RetainingWallInputImpl) then,
  ) = __$$RetainingWallInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double height,
    int material,
    int surcharge,
    @JsonKey(name: 'optimization_parameter') int optimizationParameter,
    @JsonKey(name: 'soil_stiffness') int soilStiffness,
    int topping,
    @JsonKey(name: 'has_slab') bool hasSlab,
    int toe,
    @JsonKey(name: 'site_address') Address siteAddress,
    @JsonKey(name: 'customer_info') CustomerInfo customerInfo,
  });

  @override
  $AddressCopyWith<$Res> get siteAddress;
  @override
  $CustomerInfoCopyWith<$Res> get customerInfo;
}

/// @nodoc
class __$$RetainingWallInputImplCopyWithImpl<$Res>
    extends _$RetainingWallInputCopyWithImpl<$Res, _$RetainingWallInputImpl>
    implements _$$RetainingWallInputImplCopyWith<$Res> {
  __$$RetainingWallInputImplCopyWithImpl(
    _$RetainingWallInputImpl _value,
    $Res Function(_$RetainingWallInputImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RetainingWallInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = null,
    Object? material = null,
    Object? surcharge = null,
    Object? optimizationParameter = null,
    Object? soilStiffness = null,
    Object? topping = null,
    Object? hasSlab = null,
    Object? toe = null,
    Object? siteAddress = null,
    Object? customerInfo = null,
  }) {
    return _then(
      _$RetainingWallInputImpl(
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double,
        material: null == material
            ? _value.material
            : material // ignore: cast_nullable_to_non_nullable
                  as int,
        surcharge: null == surcharge
            ? _value.surcharge
            : surcharge // ignore: cast_nullable_to_non_nullable
                  as int,
        optimizationParameter: null == optimizationParameter
            ? _value.optimizationParameter
            : optimizationParameter // ignore: cast_nullable_to_non_nullable
                  as int,
        soilStiffness: null == soilStiffness
            ? _value.soilStiffness
            : soilStiffness // ignore: cast_nullable_to_non_nullable
                  as int,
        topping: null == topping
            ? _value.topping
            : topping // ignore: cast_nullable_to_non_nullable
                  as int,
        hasSlab: null == hasSlab
            ? _value.hasSlab
            : hasSlab // ignore: cast_nullable_to_non_nullable
                  as bool,
        toe: null == toe
            ? _value.toe
            : toe // ignore: cast_nullable_to_non_nullable
                  as int,
        siteAddress: null == siteAddress
            ? _value.siteAddress
            : siteAddress // ignore: cast_nullable_to_non_nullable
                  as Address,
        customerInfo: null == customerInfo
            ? _value.customerInfo
            : customerInfo // ignore: cast_nullable_to_non_nullable
                  as CustomerInfo,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RetainingWallInputImpl implements _RetainingWallInput {
  const _$RetainingWallInputImpl({
    this.height = WallConstraints.defaultHeight,
    this.material = WallMaterialType.cmu,
    this.surcharge = SurchargeType.flat,
    @JsonKey(name: 'optimization_parameter')
    this.optimizationParameter = OptimizationType.excavation,
    @JsonKey(name: 'soil_stiffness')
    this.soilStiffness = SoilStiffnessType.stiff,
    this.topping = WallConstraints.defaultTopping,
    @JsonKey(name: 'has_slab') this.hasSlab = false,
    this.toe = WallConstraints.defaultToe,
    @JsonKey(name: 'site_address') this.siteAddress = const Address(),
    @JsonKey(name: 'customer_info') this.customerInfo = const CustomerInfo(),
  });

  factory _$RetainingWallInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$RetainingWallInputImplFromJson(json);

  /// Wall height in inches (24-144).
  @override
  @JsonKey()
  final double height;

  /// Material type (0=concrete, 1=CMU).
  @override
  @JsonKey()
  final int material;

  /// Surcharge/slope condition (0=flat, 1=1:1, 2=1:2, 4=1:4).
  @override
  @JsonKey()
  final int surcharge;

  /// Optimization parameter (0=excavation, 1=footing).
  @override
  @JsonKey(name: 'optimization_parameter')
  final int optimizationParameter;

  /// Soil stiffness (0=stiff, 1=soft).
  @override
  @JsonKey(name: 'soil_stiffness')
  final int soilStiffness;

  /// Topsoil thickness in inches.
  @override
  @JsonKey()
  final int topping;

  /// Whether the wall has a slab.
  @override
  @JsonKey(name: 'has_slab')
  final bool hasSlab;

  /// Toe length in inches.
  @override
  @JsonKey()
  final int toe;

  /// Site address where the wall will be built.
  @override
  @JsonKey(name: 'site_address')
  final Address siteAddress;

  /// Customer contact and mailing information.
  @override
  @JsonKey(name: 'customer_info')
  final CustomerInfo customerInfo;

  @override
  String toString() {
    return 'RetainingWallInput(height: $height, material: $material, surcharge: $surcharge, optimizationParameter: $optimizationParameter, soilStiffness: $soilStiffness, topping: $topping, hasSlab: $hasSlab, toe: $toe, siteAddress: $siteAddress, customerInfo: $customerInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RetainingWallInputImpl &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.surcharge, surcharge) ||
                other.surcharge == surcharge) &&
            (identical(other.optimizationParameter, optimizationParameter) ||
                other.optimizationParameter == optimizationParameter) &&
            (identical(other.soilStiffness, soilStiffness) ||
                other.soilStiffness == soilStiffness) &&
            (identical(other.topping, topping) || other.topping == topping) &&
            (identical(other.hasSlab, hasSlab) || other.hasSlab == hasSlab) &&
            (identical(other.toe, toe) || other.toe == toe) &&
            (identical(other.siteAddress, siteAddress) ||
                other.siteAddress == siteAddress) &&
            (identical(other.customerInfo, customerInfo) ||
                other.customerInfo == customerInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    height,
    material,
    surcharge,
    optimizationParameter,
    soilStiffness,
    topping,
    hasSlab,
    toe,
    siteAddress,
    customerInfo,
  );

  /// Create a copy of RetainingWallInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RetainingWallInputImplCopyWith<_$RetainingWallInputImpl> get copyWith =>
      __$$RetainingWallInputImplCopyWithImpl<_$RetainingWallInputImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RetainingWallInputImplToJson(this);
  }
}

abstract class _RetainingWallInput implements RetainingWallInput {
  const factory _RetainingWallInput({
    final double height,
    final int material,
    final int surcharge,
    @JsonKey(name: 'optimization_parameter') final int optimizationParameter,
    @JsonKey(name: 'soil_stiffness') final int soilStiffness,
    final int topping,
    @JsonKey(name: 'has_slab') final bool hasSlab,
    final int toe,
    @JsonKey(name: 'site_address') final Address siteAddress,
    @JsonKey(name: 'customer_info') final CustomerInfo customerInfo,
  }) = _$RetainingWallInputImpl;

  factory _RetainingWallInput.fromJson(Map<String, dynamic> json) =
      _$RetainingWallInputImpl.fromJson;

  /// Wall height in inches (24-144).
  @override
  double get height;

  /// Material type (0=concrete, 1=CMU).
  @override
  int get material;

  /// Surcharge/slope condition (0=flat, 1=1:1, 2=1:2, 4=1:4).
  @override
  int get surcharge;

  /// Optimization parameter (0=excavation, 1=footing).
  @override
  @JsonKey(name: 'optimization_parameter')
  int get optimizationParameter;

  /// Soil stiffness (0=stiff, 1=soft).
  @override
  @JsonKey(name: 'soil_stiffness')
  int get soilStiffness;

  /// Topsoil thickness in inches.
  @override
  int get topping;

  /// Whether the wall has a slab.
  @override
  @JsonKey(name: 'has_slab')
  bool get hasSlab;

  /// Toe length in inches.
  @override
  int get toe;

  /// Site address where the wall will be built.
  @override
  @JsonKey(name: 'site_address')
  Address get siteAddress;

  /// Customer contact and mailing information.
  @override
  @JsonKey(name: 'customer_info')
  CustomerInfo get customerInfo;

  /// Create a copy of RetainingWallInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RetainingWallInputImplCopyWith<_$RetainingWallInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
