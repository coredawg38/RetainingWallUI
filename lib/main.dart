/// Retaining Wall Design Application
///
/// A Flutter application for designing retaining walls with real-time preview,
/// customer information collection, payment processing, and document delivery.
///
/// Usage:
/// ```dart
/// void main() {
///   runApp(const ProviderScope(child: RetainingWallApp()));
/// }
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: RetainingWallApp()));
}

/// The root widget of the Retaining Wall Design application.
///
/// This widget sets up:
/// - Material 3 theming via [AppTheme]
/// - Navigation via go_router
/// - State management via Riverpod (provided by parent [ProviderScope])
class RetainingWallApp extends StatelessWidget {
  const RetainingWallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Retaining Wall Designer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
