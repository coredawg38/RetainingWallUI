/// Wall Input Validator
///
/// Provides JSON Schema validation for retaining wall input data.
/// Uses the json_schema package to validate against the server's expected schema.
///
/// Usage:
/// ```dart
/// final validator = WallInputValidator();
/// final result = validator.validate(inputJson);
/// if (!result.isValid) {
///   print(result.errors);
/// }
/// ```
library;

import 'package:json_schema/json_schema.dart';

import '../../../../core/constants/app_constants.dart';

/// Result of a validation operation.
class ValidationResult {
  /// Whether the validation passed.
  final bool isValid;

  /// List of validation error messages.
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  /// Creates a successful validation result.
  factory ValidationResult.success() => const ValidationResult(isValid: true);

  /// Creates a failed validation result with error messages.
  factory ValidationResult.failure(List<String> errors) => ValidationResult(
        isValid: false,
        errors: errors,
      );
}

/// Validates retaining wall input against the JSON schema.
///
/// Ensures that all required fields are present and have valid values
/// before submitting to the server.
class WallInputValidator {
  late final JsonSchema _schema;
  bool _initialized = false;

  /// The JSON schema definition matching the rwcpp server expectations.
  static const Map<String, dynamic> _schemaDefinition = {
    '\$schema': 'http://json-schema.org/draft-07/schema#',
    'title': 'RetainingWallInput',
    'type': 'object',
    'properties': {
      'height': {
        'type': 'number',
        'minimum': WallConstraints.minHeight,
        'maximum': WallConstraints.maxHeight,
        'description': 'Wall height in inches (24-144)',
      },
      'material': {
        'type': 'integer',
        'enum': [0, 1],
        'description': '0=concrete, 1=CMU',
      },
      'surcharge': {
        'type': 'integer',
        'enum': [0, 1, 2, 4],
        'description': '0=flat, 1=1:1, 2=1:2, 4=1:4 slope',
      },
      'optimization_parameter': {
        'type': 'integer',
        'enum': [0, 1],
        'description': '0=excavation, 1=footing',
      },
      'soil_stiffness': {
        'type': 'integer',
        'enum': [0, 1],
        'description': '0=stiff, 1=soft',
      },
      'topping': {
        'type': 'integer',
        'minimum': WallConstraints.minTopping,
        'maximum': WallConstraints.maxTopping,
        'description': 'Topsoil thickness in inches',
      },
      'has_slab': {
        'type': 'boolean',
        'description': 'Whether the wall has a slab',
      },
      'toe': {
        'type': 'integer',
        'minimum': WallConstraints.minToe,
        'maximum': WallConstraints.maxToe,
        'description': 'Toe length in inches',
      },
      'site_address': {
        'type': 'object',
        'properties': {
          'street': {'type': 'string', 'minLength': 1},
          'City': {'type': 'string', 'minLength': 1},
          'State': {'type': 'string', 'minLength': 2, 'maxLength': 2},
          'Zip Code': {'type': 'integer', 'minimum': 10000, 'maximum': 99999},
        },
        'required': ['street', 'City', 'State', 'Zip Code'],
      },
      'customer_info': {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'minLength': 1},
          'email': {
            'type': 'string',
            'format': 'email',
            'pattern': r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
          },
          'phone': {'type': 'string', 'minLength': 10},
          // mailing_address is optional for digital-only delivery
          'mailing_address': {
            'type': 'object',
            'properties': {
              'street': {'type': 'string'},
              'City': {'type': 'string'},
              'State': {'type': 'string', 'maxLength': 2},
              'Zip Code': {'type': 'integer'},
            },
          },
        },
        'required': ['name', 'email', 'phone'],
      },
    },
    'required': [
      'height',
      'material',
      'surcharge',
      'optimization_parameter',
      'soil_stiffness',
      'topping',
      'has_slab',
      'toe',
      'site_address',
      'customer_info',
    ],
  };

  /// Initializes the validator with the JSON schema.
  ///
  /// This must be called before [validate].
  Future<void> initialize() async {
    if (!_initialized) {
      _schema = JsonSchema.create(_schemaDefinition);
      _initialized = true;
    }
  }

  /// Validates the input data against the JSON schema.
  ///
  /// [input] is a JSON-serializable map representing the wall input.
  ///
  /// Returns a [ValidationResult] indicating success or failure with errors.
  ValidationResult validate(Map<String, dynamic> input) {
    if (!_initialized) {
      return ValidationResult.failure(['Validator not initialized']);
    }

    final validationErrors = <String>[];
    final result = _schema.validate(input);

    if (!result.isValid) {
      for (final error in result.errors) {
        validationErrors.add(_formatError(error));
      }
    }

    // Additional custom validation
    validationErrors.addAll(_validateCustomRules(input));

    return validationErrors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(validationErrors);
  }

  /// Formats a schema validation error into a user-friendly message.
  String _formatError(ValidationError error) {
    final path = error.instancePath.isNotEmpty ? error.instancePath : 'root';
    return '$path: ${error.message}';
  }

  /// Performs additional custom validation beyond the JSON schema.
  List<String> _validateCustomRules(Map<String, dynamic> input) {
    final errors = <String>[];

    // Validate email format more strictly
    final customerInfo = input['customer_info'] as Map<String, dynamic>?;
    if (customerInfo != null) {
      final email = customerInfo['email'] as String?;
      if (email != null && !_isValidEmail(email)) {
        errors.add('customer_info.email: Invalid email format');
      }

      final phone = customerInfo['phone'] as String?;
      if (phone != null && !_isValidPhone(phone)) {
        errors.add('customer_info.phone: Invalid phone format');
      }
    }

    // Validate height is within range
    final height = input['height'] as num?;
    if (height != null) {
      if (height < WallConstraints.minHeight) {
        errors.add(
          'height: Must be at least ${WallConstraints.minHeight} inches',
        );
      }
      if (height > WallConstraints.maxHeight) {
        errors.add(
          'height: Must be at most ${WallConstraints.maxHeight} inches',
        );
      }
    }

    return errors;
  }

  /// Validates an email address format.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  /// Validates a phone number format.
  bool _isValidPhone(String phone) {
    // Remove common formatting characters
    final digitsOnly = phone.replaceAll(RegExp(r'[\s\-\(\)\.]+'), '');
    // Check for 10-11 digits (with optional country code)
    return digitsOnly.length >= 10 && digitsOnly.length <= 11;
  }

  /// Validates a single field and returns an error message if invalid.
  String? validateField(String fieldPath, dynamic value) {
    switch (fieldPath) {
      case 'height':
        if (value is! num) return 'Height must be a number';
        if (value < WallConstraints.minHeight) {
          return 'Height must be at least ${WallConstraints.minHeight} inches';
        }
        if (value > WallConstraints.maxHeight) {
          return 'Height must be at most ${WallConstraints.maxHeight} inches';
        }
        return null;

      case 'material':
        if (value is! int || (value != 0 && value != 1)) {
          return 'Invalid material type';
        }
        return null;

      case 'surcharge':
        if (value is! int || ![0, 1, 2, 4].contains(value)) {
          return 'Invalid surcharge type';
        }
        return null;

      case 'topping':
        if (value is! int) return 'Topping must be a whole number';
        if (value < WallConstraints.minTopping) {
          return 'Topping must be at least ${WallConstraints.minTopping} inches';
        }
        if (value > WallConstraints.maxTopping) {
          return 'Topping must be at most ${WallConstraints.maxTopping} inches';
        }
        return null;

      case 'toe':
        if (value is! int) return 'Toe must be a whole number';
        if (value < WallConstraints.minToe) {
          return 'Toe must be at least ${WallConstraints.minToe} inches';
        }
        if (value > WallConstraints.maxToe) {
          return 'Toe must be at most ${WallConstraints.maxToe} inches';
        }
        return null;

      case 'email':
        if (value is! String || value.isEmpty) return 'Email is required';
        if (!_isValidEmail(value)) return 'Invalid email format';
        return null;

      case 'phone':
        if (value is! String || value.isEmpty) return 'Phone is required';
        if (!_isValidPhone(value)) return 'Invalid phone format';
        return null;

      case 'zipCode':
        if (value is! int) return 'ZIP code must be a number';
        if (value < 10000 || value > 99999) return 'Invalid ZIP code';
        return null;

      case 'state':
        if (value is! String || value.length != 2) {
          return 'State must be a 2-letter abbreviation';
        }
        return null;

      default:
        return null;
    }
  }
}
