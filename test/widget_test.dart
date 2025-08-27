import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sacco_secure/app.dart';

void main() {
  testWidgets('SaccoApp loads LoginScreen', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const SaccoApp());

    // Verify the LoginScreen is displayed
    expect(find.text('Secure Login'), findsOneWidget); // app bar title
    expect(find.byType(TextField), findsNWidgets(2)); // username & password
    expect(find.byType(ElevatedButton), findsOneWidget); // sign in button
  });
}
