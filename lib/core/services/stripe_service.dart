/// Stripe Payment Service
///
/// Handles Stripe payment integration for web and mobile platforms.
/// Uses flutter_stripe for native platforms and flutter_stripe_web for web.
///
/// Usage:
/// ```dart
/// final stripeService = StripeService();
/// await stripeService.initialize();
/// final result = await stripeService.processPayment(amount: 99.99, email: 'user@example.com');
/// ```
library;

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

/// Result of a payment operation.
class PaymentResult {
  /// Whether the payment was successful.
  final bool success;

  /// Payment intent ID if successful.
  final String? paymentIntentId;

  /// Error message if failed.
  final String? errorMessage;

  /// Transaction ID for successful payments.
  final String? transactionId;

  const PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.errorMessage,
    this.transactionId,
  });

  factory PaymentResult.success({
    required String paymentIntentId,
    String? transactionId,
  }) {
    return PaymentResult(
      success: true,
      paymentIntentId: paymentIntentId,
      transactionId: transactionId ?? paymentIntentId,
    );
  }

  factory PaymentResult.failure(String message) {
    return PaymentResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Response from payment intent creation.
class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;
  final int amount;
  final String currency;

  const PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      clientSecret: json['clientSecret'] as String,
      paymentIntentId: json['paymentIntentId'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
    );
  }
}

/// Service for handling Stripe payments.
class StripeService {
  static StripeService? _instance;
  bool _isInitialized = false;

  final http.Client _httpClient;

  StripeService._({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Gets the singleton instance of StripeService.
  factory StripeService({http.Client? httpClient}) {
    _instance ??= StripeService._(httpClient: httpClient);
    return _instance!;
  }

  /// Whether Stripe has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the Stripe SDK.
  ///
  /// Must be called before any payment operations.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      Stripe.publishableKey = StripeConstants.publishableKey;

      // Set merchant identifier for Apple Pay (optional)
      Stripe.merchantIdentifier = 'merchant.com.retainingwall.builder';

      // Enable URL scheme for deep links (mobile)
      Stripe.urlScheme = 'retainingwallbuilder';

      await Stripe.instance.applySettings();

      _isInitialized = true;
      debugPrint('Stripe initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Stripe: $e');
      rethrow;
    }
  }

  /// Creates a payment intent on the backend.
  ///
  /// [amount] is the amount in dollars (e.g., 99.99).
  /// [email] is the customer's email address.
  /// [metadata] is optional additional data to attach to the payment.
  Future<PaymentIntentResponse> createPaymentIntent({
    required double amount,
    required String email,
    Map<String, String>? metadata,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(StripeConstants.paymentIntentEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': (amount * 100).round(), // Convert to cents
          'currency': StripeConstants.currency,
          'email': email,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PaymentIntentResponse.fromJson(json);
      } else {
        throw Exception(
          'Failed to create payment intent: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      rethrow;
    }
  }

  /// Processes a payment using the Stripe Payment Sheet.
  ///
  /// [amount] is the amount in dollars.
  /// [email] is the customer's email address.
  /// [customerName] is the customer's name for the payment sheet.
  /// [metadata] is optional additional data to attach to the payment.
  Future<PaymentResult> processPayment({
    required double amount,
    required String email,
    String? customerName,
    Map<String, String>? metadata,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Step 1: Create payment intent on backend
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        email: email,
        metadata: metadata,
      );

      // Step 2: Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: StripeConstants.merchantDisplayName,
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF1976D2),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
            ),
          ),
          billingDetails: BillingDetails(
            email: email,
            name: customerName,
          ),
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
            name: CollectionMode.automatic,
            email: CollectionMode.automatic,
            address: AddressCollectionMode.automatic,
          ),
        ),
      );

      // Step 3: Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Payment successful
      return PaymentResult.success(
        paymentIntentId: paymentIntent.paymentIntentId,
        transactionId: paymentIntent.paymentIntentId,
      );
    } on StripeException catch (e) {
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      return PaymentResult.failure(
        e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      debugPrint('Payment error: $e');
      return PaymentResult.failure('Payment failed: $e');
    }
  }

  /// Confirms a payment using card details directly.
  ///
  /// This is an alternative to the Payment Sheet for more control.
  /// [clientSecret] is the client secret from the payment intent.
  /// [cardDetails] contains the card information.
  Future<PaymentResult> confirmPaymentWithCard({
    required String clientSecret,
    required CardDetails cardDetails,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Create the card payment method
      await Stripe.instance.dangerouslyUpdateCardDetails(cardDetails);

      // Confirm the payment
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
      );

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        return PaymentResult.success(
          paymentIntentId: paymentIntent.id,
          transactionId: paymentIntent.id,
        );
      } else if (paymentIntent.status == PaymentIntentsStatus.RequiresAction) {
        // Handle 3D Secure authentication
        final result = await Stripe.instance.handleNextAction(clientSecret);
        if (result.status == PaymentIntentsStatus.Succeeded) {
          return PaymentResult.success(
            paymentIntentId: result.id,
            transactionId: result.id,
          );
        } else {
          return PaymentResult.failure('Authentication required');
        }
      } else {
        return PaymentResult.failure(
          'Payment not completed: ${paymentIntent.status}',
        );
      }
    } on StripeException catch (e) {
      return PaymentResult.failure(
        e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      return PaymentResult.failure('Payment failed: $e');
    }
  }

  /// Validates card details format.
  ///
  /// Returns null if valid, or an error message if invalid.
  String? validateCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s'), '');
    if (cleanNumber.isEmpty) {
      return 'Card number is required';
    }
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'Invalid card number length';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanNumber)) {
      return 'Card number must contain only digits';
    }
    // Luhn algorithm check
    if (!_luhnCheck(cleanNumber)) {
      return 'Invalid card number';
    }
    return null;
  }

  /// Validates expiry date format.
  String? validateExpiryDate(String expiry) {
    final parts = expiry.split('/');
    if (parts.length != 2) {
      return 'Use MM/YY format';
    }
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) {
      return 'Invalid expiry date';
    }
    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    final now = DateTime.now();
    final fullYear = 2000 + year;
    if (fullYear < now.year ||
        (fullYear == now.year && month < now.month)) {
      return 'Card has expired';
    }
    return null;
  }

  /// Validates CVC format.
  String? validateCvc(String cvc) {
    if (cvc.isEmpty) {
      return 'CVC is required';
    }
    if (cvc.length < 3 || cvc.length > 4) {
      return 'Invalid CVC';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cvc)) {
      return 'CVC must contain only digits';
    }
    return null;
  }

  /// Luhn algorithm for card number validation.
  bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// Formats a card number with spaces every 4 digits.
  String formatCardNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'\s'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  /// Formats expiry date as MM/YY.
  String formatExpiryDate(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 2) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    return cleaned;
  }

  /// Disposes resources.
  void dispose() {
    _httpClient.close();
    _instance = null;
  }
}

/// Card brand detection.
enum CardBrand {
  visa,
  mastercard,
  amex,
  discover,
  dinersClub,
  jcb,
  unionPay,
  unknown,
}

/// Extension to detect card brand from number.
extension CardBrandDetection on String {
  CardBrand get cardBrand {
    final cleaned = replaceAll(RegExp(r'\s'), '');
    if (cleaned.isEmpty) return CardBrand.unknown;

    if (cleaned.startsWith('4')) {
      return CardBrand.visa;
    } else if (cleaned.startsWith(RegExp(r'^5[1-5]')) ||
        cleaned.startsWith(RegExp(r'^2[2-7]'))) {
      return CardBrand.mastercard;
    } else if (cleaned.startsWith('34') || cleaned.startsWith('37')) {
      return CardBrand.amex;
    } else if (cleaned.startsWith('6011') ||
        cleaned.startsWith('65') ||
        cleaned.startsWith(RegExp(r'^64[4-9]'))) {
      return CardBrand.discover;
    } else if (cleaned.startsWith('36') ||
        cleaned.startsWith('38') ||
        cleaned.startsWith(RegExp(r'^30[0-5]'))) {
      return CardBrand.dinersClub;
    } else if (cleaned.startsWith('35')) {
      return CardBrand.jcb;
    } else if (cleaned.startsWith('62')) {
      return CardBrand.unionPay;
    }
    return CardBrand.unknown;
  }
}
