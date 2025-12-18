// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retaining_wall_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  street: json['street'] as String? ?? '',
  city: json['City'] as String? ?? '',
  state: json['State'] as String? ?? '',
  zipCode: (json['Zip Code'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'street': instance.street,
  'City': instance.city,
  'State': instance.state,
  'Zip Code': instance.zipCode,
};

_CustomerInfo _$CustomerInfoFromJson(Map<String, dynamic> json) =>
    _CustomerInfo(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      mailingAddress: json['mailing_address'] == null
          ? const Address()
          : Address.fromJson(json['mailing_address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CustomerInfoToJson(_CustomerInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'mailing_address': instance.mailingAddress.toJson(),
    };

_RetainingWallInput _$RetainingWallInputFromJson(
  Map<String, dynamic> json,
) => _RetainingWallInput(
  height: (json['height'] as num?)?.toDouble() ?? WallConstraints.defaultHeight,
  material: (json['material'] as num?)?.toInt() ?? WallMaterialType.cmu,
  surcharge: (json['surcharge'] as num?)?.toInt() ?? SurchargeType.flat,
  optimizationParameter:
      (json['optimization_parameter'] as num?)?.toInt() ??
      OptimizationType.excavation,
  soilStiffness:
      (json['soil_stiffness'] as num?)?.toInt() ?? SoilStiffnessType.stiff,
  topping: (json['topping'] as num?)?.toInt() ?? WallConstraints.defaultTopping,
  hasSlab: json['has_slab'] as bool? ?? false,
  toe: (json['toe'] as num?)?.toInt() ?? WallConstraints.defaultToe,
  siteAddress: json['site_address'] == null
      ? const Address()
      : Address.fromJson(json['site_address'] as Map<String, dynamic>),
  customerInfo: json['customer_info'] == null
      ? const CustomerInfo()
      : CustomerInfo.fromJson(json['customer_info'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RetainingWallInputToJson(_RetainingWallInput instance) =>
    <String, dynamic>{
      'height': instance.height,
      'material': instance.material,
      'surcharge': instance.surcharge,
      'optimization_parameter': instance.optimizationParameter,
      'soil_stiffness': instance.soilStiffness,
      'topping': instance.topping,
      'has_slab': instance.hasSlab,
      'toe': instance.toe,
      'site_address': instance.siteAddress.toJson(),
      'customer_info': instance.customerInfo.toJson(),
    };
