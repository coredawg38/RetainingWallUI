/// Wall Input Providers
///
/// Riverpod providers for managing wall input state, validation,
/// and API interactions.
///
/// Usage:
/// ```dart
/// // Read current input
/// final input = ref.watch(wallInputProvider);
///
/// // Update height
/// ref.read(wallInputProvider.notifier).updateHeight(96.0);
///
/// // Submit design
/// await ref.read(wallInputProvider.notifier).submitDesign();
/// ```
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../data/models/retaining_wall_input.dart';
import '../domain/validators/wall_input_validator.dart';

/// Provider for the API client instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.dispose);
  return client;
});

/// Provider for the wall input validator.
final wallInputValidatorProvider = Provider<WallInputValidator>((ref) {
  final validator = WallInputValidator();
  validator.initialize();
  return validator;
});

/// State class for wall input with submission status.
class WallInputState {
  /// The current wall input data.
  final RetainingWallInput input;

  /// Current wizard step.
  final WizardStep currentStep;

  /// Whether a submission is in progress.
  final bool isSubmitting;

  /// Last submission response, if any.
  final DesignResponse? lastResponse;

  /// Current validation errors, if any.
  final List<String> validationErrors;

  /// Error message from last operation, if any.
  final String? errorMessage;

  const WallInputState({
    this.input = const RetainingWallInput(),
    this.currentStep = WizardStep.parameters,
    this.isSubmitting = false,
    this.lastResponse,
    this.validationErrors = const [],
    this.errorMessage,
  });

  /// Creates a copy with the given fields updated.
  WallInputState copyWith({
    RetainingWallInput? input,
    WizardStep? currentStep,
    bool? isSubmitting,
    DesignResponse? lastResponse,
    List<String>? validationErrors,
    String? errorMessage,
  }) {
    return WallInputState(
      input: input ?? this.input,
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastResponse: lastResponse ?? this.lastResponse,
      validationErrors: validationErrors ?? this.validationErrors,
      errorMessage: errorMessage,
    );
  }

  /// Whether the current step can proceed to the next.
  bool get canProceed {
    switch (currentStep) {
      case WizardStep.parameters:
        return input.hasValidWallParameters && input.hasValidSiteAddress;
      case WizardStep.customerInfo:
        return input.hasValidCustomerInfo;
      case WizardStep.payment:
        return lastResponse?.success == true;
      case WizardStep.delivery:
        return true;
    }
  }

  /// Whether there is a previous step to go back to.
  bool get canGoBack => currentStep != WizardStep.parameters;

  /// The calculated price based on wall height.
  double get price => input.price;

  /// The pricing tier description.
  String get priceTierDescription => input.priceTierDescription;
}

/// Notifier for managing wall input state.
class WallInputNotifier extends Notifier<WallInputState> {
  @override
  WallInputState build() {
    return const WallInputState();
  }

  ApiClient get _apiClient => ref.read(apiClientProvider);
  WallInputValidator get _validator => ref.read(wallInputValidatorProvider);

  /// Updates the wall height.
  void updateHeight(double height) {
    state = state.copyWith(
      input: state.input.copyWith(height: height),
    );
  }

  /// Updates the material type.
  void updateMaterial(int material) {
    state = state.copyWith(
      input: state.input.copyWith(material: material),
    );
  }

  /// Updates the surcharge type.
  void updateSurcharge(int surcharge) {
    state = state.copyWith(
      input: state.input.copyWith(surcharge: surcharge),
    );
  }

  /// Updates the optimization parameter.
  void updateOptimizationParameter(int optimizationParameter) {
    state = state.copyWith(
      input: state.input.copyWith(optimizationParameter: optimizationParameter),
    );
  }

  /// Updates the soil stiffness.
  void updateSoilStiffness(int soilStiffness) {
    state = state.copyWith(
      input: state.input.copyWith(soilStiffness: soilStiffness),
    );
  }

  /// Updates the topping thickness.
  void updateTopping(int topping) {
    state = state.copyWith(
      input: state.input.copyWith(topping: topping),
    );
  }

  /// Updates whether the wall has a slab.
  void updateHasSlab(bool hasSlab) {
    state = state.copyWith(
      input: state.input.copyWith(hasSlab: hasSlab),
    );
  }

  /// Updates the toe length.
  void updateToe(int toe) {
    state = state.copyWith(
      input: state.input.copyWith(toe: toe),
    );
  }

  /// Updates the site address.
  void updateSiteAddress(Address address) {
    state = state.copyWith(
      input: state.input.copyWith(siteAddress: address),
    );
  }

  /// Updates the customer info.
  void updateCustomerInfo(CustomerInfo customerInfo) {
    state = state.copyWith(
      input: state.input.copyWith(customerInfo: customerInfo),
    );
  }

  /// Updates the site address street.
  void updateSiteStreet(String street) {
    state = state.copyWith(
      input: state.input.copyWith(
        siteAddress: state.input.siteAddress.copyWith(street: street),
      ),
    );
  }

  /// Updates the site address city.
  void updateSiteCity(String city) {
    state = state.copyWith(
      input: state.input.copyWith(
        siteAddress: state.input.siteAddress.copyWith(city: city),
      ),
    );
  }

  /// Updates the site address state.
  void updateSiteState(String stateAbbr) {
    state = state.copyWith(
      input: state.input.copyWith(
        siteAddress: state.input.siteAddress.copyWith(state: stateAbbr),
      ),
    );
  }

  /// Updates the site address ZIP code.
  void updateSiteZipCode(int zipCode) {
    state = state.copyWith(
      input: state.input.copyWith(
        siteAddress: state.input.siteAddress.copyWith(zipCode: zipCode),
      ),
    );
  }

  /// Updates the customer name.
  void updateCustomerName(String name) {
    state = state.copyWith(
      input: state.input.copyWith(
        customerInfo: state.input.customerInfo.copyWith(name: name),
      ),
    );
  }

  /// Updates the customer email.
  void updateCustomerEmail(String email) {
    state = state.copyWith(
      input: state.input.copyWith(
        customerInfo: state.input.customerInfo.copyWith(email: email),
      ),
    );
  }

  /// Updates the customer phone.
  void updateCustomerPhone(String phone) {
    state = state.copyWith(
      input: state.input.copyWith(
        customerInfo: state.input.customerInfo.copyWith(phone: phone),
      ),
    );
  }

  /// Updates the mailing address.
  void updateMailingAddress(Address address) {
    state = state.copyWith(
      input: state.input.copyWith(
        customerInfo: state.input.customerInfo.copyWith(mailingAddress: address),
      ),
    );
  }

  /// Copies site address to mailing address.
  void copySiteToMailingAddress() {
    state = state.copyWith(
      input: state.input.copyWith(
        customerInfo: state.input.customerInfo.copyWith(
          mailingAddress: state.input.siteAddress,
        ),
      ),
    );
  }

  /// Advances to the next wizard step.
  void nextStep() {
    final steps = WizardStep.values;
    final currentIndex = steps.indexOf(state.currentStep);
    if (currentIndex < steps.length - 1) {
      state = state.copyWith(currentStep: steps[currentIndex + 1]);
    }
  }

  /// Goes back to the previous wizard step.
  void previousStep() {
    final steps = WizardStep.values;
    final currentIndex = steps.indexOf(state.currentStep);
    if (currentIndex > 0) {
      state = state.copyWith(currentStep: steps[currentIndex - 1]);
    }
  }

  /// Goes to a specific wizard step.
  void goToStep(WizardStep step) {
    state = state.copyWith(currentStep: step);
  }

  /// Validates the current input.
  bool validate() {
    final result = _validator.validate(state.input.toJson());
    state = state.copyWith(
      validationErrors: result.errors,
      errorMessage: result.isValid ? null : result.errors.firstOrNull,
    );
    return result.isValid;
  }

  /// Submits the design to the server.
  Future<bool> submitDesign() async {
    if (!validate()) {
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
    );

    try {
      final response = await _apiClient.submitDesign(state.input.toJson());

      state = state.copyWith(
        isSubmitting: false,
        lastResponse: response,
        errorMessage: response.success ? null : response.errorMessage,
      );

      return response.success;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit design: $e',
      );
      return false;
    }
  }

  /// Resets the state to initial values.
  void reset() {
    state = const WallInputState();
  }

  /// Clears any error messages.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for the wall input state and notifier.
final wallInputProvider =
    NotifierProvider<WallInputNotifier, WallInputState>(WallInputNotifier.new);

/// Provider for just the current wall input (convenience accessor).
final currentWallInputProvider = Provider<RetainingWallInput>((ref) {
  return ref.watch(wallInputProvider.select((state) => state.input));
});

/// Provider for the current wizard step.
final currentWizardStepProvider = Provider<WizardStep>((ref) {
  return ref.watch(wallInputProvider.select((state) => state.currentStep));
});

/// Provider for the calculated price.
final wallPriceProvider = Provider<double>((ref) {
  return ref.watch(wallInputProvider.select((state) => state.price));
});

/// Provider for whether submission is in progress.
final isSubmittingProvider = Provider<bool>((ref) {
  return ref.watch(wallInputProvider.select((state) => state.isSubmitting));
});

/// Provider for the last design response.
final lastDesignResponseProvider = Provider<DesignResponse?>((ref) {
  return ref.watch(wallInputProvider.select((state) => state.lastResponse));
});
