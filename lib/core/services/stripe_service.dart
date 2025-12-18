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
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../constants/app_constants.dart';

/// Simple logger for Stripe operations.
/// Logs to console with timestamps and categories.
class StripeLogger {
  static const String _tag = '[Stripe]';

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

  static void debug(String message) {
    if (AppConfig.debug || !AppConfig.isProduction) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('$_tag $timestamp DEBUG: $message');
    }
  }

  static void http(String method, String url, {int? statusCode, String? body}) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('$_tag $timestamp HTTP $method: $url');
    if (statusCode != null) {
      debugPrint('$_tag $timestamp HTTP RESPONSE: $statusCode');
    }
    if (body != null && body.length < 500) {
      debugPrint('$_tag $timestamp HTTP BODY: $body');
    } else if (body != null) {
      debugPrint('$_tag $timestamp HTTP BODY: ${body.substring(0, 500)}... (truncated)');
    }
  }
}

/// Whether the current platform supports Stripe.
/// Stripe only supports iOS, Android, and Web.
bool get isStripeSupportedPlatform {
  if (kIsWeb) return true;
  if (Platform.isIOS || Platform.isAndroid) return true;
  return false;
}

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
  /// On unsupported platforms (macOS, Windows, Linux), this is a no-op.
  Future<void> initialize() async {
    StripeLogger.info('initialize() called');
    StripeLogger.debug('Environment: ${AppConfig.environment.name}');
    StripeLogger.debug('Is already initialized: $_isInitialized');

    if (_isInitialized) {
      StripeLogger.info('Already initialized, skipping');
      return;
    }

    // Skip initialization on unsupported platforms
    if (!isStripeSupportedPlatform) {
      StripeLogger.info('Platform not supported (kIsWeb=$kIsWeb) - skipping initialization');
      _isInitialized = true; // Mark as initialized to prevent repeated attempts
      return;
    }

    try {
      final publishableKey = StripeConstants.publishableKey;
      StripeLogger.info('Setting publishable key: ${publishableKey.substring(0, 20)}...');
      StripeLogger.debug('Key type: ${publishableKey.startsWith("pk_test") ? "TEST" : "LIVE"}');

      Stripe.publishableKey = publishableKey;

      // Set merchant identifier for Apple Pay (optional)
      Stripe.merchantIdentifier = 'merchant.com.retainingwall.builder';
      StripeLogger.debug('Merchant identifier set');

      // Enable URL scheme for deep links (mobile)
      Stripe.urlScheme = 'retainingwallbuilder';
      StripeLogger.debug('URL scheme set');

      StripeLogger.info('Calling Stripe.instance.applySettings()...');
      await Stripe.instance.applySettings();

      _isInitialized = true;
      StripeLogger.info('Stripe SDK initialized successfully');
    } catch (e, stackTrace) {
      StripeLogger.error('Failed to initialize Stripe SDK', e, stackTrace);
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
    final endpoint = StripeConstants.paymentIntentEndpoint;
    final amountCents = (amount * 100).round();

    StripeLogger.info('createPaymentIntent() called');
    StripeLogger.debug('Amount: \$$amount ($amountCents cents)');
    StripeLogger.debug('Email: $email');
    StripeLogger.debug('Endpoint: $endpoint');

    final requestBody = jsonEncode({
      'amount': amountCents,
      'currency': StripeConstants.currency,
      'email': email,
      'metadata': metadata ?? {},
    });

    StripeLogger.http('POST', endpoint, body: requestBody);

    try {
      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      StripeLogger.http('POST', endpoint, statusCode: response.statusCode, body: response.body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final paymentIntent = PaymentIntentResponse.fromJson(json);
        StripeLogger.info('Payment intent created successfully');
        StripeLogger.debug('Payment intent ID: ${paymentIntent.paymentIntentId}');
        StripeLogger.debug('Client secret (first 20 chars): ${paymentIntent.clientSecret.substring(0, 20)}...');
        return paymentIntent;
      } else {
        StripeLogger.error('Failed to create payment intent: HTTP ${response.statusCode}');
        StripeLogger.error('Response body: ${response.body}');
        throw Exception(
          'Failed to create payment intent: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      StripeLogger.error('Error creating payment intent', e, stackTrace);
      rethrow;
    }
  }

  /// Processes a payment using the appropriate method for the platform.
  ///
  /// - **Mobile (iOS/Android)**: Uses Stripe Payment Sheet for best UX.
  /// - **Web**: Uses CardField + confirmPayment (Payment Sheet not supported on web).
  ///
  /// [amount] is the amount in dollars.
  /// [email] is the customer's email address.
  /// [customerName] is the customer's name for the payment sheet.
  /// [metadata] is optional additional data to attach to the payment.
  /// [billingDetails] optional billing details for web payments.
  ///
  /// On unsupported platforms, returns a demo success result for testing.
  Future<PaymentResult> processPayment({
    required double amount,
    required String email,
    String? customerName,
    Map<String, String>? metadata,
    BillingDetails? billingDetails,
  }) async {
    StripeLogger.info('processPayment() called');
    StripeLogger.debug('Amount: \$$amount');
    StripeLogger.debug('Email: $email');
    StripeLogger.debug('Customer name: $customerName');
    StripeLogger.debug('Is web: $kIsWeb');
    StripeLogger.debug('Is initialized: $_isInitialized');

    if (!_isInitialized) {
      StripeLogger.info('Not initialized, calling initialize()...');
      await initialize();
    }

    // On unsupported platforms, return a demo success for testing
    if (!isStripeSupportedPlatform) {
      StripeLogger.info('Platform not supported - returning demo payment result');
      return PaymentResult.success(
        paymentIntentId: 'demo_pi_${DateTime.now().millisecondsSinceEpoch}',
        transactionId: 'demo_txn_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    // Use different payment flow for web vs mobile
    if (kIsWeb) {
      return _processPaymentWeb(
        amount: amount,
        email: email,
        customerName: customerName,
        metadata: metadata,
        billingDetails: billingDetails,
      );
    } else {
      return _processPaymentMobile(
        amount: amount,
        email: email,
        customerName: customerName,
        metadata: metadata,
      );
    }
  }

  /// Processes payment on web using CardField + confirmPayment.
  ///
  /// On web, Payment Sheet is not supported, so we use:
  /// 1. CardField widget to collect card details
  /// 2. confirmPayment() with PaymentMethodParams.card()
  Future<PaymentResult> _processPaymentWeb({
    required double amount,
    required String email,
    String? customerName,
    Map<String, String>? metadata,
    BillingDetails? billingDetails,
  }) async {
    StripeLogger.info('_processPaymentWeb() - Using web payment flow');

    try {
      // Step 1: Create payment intent on backend
      StripeLogger.info('Step 1: Creating payment intent on backend...');
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        email: email,
        metadata: metadata,
      );
      StripeLogger.info('Step 1 complete: Payment intent created');
      StripeLogger.debug('Client secret: ${paymentIntent.clientSecret.substring(0, 20)}...');

      // Step 2: Confirm payment with card details from CardField
      // The CardField widget collects card details and stores them in Stripe SDK
      StripeLogger.info('Step 2: Confirming payment with card details...');

      final confirmedPayment = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent.clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails ?? BillingDetails(
              email: email,
              name: customerName,
            ),
          ),
        ),
      );
      StripeLogger.info('Step 2 complete: Payment confirmation received');
      StripeLogger.debug('Payment status: ${confirmedPayment.status}');

      // Step 3: Check payment status
      if (confirmedPayment.status == PaymentIntentsStatus.Succeeded) {
        StripeLogger.info('Payment succeeded!');
        return PaymentResult.success(
          paymentIntentId: confirmedPayment.id,
          transactionId: confirmedPayment.id,
        );
      } else if (confirmedPayment.status == PaymentIntentsStatus.RequiresAction) {
        // Handle 3D Secure authentication
        StripeLogger.info('3D Secure authentication required...');
        final result = await Stripe.instance.handleNextAction(
          paymentIntent.clientSecret,
        );

        if (result.status == PaymentIntentsStatus.Succeeded) {
          StripeLogger.info('3D Secure authentication succeeded!');
          return PaymentResult.success(
            paymentIntentId: result.id,
            transactionId: result.id,
          );
        } else {
          StripeLogger.error('3D Secure authentication failed: ${result.status}');
          return PaymentResult.failure('Authentication failed');
        }
      } else {
        StripeLogger.error('Payment not completed: ${confirmedPayment.status}');
        return PaymentResult.failure(
          'Payment not completed: ${confirmedPayment.status}',
        );
      }
    } on StripeException catch (e, stackTrace) {
      StripeLogger.error('Stripe exception in web payment', e, stackTrace);
      StripeLogger.error('Stripe error: ${e.error.localizedMessage}');
      return PaymentResult.failure(
        e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e, stackTrace) {
      StripeLogger.error('Unexpected error in web payment', e, stackTrace);
      return PaymentResult.failure('Payment failed: $e');
    }
  }

  /// Processes payment on mobile using Payment Sheet.
  ///
  /// Payment Sheet provides the best UX on native platforms with:
  /// - Native UI that matches platform conventions
  /// - Built-in card scanning
  /// - Saved payment methods
  /// - Apple Pay / Google Pay integration
  Future<PaymentResult> _processPaymentMobile({
    required double amount,
    required String email,
    String? customerName,
    Map<String, String>? metadata,
  }) async {
    StripeLogger.info('_processPaymentMobile() - Using Payment Sheet');

    try {
      // Step 1: Create payment intent on backend
      StripeLogger.info('Step 1: Creating payment intent on backend...');
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        email: email,
        metadata: metadata,
      );
      StripeLogger.info('Step 1 complete: Payment intent created');

      // Step 2: Initialize the payment sheet
      StripeLogger.info('Step 2: Initializing payment sheet...');
      StripeLogger.debug('Client secret: ${paymentIntent.clientSecret.substring(0, 20)}...');
      StripeLogger.debug('Merchant display name: ${StripeConstants.merchantDisplayName}');

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
      StripeLogger.info('Step 2 complete: Payment sheet initialized');

      // Step 3: Present the payment sheet
      StripeLogger.info('Step 3: Presenting payment sheet to user...');
      await Stripe.instance.presentPaymentSheet();
      StripeLogger.info('Step 3 complete: Payment sheet presented and completed');

      // Step 4: Payment successful
      StripeLogger.info('Step 4: Payment successful!');
      StripeLogger.debug('Payment intent ID: ${paymentIntent.paymentIntentId}');
      return PaymentResult.success(
        paymentIntentId: paymentIntent.paymentIntentId,
        transactionId: paymentIntent.paymentIntentId,
      );
    } on StripeException catch (e, stackTrace) {
      StripeLogger.error('Stripe exception occurred', e, stackTrace);
      StripeLogger.error('Stripe error code: ${e.error.code}');
      StripeLogger.error('Stripe error message: ${e.error.localizedMessage}');
      StripeLogger.error('Stripe error type: ${e.error.stripeErrorCode}');
      return PaymentResult.failure(
        e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e, stackTrace) {
      StripeLogger.error('Unexpected payment error', e, stackTrace);
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
    StripeLogger.info('confirmPaymentWithCard() called');
    StripeLogger.debug('Client secret: ${clientSecret.substring(0, 20)}...');
    StripeLogger.debug('Card number (last 4): ****${cardDetails.number?.substring((cardDetails.number?.length ?? 4) - 4)}');

    if (!_isInitialized) {
      StripeLogger.info('Not initialized, calling initialize()...');
      await initialize();
    }

    try {
      // Create the card payment method
      StripeLogger.info('Updating card details...');
      await Stripe.instance.dangerouslyUpdateCardDetails(cardDetails);
      StripeLogger.info('Card details updated');

      // Confirm the payment
      StripeLogger.info('Confirming payment...');
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
      );
      StripeLogger.info('Payment confirmation response received');
      StripeLogger.debug('Payment status: ${paymentIntent.status}');

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        StripeLogger.info('Payment succeeded!');
        return PaymentResult.success(
          paymentIntentId: paymentIntent.id,
          transactionId: paymentIntent.id,
        );
      } else if (paymentIntent.status == PaymentIntentsStatus.RequiresAction) {
        // Handle 3D Secure authentication
        StripeLogger.info('3D Secure authentication required, handling next action...');
        final result = await Stripe.instance.handleNextAction(clientSecret);
        StripeLogger.debug('3D Secure result status: ${result.status}');

        if (result.status == PaymentIntentsStatus.Succeeded) {
          StripeLogger.info('3D Secure authentication succeeded!');
          return PaymentResult.success(
            paymentIntentId: result.id,
            transactionId: result.id,
          );
        } else {
          StripeLogger.error('3D Secure authentication failed');
          return PaymentResult.failure('Authentication required');
        }
      } else {
        StripeLogger.error('Payment not completed with status: ${paymentIntent.status}');
        return PaymentResult.failure(
          'Payment not completed: ${paymentIntent.status}',
        );
      }
    } on StripeException catch (e, stackTrace) {
      StripeLogger.error('Stripe exception in confirmPaymentWithCard', e, stackTrace);
      StripeLogger.error('Stripe error: ${e.error.localizedMessage}');
      return PaymentResult.failure(
        e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e, stackTrace) {
      StripeLogger.error('Unexpected error in confirmPaymentWithCard', e, stackTrace);
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
