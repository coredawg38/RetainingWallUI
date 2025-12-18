import 'package:flutter_test/flutter_test.dart';
import 'package:retaining_wall_builder/core/services/stripe_service.dart';

void main() {
  late StripeService stripeService;

  setUp(() {
    stripeService = StripeService();
  });

  group('Card Number Validation', () {
    test('validates empty card number', () {
      expect(stripeService.validateCardNumber(''), 'Card number is required');
    });

    test('validates card number too short', () {
      expect(stripeService.validateCardNumber('1234'), 'Invalid card number length');
    });

    test('validates card number too long', () {
      expect(stripeService.validateCardNumber('12345678901234567890'), 'Invalid card number length');
    });

    test('validates non-digit card number', () {
      // 16 characters but contains letters
      expect(stripeService.validateCardNumber('1234abcd56789012'), 'Card number must contain only digits');
    });

    test('validates invalid Luhn checksum', () {
      expect(stripeService.validateCardNumber('4111111111111112'), 'Invalid card number');
    });

    test('validates valid Visa card', () {
      // Valid test card number (passes Luhn check)
      expect(stripeService.validateCardNumber('4111111111111111'), isNull);
    });

    test('validates valid Mastercard', () {
      expect(stripeService.validateCardNumber('5555555555554444'), isNull);
    });

    test('validates valid Amex', () {
      expect(stripeService.validateCardNumber('378282246310005'), isNull);
    });

    test('handles card number with spaces', () {
      expect(stripeService.validateCardNumber('4111 1111 1111 1111'), isNull);
    });
  });

  group('Expiry Date Validation', () {
    test('validates empty expiry', () {
      expect(stripeService.validateExpiryDate(''), 'Use MM/YY format');
    });

    test('validates invalid format', () {
      expect(stripeService.validateExpiryDate('1225'), 'Use MM/YY format');
    });

    test('validates invalid month - too low', () {
      expect(stripeService.validateExpiryDate('00/25'), 'Invalid month');
    });

    test('validates invalid month - too high', () {
      expect(stripeService.validateExpiryDate('13/25'), 'Invalid month');
    });

    test('validates expired card', () {
      expect(stripeService.validateExpiryDate('01/20'), 'Card has expired');
    });

    test('validates valid future expiry', () {
      expect(stripeService.validateExpiryDate('12/30'), isNull);
    });

    test('validates current month expiry', () {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final year = (now.year % 100).toString().padLeft(2, '0');
      // Current month should be valid
      expect(stripeService.validateExpiryDate('$month/$year'), isNull);
    });
  });

  group('CVC Validation', () {
    test('validates empty CVC', () {
      expect(stripeService.validateCvc(''), 'CVC is required');
    });

    test('validates CVC too short', () {
      expect(stripeService.validateCvc('12'), 'Invalid CVC');
    });

    test('validates CVC too long', () {
      expect(stripeService.validateCvc('12345'), 'Invalid CVC');
    });

    test('validates non-digit CVC', () {
      expect(stripeService.validateCvc('12a'), 'CVC must contain only digits');
    });

    test('validates valid 3-digit CVC', () {
      expect(stripeService.validateCvc('123'), isNull);
    });

    test('validates valid 4-digit CVC (Amex)', () {
      expect(stripeService.validateCvc('1234'), isNull);
    });
  });

  group('Card Number Formatting', () {
    test('formats card number with spaces', () {
      expect(stripeService.formatCardNumber('4111111111111111'), '4111 1111 1111 1111');
    });

    test('formats partial card number', () {
      expect(stripeService.formatCardNumber('411111'), '4111 11');
    });

    test('handles already spaced input', () {
      expect(stripeService.formatCardNumber('4111 1111'), '4111 1111');
    });
  });

  group('Expiry Date Formatting', () {
    test('formats expiry date', () {
      expect(stripeService.formatExpiryDate('1225'), '12/25');
    });

    test('formats partial expiry', () {
      expect(stripeService.formatExpiryDate('12'), '12/');
    });

    test('handles already formatted input', () {
      expect(stripeService.formatExpiryDate('12/25'), '12/25');
    });
  });

  group('Card Brand Detection', () {
    test('detects Visa', () {
      expect('4111111111111111'.cardBrand, CardBrand.visa);
    });

    test('detects Mastercard (51-55 range)', () {
      expect('5555555555554444'.cardBrand, CardBrand.mastercard);
    });

    test('detects Amex (34)', () {
      expect('340000000000009'.cardBrand, CardBrand.amex);
    });

    test('detects Amex (37)', () {
      expect('378282246310005'.cardBrand, CardBrand.amex);
    });

    test('detects Discover', () {
      expect('6011111111111117'.cardBrand, CardBrand.discover);
    });

    test('returns unknown for unrecognized prefix', () {
      expect('9999999999999999'.cardBrand, CardBrand.unknown);
    });

    test('returns unknown for empty string', () {
      expect(''.cardBrand, CardBrand.unknown);
    });
  });

  group('Platform Support', () {
    test('isStripeSupportedPlatform returns boolean', () {
      // This will vary based on the platform running the test
      expect(isStripeSupportedPlatform, isA<bool>());
    });
  });
}
