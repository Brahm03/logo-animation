import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animation_lesson/src/features/home/presentation/home_page.dart';

void main() {
  testWidgets('HomePage renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    expect(find.byType(HomePage), findsOneWidget);
  });
}
