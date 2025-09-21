// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:social_media_clone/viewmodels/auth_viewmodel.dart';
import 'package:social_media_clone/viewmodels/post_viewmodel.dart';
import 'package:social_media_clone/views/auth/login_screen.dart';

void main() {
  testWidgets('Login screen builds without errors', (WidgetTester tester) async {
    // Build the login screen directly
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => PostViewModel()),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
        ),
      ),
    );

    // Verify that the login screen builds successfully
    expect(tester.takeException(), isNull);
    
    // Verify that we can find the login form elements
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}
