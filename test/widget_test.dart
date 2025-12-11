import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retaining_wall_builder/main.dart';

void main() {
  testWidgets('App loads with information page', (WidgetTester tester) async {
    // Set a larger surface size to avoid overflow issues
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const ProviderScope(
        child: RetainingWallApp(),
      ),
    );

    // The app title should be in the AppBar
    expect(find.text('Retaining Wall Designer'), findsOneWidget);

    // Reset the surface size
    addTearDown(tester.view.reset);
  });
}
