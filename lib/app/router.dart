/// Application Router Configuration
///
/// Defines all routes and navigation configuration using go_router.
///
/// Routes:
/// - `/` - Information/Landing page
/// - `/design` - Main wall design page with wizard
/// - `/payment` - Payment processing page
/// - `/delivery/:requestId` - Document delivery page
///
/// Usage:
/// ```dart
/// MaterialApp.router(
///   routerConfig: appRouter,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/delivery/presentation/pages/delivery_page.dart';
import '../features/information/presentation/information_page.dart';
import '../features/payment/presentation/pages/payment_page.dart';
import '../features/wall_input/presentation/pages/wall_input_page.dart';

/// Route path constants.
abstract final class RoutePaths {
  /// Home/Information page.
  static const String home = '/';

  /// Wall design page.
  static const String design = '/design';

  /// Payment page.
  static const String payment = '/payment';

  /// Delivery page (requires requestId parameter).
  static const String delivery = '/delivery/:requestId';

  /// Gets the delivery route with the given request ID.
  static String deliveryWithId(String requestId) => '/delivery/$requestId';
}

/// Route name constants for named navigation.
abstract final class RouteNames {
  static const String home = 'home';
  static const String design = 'design';
  static const String payment = 'payment';
  static const String delivery = 'delivery';
}

/// The application router configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  debugLogDiagnostics: true,
  routes: [
    // Information/Landing page
    GoRoute(
      path: RoutePaths.home,
      name: RouteNames.home,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const InformationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    // Wall design page
    GoRoute(
      path: RoutePaths.design,
      name: RouteNames.design,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WallInputPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    // Payment page
    GoRoute(
      path: RoutePaths.payment,
      name: RouteNames.payment,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PaymentPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    // Delivery page
    GoRoute(
      path: RoutePaths.delivery,
      name: RouteNames.delivery,
      pageBuilder: (context, state) {
        final requestId = state.pathParameters['requestId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: DeliveryPage(requestId: requestId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ],

  // Error page for unknown routes
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.path}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  ),
);

/// Extension methods for easier navigation.
extension NavigationExtensions on BuildContext {
  /// Navigates to the information page.
  void goToHome() => go(RoutePaths.home);

  /// Navigates to the design page.
  void goToDesign() => go(RoutePaths.design);

  /// Navigates to the payment page.
  void goToPayment() => go(RoutePaths.payment);

  /// Navigates to the delivery page with the given request ID.
  void goToDelivery(String requestId) =>
      go(RoutePaths.deliveryWithId(requestId));
}
