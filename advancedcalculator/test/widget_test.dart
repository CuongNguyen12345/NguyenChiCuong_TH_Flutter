import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lab3/main.dart';
import 'package:lab3/models/calculator_settings.dart';
import 'package:lab3/services/storage_service.dart';

void main() {
  testWidgets('calculator screen renders title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.binding.setSurfaceSize(const Size(800, 1200));

    await tester.pumpWidget(
      MyApp(
        storageService: StorageService(),
        initialSettings: const CalculatorSettings(),
        initialMemory: 0,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Advanced Calculator'), findsOneWidget);
    expect(find.text('Basic'), findsWidgets);

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
