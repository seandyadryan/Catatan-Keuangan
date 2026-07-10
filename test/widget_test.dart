import 'package:catatan_keuangan_pro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Catatan Keuangan PRO opens home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FinanceApp());
    expect(find.text('Catatan Keuangan PRO'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    expect(find.text('Harian'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
