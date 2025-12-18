/// Payment Providers
///
/// Riverpod providers for managing payment state and Stripe integration.
///
/// Usage:
/// ```dart
/// // Check if payment is complete
/// final isPaid = ref.watch(paymentCompleteProvider);
///
/// // Process payment with Stripe
/// await ref.read(paymentProvider.notifier).processPayment(
///   amount: 99.99,
///   email: 'user@example.com',
/// );
/// ```
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../core/services/stripe_service.dart';

/// Logger for payment provider operations.
class PaymentLogger {
  static const String _tag = '[Payment]';

  static void info(String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('$_tag $timestamp INFO: $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('$_tag $timestamp ERROR: $message');
    if (error != null) {
      debugPrint('$_tag $timestamp ERROR DETAILS: $error');
    }
    if (stackTrace != null) {
      debugPrint('$_tag $timestamp STACK TRACE: $stackTrace');
    }
  }

  static void state(String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('$_tag $timestamp STATE: $message');
  }
}

/// Payment status enumeration.
enum PaymentStatus {
  /// Payment not yet initiated.
  pending,

  /// Payment is being processed.
  processing,

  /// Payment completed successfully.
  completed,

  /// Payment failed.
  failed,

  /// Payment was cancelled.
  cancelled,

  /// Waiting for 3D Secure authentication.
  requiresAuthentication,
}

/// State class for payment processing.
class PaymentState {
  /// Current payment status.
  final PaymentStatus status;

  /// Amount to be charged in dollars.
  final double amount;

  /// Payment intent ID from Stripe.
  final String? paymentIntentId;

  /// Client secret for the payment intent.
  final String? clientSecret;

  /// Transaction ID after successful payment.
  final String? transactionId;

  /// Error message if payment failed.
  final String? errorMessage;

  /// Timestamp when payment was initiated.
  final DateTime? initiatedAt;

  /// Timestamp when payment was completed.
  final DateTime? completedAt;

  /// Card details for manual entry.
  final CardFormState? cardFormState;

  const PaymentState({
    this.status = PaymentStatus.pending,
    this.amount = 0.0,
    this.paymentIntentId,
    this.clientSecret,
    this.transactionId,
    this.errorMessage,
    this.initiatedAt,
    this.completedAt,
    this.cardFormState,
  });

  /// Creates a copy with the given fields updated.
  PaymentState copyWith({
    PaymentStatus? status,
    double? amount,
    String? paymentIntentId,
    String? clientSecret,
    String? transactionId,
    String? errorMessage,
    DateTime? initiatedAt,
    DateTime? completedAt,
    CardFormState? cardFormState,
  }) {
    return PaymentState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      clientSecret: clientSecret ?? this.clientSecret,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: errorMessage,
      initiatedAt: initiatedAt ?? this.initiatedAt,
      completedAt: completedAt ?? this.completedAt,
      cardFormState: cardFormState ?? this.cardFormState,
    );
  }

  /// Whether payment has been completed successfully.
  bool get isComplete => status == PaymentStatus.completed;

  /// Whether payment is currently processing.
  bool get isProcessing => status == PaymentStatus.processing;

  /// Whether payment has failed.
  bool get hasFailed => status == PaymentStatus.failed;

  /// Whether payment can be initiated.
  bool get canPay =>
      status == PaymentStatus.pending ||
      status == PaymentStatus.failed ||
      status == PaymentStatus.cancelled;

  /// Whether authentication is required.
  bool get requiresAuth => status == PaymentStatus.requiresAuthentication;
}

/// Card form state for manual card entry.
class CardFormState {
  final String cardNumber;
  final String expiryDate;
  final String cvc;
  final String cardholderName;
  final String? cardNumberError;
  final String? expiryError;
  final String? cvcError;
  final bool isValid;

  const CardFormState({
    this.cardNumber = '',
    this.expiryDate = '',
    this.cvc = '',
    this.cardholderName = '',
    this.cardNumberError,
    this.expiryError,
    this.cvcError,
    this.isValid = false,
  });

  CardFormState copyWith({
    String? cardNumber,
    String? expiryDate,
    String? cvc,
    String? cardholderName,
    String? cardNumberError,
    String? expiryError,
    String? cvcError,
    bool? isValid,
  }) {
    return CardFormState(
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvc: cvc ?? this.cvc,
      cardholderName: cardholderName ?? this.cardholderName,
      cardNumberError: cardNumberError,
      expiryError: expiryError,
      cvcError: cvcError,
      isValid: isValid ?? this.isValid,
    );
  }
}

/// Notifier for managing payment state with Stripe integration.
class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() {
    return const PaymentState();
  }

  StripeService get _stripeService => ref.read(stripeServiceProvider);

  /// Initializes Stripe SDK.
  Future<void> initializeStripe() async {
    PaymentLogger.info('initializeStripe() called');
    try {
      await _stripeService.initialize();
      PaymentLogger.info('Stripe initialization completed');
    } catch (e, stackTrace) {
      PaymentLogger.error('Failed to initialize Stripe', e, stackTrace);
    }
  }

  /// Sets the payment amount.
  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  /// Updates card form field.
  void updateCardField({
    String? cardNumber,
    String? expiryDate,
    String? cvc,
    String? cardholderName,
  }) {
    final currentForm = state.cardFormState ?? const CardFormState();

    String? cardNumError;
    String? expError;
    String? cvcErr;

    final newCardNumber = cardNumber ?? currentForm.cardNumber;
    final newExpiry = expiryDate ?? currentForm.expiryDate;
    final newCvc = cvc ?? currentForm.cvc;
    final newName = cardholderName ?? currentForm.cardholderName;

    // Validate only if field has content
    if (newCardNumber.isNotEmpty) {
      cardNumError = _stripeService.validateCardNumber(newCardNumber);
    }
    if (newExpiry.isNotEmpty) {
      expError = _stripeService.validateExpiryDate(newExpiry);
    }
    if (newCvc.isNotEmpty) {
      cvcErr = _stripeService.validateCvc(newCvc);
    }

    final isValid = cardNumError == null &&
        expError == null &&
        cvcErr == null &&
        newCardNumber.replaceAll(' ', '').length >= 13 &&
        newExpiry.length >= 5 &&
        newCvc.length >= 3 &&
        newName.isNotEmpty;

    state = state.copyWith(
      cardFormState: CardFormState(
        cardNumber: cardNumber != null
            ? _stripeService.formatCardNumber(cardNumber)
            : currentForm.cardNumber,
        expiryDate: expiryDate != null
            ? _stripeService.formatExpiryDate(expiryDate)
            : currentForm.expiryDate,
        cvc: cvc ?? currentForm.cvc,
        cardholderName: cardholderName ?? currentForm.cardholderName,
        cardNumberError: cardNumError,
        expiryError: expError,
        cvcError: cvcErr,
        isValid: isValid,
      ),
    );
  }

  /// Processes payment using Stripe Payment Sheet.
  ///
  /// This is the recommended approach for most use cases.
  Future<bool> processPayment({
    required double amount,
    required String email,
    String? customerName,
    Map<String, String>? metadata,
  }) async {
    PaymentLogger.info('processPayment() called');
    PaymentLogger.info('Amount: \$$amount, Email: $email, Name: $customerName');

    PaymentLogger.state('Transitioning to PROCESSING');
    state = state.copyWith(
      status: PaymentStatus.processing,
      amount: amount,
      initiatedAt: DateTime.now(),
      errorMessage: null,
    );

    try {
      PaymentLogger.info('Calling _stripeService.processPayment()...');
      final result = await _stripeService.processPayment(
        amount: amount,
        email: email,
        customerName: customerName,
        metadata: metadata,
      );

      PaymentLogger.info('Payment result received: success=${result.success}');
      if (result.success) {
        PaymentLogger.state('Transitioning to COMPLETED');
        PaymentLogger.info('Transaction ID: ${result.transactionId}');
        state = state.copyWith(
          status: PaymentStatus.completed,
          paymentIntentId: result.paymentIntentId,
          transactionId: result.transactionId,
          completedAt: DateTime.now(),
        );
        return true;
      } else {
        PaymentLogger.state('Transitioning to FAILED');
        PaymentLogger.error('Payment failed: ${result.errorMessage}');
        state = state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: result.errorMessage,
        );
        return false;
      }
    } catch (e, stackTrace) {
      PaymentLogger.state('Transitioning to FAILED (exception)');
      PaymentLogger.error('Payment exception', e, stackTrace);
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Payment failed: $e',
      );
      return false;
    }
  }

  /// Processes payment using card details from form.
  ///
  /// Use this for custom card input forms.
  Future<bool> processPaymentWithCard({
    required double amount,
    required String email,
    Map<String, String>? metadata,
  }) async {
    PaymentLogger.info('processPaymentWithCard() called');
    PaymentLogger.info('Amount: \$$amount, Email: $email');

    final cardForm = state.cardFormState;
    if (cardForm == null || !cardForm.isValid) {
      PaymentLogger.error('Invalid card form state: ${cardForm == null ? "null" : "invalid"}');
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Invalid card details',
      );
      return false;
    }

    PaymentLogger.state('Transitioning to PROCESSING');
    state = state.copyWith(
      status: PaymentStatus.processing,
      amount: amount,
      initiatedAt: DateTime.now(),
      errorMessage: null,
    );

    try {
      // Create payment intent first
      PaymentLogger.info('Creating payment intent...');
      final paymentIntent = await _stripeService.createPaymentIntent(
        amount: amount,
        email: email,
        metadata: metadata,
      );
      PaymentLogger.info('Payment intent created: ${paymentIntent.paymentIntentId}');

      state = state.copyWith(
        clientSecret: paymentIntent.clientSecret,
        paymentIntentId: paymentIntent.paymentIntentId,
      );

      // Parse expiry date
      final expiryParts = cardForm.expiryDate.split('/');
      final expMonth = int.parse(expiryParts[0]);
      final expYear = int.parse(expiryParts[1]);
      PaymentLogger.info('Card expiry: $expMonth/${expYear + 2000}');

      // Confirm payment with card
      PaymentLogger.info('Confirming payment with card...');
      final result = await _stripeService.confirmPaymentWithCard(
        clientSecret: paymentIntent.clientSecret,
        cardDetails: CardDetails(
          number: cardForm.cardNumber.replaceAll(' ', ''),
          expirationMonth: expMonth,
          expirationYear: expYear,
          cvc: cardForm.cvc,
        ),
      );

      PaymentLogger.info('Payment result: success=${result.success}');
      if (result.success) {
        PaymentLogger.state('Transitioning to COMPLETED');
        state = state.copyWith(
          status: PaymentStatus.completed,
          transactionId: result.transactionId,
          completedAt: DateTime.now(),
        );
        return true;
      } else {
        PaymentLogger.state('Transitioning to FAILED');
        PaymentLogger.error('Payment failed: ${result.errorMessage}');
        state = state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: result.errorMessage,
        );
        return false;
      }
    } catch (e, stackTrace) {
      PaymentLogger.state('Transitioning to FAILED (exception)');
      PaymentLogger.error('Payment exception', e, stackTrace);
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Payment failed: $e',
      );
      return false;
    }
  }

  /// Simulates a successful payment (for testing/demo).
  Future<bool> simulateSuccessfulPayment(double amount) async {
    state = state.copyWith(
      status: PaymentStatus.processing,
      amount: amount,
      initiatedAt: DateTime.now(),
      errorMessage: null,
    );

    await Future.delayed(const Duration(seconds: 2));

    final transactionId = 'txn_demo_${DateTime.now().millisecondsSinceEpoch}';

    state = state.copyWith(
      status: PaymentStatus.completed,
      transactionId: transactionId,
      paymentIntentId: 'pi_demo_${DateTime.now().millisecondsSinceEpoch}',
      completedAt: DateTime.now(),
    );

    return true;
  }

  /// Simulates a failed payment (for testing).
  Future<bool> simulateFailedPayment(double amount) async {
    state = state.copyWith(
      status: PaymentStatus.processing,
      amount: amount,
      initiatedAt: DateTime.now(),
      errorMessage: null,
    );

    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      status: PaymentStatus.failed,
      errorMessage: 'Payment declined. Please try a different payment method.',
    );

    return false;
  }

  /// Cancels the current payment.
  void cancelPayment() {
    if (state.status == PaymentStatus.processing) {
      state = state.copyWith(
        status: PaymentStatus.cancelled,
        errorMessage: 'Payment was cancelled.',
      );
    }
  }

  /// Resets the payment state.
  void reset() {
    state = const PaymentState();
  }

  /// Clears any error messages.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Marks payment as complete (for demo/testing purposes).
  void markAsComplete() {
    state = state.copyWith(
      status: PaymentStatus.completed,
      transactionId: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      completedAt: DateTime.now(),
    );
  }
}

/// Provider for Stripe service.
final stripeServiceProvider = Provider<StripeService>((ref) {
  final service = StripeService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for payment state and notifier.
final paymentProvider =
    NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);

/// Provider for whether payment is complete.
final paymentCompleteProvider = Provider<bool>((ref) {
  return ref.watch(paymentProvider.select((state) => state.isComplete));
});

/// Provider for whether payment is processing.
final paymentProcessingProvider = Provider<bool>((ref) {
  return ref.watch(paymentProvider.select((state) => state.isProcessing));
});

/// Provider for payment error message.
final paymentErrorProvider = Provider<String?>((ref) {
  return ref.watch(paymentProvider.select((state) => state.errorMessage));
});

/// Provider for card form state.
final cardFormProvider = Provider<CardFormState?>((ref) {
  return ref.watch(paymentProvider.select((state) => state.cardFormState));
});
