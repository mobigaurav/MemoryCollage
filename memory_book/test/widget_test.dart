import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_book/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('splash wordmark is Memory Book', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Memory Book'), findsOneWidget);
  });
}
