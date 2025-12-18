/// Application Configuration
///
/// Environment-based configuration for API URLs and service credentials.
/// Values are injected at compile time using --dart-define flags.
///
/// Usage:
/// ```bash
/// # Development (defaults apply)
/// flutter run -d chrome
///
/// # Test environment
/// flutter run --dart-define=ENVIRONMENT=test
///
/// # Production
/// flutter run --dart-define=ENVIRONMENT=production \
///             --dart-define=API_BASE_URL=https://api.example.com/retainingwall \
///             --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx
/// ```
library;

/// Environment types for configuration.
enum Environment {
  development,
  test,
  production,
}

/// Application configuration loaded from compile-time environment variables.
abstract final class AppConfig {
  /// Current environment (development, test, production).
  /// Override with: --dart-define=ENVIRONMENT=production
  static const String _environmentName = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Parsed environment enum.
  static Environment get environment {
    switch (_environmentName.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'test':
      case 'testing':
        return Environment.test;
      default:
        return Environment.development;
    }
  }

  /// Whether running in production.
  static bool get isProduction => environment == Environment.production;

  /// Whether running in test environment.
  static bool get isTest => environment == Environment.test;

  /// Whether running in development.
  static bool get isDevelopment => environment == Environment.development;

  /// Base URL for the rwcpp backend server.
  /// Override with: --dart-define=API_BASE_URL=https://your-api.com
  /// Note: Using 127.0.0.1 instead of localhost to avoid IPv6 resolution issues
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  /// Stripe publishable key for development and test environments.
  /// This is a test mode key - safe to use for testing.
  static const String _stripeTestKey =
      'pk_test_51SVKxE0r8GpnUde9yg6oGsbY51nj0VqUs8WL21Jug7zuVBctDZ4LS6Z6jg906OROOJuVx2B5pffvdqnXIdO85sNP00kj9C8Z7j';

  /// Stripe publishable key for production.
  /// Must be provided via --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx
  static const String _stripeProductionKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '', // No default for production - must be explicitly set
  );

  /// Active Stripe publishable key based on environment.
  /// Uses test key for dev/test, production key for production.
  static String get stripePublishableKey {
    if (isProduction) {
      if (_stripeProductionKey.isEmpty) {
        throw StateError(
          'STRIPE_PUBLISHABLE_KEY must be set for production builds. '
          'Use: --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx',
        );
      }
      return _stripeProductionKey;
    }
    // Use test key for development and test environments
    return _stripeTestKey;
  }

  /// Whether we're running in demo mode (no backend required).
  /// Override with: --dart-define=DEMO_MODE=true
  static const bool demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: false,
  );

  /// Debug mode for additional logging.
  /// Override with: --dart-define=DEBUG=true
  static const bool debug = bool.fromEnvironment(
    'DEBUG',
    defaultValue: false,
  );
}
