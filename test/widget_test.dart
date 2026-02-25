// This is a basic Flutter widget test for VIT Sports App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vit_sports_app/main.dart';

void main() {
  testWidgets('App loads and shows HomeScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title appears
    expect(find.text('VIT Sports App'), findsOneWidget);

    // Verify that the bottom navigation bar is present
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify navigation destinations
    expect(find.text('Football'), findsAtLeastNWidgets(1));
    expect(find.text('Badminton'), findsOneWidget);
    expect(find.text('Cricket'), findsOneWidget);
    expect(find.text('Tournaments'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Bottom navigation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap on Badminton tab
    await tester.tap(find.text('Badminton'));
    await tester.pumpAndSettle();

    // Verify Badminton screen shows
    expect(find.text('Coming Soon'), findsOneWidget);
  });
}
