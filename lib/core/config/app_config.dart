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
/// # Production
/// flutter run --dart-define=API_BASE_URL=https://api.example.com/retainingwall \
///             --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx
/// ```
library;

/// Application configuration loaded from compile-time environment variables.
abstract final class AppConfig {
  /// Base URL for the rwcpp backend server.
  /// Override with: --dart-define=API_BASE_URL=https://your-api.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8001/retainingwall',
  );

  /// Stripe publishable key.
  /// Override with: --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51SVKxE0r8GpnUde9yg6oGsbY51nj0VqUs8WL21Jug7zuVBctDZ4LS6Z6jg906OROOJuVx2B5pffvdqnXIdO85sNP00kj9C8Z7j',
  );

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
