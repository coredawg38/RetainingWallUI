/// Application Constants
///
/// Centralized configuration values for the Retaining Wall Design application.
/// Includes API endpoints, validation constraints, and pricing tiers.
library;

import '../config/app_config.dart';

/// API configuration constants.
abstract final class ApiConstants {
  /// Base URL for the rwcpp server.
  /// Configured via --dart-define=API_BASE_URL=...
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// Design submission endpoint.
  static const String designEndpoint = '/api/v1/design';

  /// Preview PDF generation endpoint (no payment required).
  static const String previewEndpoint = '/api/v1/preview';

  /// Test detailed PDF generation endpoint (no payment required).
  static const String testEndpoint = '/api/v1/test';

  /// Status check endpoint (append /{requestId}).
  static const String statusEndpoint = '/api/v1/status';

  /// File download base endpoint (append /{requestId}/{filename}).
  static const String filesEndpoint = '/files';

  /// Health check endpoint.
  static const String healthEndpoint = '/health';

  /// Default request timeout in seconds.
  static const int timeoutSeconds = 30;
}

/// Stripe configuration constants.
abstract final class StripeConstants {
  /// Stripe publishable key.
  /// Configured via --dart-define=STRIPE_PUBLISHABLE_KEY=...
  /// Get test keys from: https://dashboard.stripe.com/test/apikeys
  static String get publishableKey => AppConfig.stripePublishableKey;

  /// Backend URL for creating payment intents.
  /// This should point to your backend server that handles Stripe API calls.
  static String get paymentIntentEndpoint => '${ApiConstants.baseUrl}/api/v1/create-payment-intent';

  /// Currency for payments.
  static const String currency = 'usd';

  /// Merchant display name shown in payment sheet.
  static const String merchantDisplayName = 'Retaining Wall Builder';
}

/// Wall parameter validation constraints.
abstract final class WallConstraints {
  /// Minimum wall height in inches.
  static const double minHeight = 24.0;

  /// Maximum wall height in inches.
  static const double maxHeight = 144.0;

  /// Default wall height in inches.
  static const double defaultHeight = 48.0;

  /// Minimum toe length in inches.
  static const int minToe = 0;

  /// Maximum toe length in inches.
  static const int maxToe = 120;

  /// Default toe length in inches.
  static const int defaultToe = 12;

  /// Minimum topping (topsoil) thickness in inches.
  static const int minTopping = 0;

  /// Maximum topping thickness in inches.
  static const int maxTopping = 24;

  /// Default topping thickness in inches.
  static const int defaultTopping = 2;
}

/// Wall material type enumeration values.
///
/// These values correspond to the rwcpp server's material parameter.
/// Named WallMaterialType to avoid conflict with Flutter's MaterialType.
abstract final class WallMaterialType {
  /// Concrete material.
  static const int concrete = 0;

  /// Concrete Masonry Unit (CMU) material.
  static const int cmu = 1;

  /// Human-readable labels for material types.
  static const Map<int, String> labels = {
    concrete: 'Concrete',
    cmu: 'CMU (Concrete Masonry Unit)',
  };
}

/// Surcharge type enumeration values.
///
/// Represents the slope condition above the wall.
abstract final class SurchargeType {
  /// Flat ground (no slope).
  static const int flat = 0;

  /// 1:1 slope (45 degrees).
  static const int slope1to1 = 1;

  /// 1:2 slope.
  static const int slope1to2 = 2;

  /// 1:4 slope.
  static const int slope1to4 = 4;

  /// Human-readable labels for surcharge types.
  static const Map<int, String> labels = {
    flat: 'Flat (No Slope)',
    slope1to1: '1:1 Slope (45 degrees)',
    slope1to2: '1:2 Slope',
    slope1to4: '1:4 Slope',
  };
}

/// Optimization parameter enumeration values.
abstract final class OptimizationType {
  /// Optimize for minimal excavation.
  static const int excavation = 0;

  /// Optimize for minimal footing size.
  static const int footing = 1;

  /// Human-readable labels for optimization types.
  static const Map<int, String> labels = {
    excavation: 'Minimize Excavation',
    footing: 'Minimize Footing',
  };
}

/// Soil stiffness enumeration values.
abstract final class SoilStiffnessType {
  /// Stiff soil conditions.
  static const int stiff = 0;

  /// Soft soil conditions.
  static const int soft = 1;

  /// Human-readable labels for soil stiffness types.
  static const Map<int, String> labels = {
    stiff: 'Stiff Soil',
    soft: 'Soft Soil',
  };
}

/// Flat pricing for wall designs.
abstract final class PricingTiers {
  /// Single flat price for all wall designs.
  static const double price = 500.0;

  /// Returns the flat design price (height is unused; kept for call-site compatibility).
  static double calculatePrice(double heightInches) => price;

  /// Returns a description for the order summary.
  static String getTierDescription(double heightInches) =>
      'Retaining Wall Design';
}

/// Design wizard step identifiers.
enum WizardStep {
  /// Wall parameters input step.
  parameters,

  /// Customer and address information step.
  customerInfo,

  /// Payment processing step.
  payment,

  /// Document delivery step.
  delivery,
}

/// Extension to add display names to wizard steps.
extension WizardStepExtension on WizardStep {
  /// Human-readable name for the wizard step.
  String get displayName {
    switch (this) {
      case WizardStep.parameters:
        return 'Wall Parameters';
      case WizardStep.customerInfo:
        return 'Customer Info';
      case WizardStep.payment:
        return 'Payment';
      case WizardStep.delivery:
        return 'Delivery';
    }
  }

  /// Icon for the wizard step.
  int get iconCodePoint {
    switch (this) {
      case WizardStep.parameters:
        return 0xe87e; // Icons.architecture
      case WizardStep.customerInfo:
        return 0xe7fd; // Icons.person
      case WizardStep.payment:
        return 0xe8a1; // Icons.payment
      case WizardStep.delivery:
        return 0xe2c0; // Icons.download
    }
  }
}
