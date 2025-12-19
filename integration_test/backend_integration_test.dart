/// Backend Integration Tests
///
/// These tests run against the real backend server.
/// Ensure the backend is running at http://127.0.0.1:8080 before running.
///
/// Run with:
/// ```bash
/// dart test integration_test/backend_integration_test.dart
/// ```
library;

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

/// Backend base URL - matches AppConfig.apiBaseUrl default
const String baseUrl = 'http://127.0.0.1:8080';

/// Test logger that uses dart:developer log instead of print.
void _log(String message) {
  developer.log(message, name: 'IntegrationTest');
}

void main() {
  late http.Client client;

  setUpAll(() {
    client = http.Client();
  });

  tearDownAll(() {
    client.close();
  });

  group('Backend Health Check', () {
    test('health endpoint responds', () async {
      final response = await client.get(
        Uri.parse('$baseUrl/health'),
      );

      expect(response.statusCode, equals(200));
      _log('Health check response: ${response.body}');
    });
  });

  group('Payment Intent Endpoint', () {
    test('creates payment intent with valid data', () async {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 4999, // $49.99 in cents
          'currency': 'usd',
          'email': 'test@example.com',
          'metadata': {
            'test': 'true',
            'source': 'integration_test',
          },
        }),
      );

      _log('Payment intent response status: ${response.statusCode}');
      _log('Payment intent response body: ${response.body}');

      expect(response.statusCode, equals(200));

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Verify required fields are present
      expect(json, contains('clientSecret'));
      expect(json, contains('paymentIntentId'));
      expect(json, contains('amount'));
      expect(json, contains('currency'));

      // Verify values
      expect(json['amount'], equals(4999));
      expect(json['currency'], equals('usd'));

      // Client secret should start with pi_ and contain _secret_
      expect(json['clientSecret'], startsWith('pi_'));
      expect(json['clientSecret'], contains('_secret_'));

      // Payment intent ID should start with pi_
      expect(json['paymentIntentId'], startsWith('pi_'));
    });

    test('creates payment intent for medium wall price', () async {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 9999, // $99.99 in cents
          'currency': 'usd',
          'email': 'medium@example.com',
        }),
      );

      expect(response.statusCode, equals(200));

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      expect(json['amount'], equals(9999));
    });

    test('creates payment intent for large wall price', () async {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 14999, // $149.99 in cents
          'currency': 'usd',
          'email': 'large@example.com',
        }),
      );

      expect(response.statusCode, equals(200));

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      expect(json['amount'], equals(14999));
    });

    test('handles missing amount', () async {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currency': 'usd',
          'email': 'test@example.com',
        }),
      );

      _log('Missing amount response: ${response.statusCode} - ${response.body}');

      // Expect error response (400 or 422)
      expect(response.statusCode, anyOf(equals(400), equals(422)));
    });

    test('handles missing email', () async {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 4999,
          'currency': 'usd',
        }),
      );

      _log('Missing email response: ${response.statusCode} - ${response.body}');

      // Backend may accept without email or return error - document behavior
      // If it accepts, should still return valid payment intent
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        expect(json, contains('clientSecret'));
      }
    });

    test('handles invalid JSON', () async {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: 'not valid json',
      );

      _log('Invalid JSON response: ${response.statusCode} - ${response.body}');

      // Expect error response
      expect(response.statusCode, anyOf(equals(400), equals(422), equals(500)));
    });

    test('handles zero amount', () async {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 0,
          'currency': 'usd',
          'email': 'zero@example.com',
        }),
      );

      _log('Zero amount response: ${response.statusCode} - ${response.body}');

      // Stripe requires minimum amount of 50 cents for USD
      // Expect error from either backend validation or Stripe
      expect(response.statusCode, anyOf(equals(400), equals(422), equals(500)));
    });

    test('handles negative amount', () async {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': -100,
          'currency': 'usd',
          'email': 'negative@example.com',
        }),
      );

      _log('Negative amount response: ${response.statusCode} - ${response.body}');

      // Expect error response
      expect(response.statusCode, anyOf(equals(400), equals(422), equals(500)));
    });
  });

  group('Design Endpoint', () {
    test('design endpoint exists', () async {
      // Just test that the endpoint is reachable
      // A full design submission test would require valid wall parameters
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/design'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      _log('Design endpoint response: ${response.statusCode}');

      // Should get a validation error, not 404
      expect(response.statusCode, isNot(equals(404)));
    });
  });
}
