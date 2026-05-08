import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Simple smoke widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Notes'),
        ),
      ),
    );

    expect(find.text('Notes'), findsOneWidget);
  });
}
