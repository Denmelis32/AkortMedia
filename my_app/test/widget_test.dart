// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('Test app startup', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Build our app with isLoggedIn = false
    await tester.pumpWidget(MyApp(isLoggedIn: false));

    // Verify that LoginPage is shown
    expect(find.text('Вход'), findsOneWidget);
  });

  testWidgets('Test app startup when logged in', (WidgetTester tester) async {
    // Mock SharedPreferences with user data
    SharedPreferences.setMockInitialValues({
      'auth_token': 'mock_token',
      'user_data': '{"name": "Test User", "email": "test@example.com"}',
    });

    // Build our app with isLoggedIn = true
    await tester.pumpWidget(MyApp(isLoggedIn: true));

    // Verify that HomePage is shown
    expect(find.byType(HomePage), findsOneWidget);
  });
}