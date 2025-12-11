/// Retaining Wall Input Data Models
///
/// Freezed models for retaining wall design input, including wall parameters,
/// site address, and customer information.
///
/// These models match the JSON schema expected by the rwcpp server.
///
/// Usage:
/// ```dart
/// final input = RetainingWallInput(
///   height: 96.0,
///   material: WallMaterialType.cmu,
///   surcharge: SurchargeType.flat,
///   // ...
/// );
/// final json = input.toJson();
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/app_constants.dart';

part 'retaining_wall_input.freezed.dart';
part 'retaining_wall_input.g.dart';

/// Address model for site and mailing addresses.
///
/// Matches the JSON schema with property names as expected by the server.
@freezed
class Address with _$Address {
  const factory Address({
    /// Street address line.
    @Default('') String street,

    /// City name.
    /// Note: JSON key is "City" (capitalized) to match server schema.
    @JsonKey(name: 'City') @Default('') String city,

    /// State abbreviation (e.g., "UT", "CA").
    /// Note: JSON key is "State" (capitalized) to match server schema.
    @JsonKey(name: 'State') @Default('') String state,

    /// ZIP code as integer.
    /// Note: JSON key is "Zip Code" to match server schema.
    @JsonKey(name: 'Zip Code') @Default(0) int zipCode,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

/// Customer information model.
///
/// Contains contact details and mailing address for the customer.
@freezed
class CustomerInfo with _$CustomerInfo {
  const factory CustomerInfo({
    /// Customer's full name.
    @Default('') String name,

    /// Customer's email address.
    @Default('') String email,

    /// Customer's phone number.
    @Default('') String phone,

    /// Customer's mailing address for document delivery.
    @JsonKey(name: 'mailing_address') @Default(Address()) Address mailingAddress,
  }) = _CustomerInfo;

  factory CustomerInfo.fromJson(Map<String, dynamic> json) =>
      _$CustomerInfoFromJson(json);
}

/// Complete retaining wall input specification.
///
/// Contains all parameters needed for wall design calculation:
/// - Wall dimensions (height, toe)
/// - Material and construction options
/// - Site conditions (surcharge, soil stiffness, topping)
/// - Site and customer information
@freezed
class RetainingWallInput with _$RetainingWallInput {
  const factory RetainingWallInput({
    /// Wall height in inches (24-144).
    @Default(WallConstraints.defaultHeight) double height,

    /// Material type (0=concrete, 1=CMU).
    @Default(WallMaterialType.cmu) int material,

    /// Surcharge/slope condition (0=flat, 1=1:1, 2=1:2, 4=1:4).
    @Default(SurchargeType.flat) int surcharge,

    /// Optimization parameter (0=excavation, 1=footing).
    @JsonKey(name: 'optimization_parameter')
    @Default(OptimizationType.excavation)
    int optimizationParameter,

    /// Soil stiffness (0=stiff, 1=soft).
    @JsonKey(name: 'soil_stiffness')
    @Default(SoilStiffnessType.stiff)
    int soilStiffness,

    /// Topsoil thickness in inches.
    @Default(WallConstraints.defaultTopping) int topping,

    /// Whether the wall has a slab.
    @JsonKey(name: 'has_slab') @Default(false) bool hasSlab,

    /// Toe length in inches.
    @Default(WallConstraints.defaultToe) int toe,

    /// Site address where the wall will be built.
    @JsonKey(name: 'site_address') @Default(Address()) Address siteAddress,

    /// Customer contact and mailing information.
    @JsonKey(name: 'customer_info')
    @Default(CustomerInfo())
    CustomerInfo customerInfo,
  }) = _RetainingWallInput;

  factory RetainingWallInput.fromJson(Map<String, dynamic> json) =>
      _$RetainingWallInputFromJson(json);
}

/// Extension methods for [RetainingWallInput].
extension RetainingWallInputExtensions on RetainingWallInput {
  /// Returns the wall height in feet.
  double get heightInFeet => height / 12.0;

  /// Returns the calculated price based on height.
  double get price => PricingTiers.calculatePrice(height);

  /// Returns the pricing tier description.
  String get priceTierDescription => PricingTiers.getTierDescription(height);

  /// Returns true if all required wall parameters are valid.
  bool get hasValidWallParameters {
    return height >= WallConstraints.minHeight &&
        height <= WallConstraints.maxHeight &&
        toe >= WallConstraints.minToe &&
        toe <= WallConstraints.maxToe &&
        topping >= WallConstraints.minTopping &&
        topping <= WallConstraints.maxTopping;
  }

  /// Returns true if all site address fields are filled.
  bool get hasValidSiteAddress {
    return siteAddress.street.isNotEmpty &&
        siteAddress.city.isNotEmpty &&
        siteAddress.state.isNotEmpty &&
        siteAddress.zipCode > 0;
  }

  /// Returns true if the email has a valid format.
  bool get hasValidEmail {
    if (customerInfo.email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    return emailRegex.hasMatch(customerInfo.email);
  }

  /// Returns true if all customer info fields are filled.
  /// Note: Mailing address is not required for digital delivery.
  bool get hasValidCustomerInfo {
    return customerInfo.name.isNotEmpty &&
        customerInfo.email.isNotEmpty &&
        hasValidEmail &&
        customerInfo.phone.isNotEmpty;
  }

  /// Returns true if the entire input is valid for submission.
  bool get isValid =>
      hasValidWallParameters && hasValidSiteAddress && hasValidCustomerInfo;

  /// Returns the material type as a human-readable string.
  String get materialLabel =>
      WallMaterialType.labels[material] ?? 'Unknown';

  /// Returns the surcharge type as a human-readable string.
  String get surchargeLabel =>
      SurchargeType.labels[surcharge] ?? 'Unknown';

  /// Returns the optimization type as a human-readable string.
  String get optimizationLabel =>
      OptimizationType.labels[optimizationParameter] ?? 'Unknown';

  /// Returns the soil stiffness as a human-readable string.
  String get soilStiffnessLabel =>
      SoilStiffnessType.labels[soilStiffness] ?? 'Unknown';
}
