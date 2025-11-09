import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pentas/pages/signup_page.dart'; // ✅ ini benar

void main() {
  testWidgets('Menampilkan form Sign Up dengan benar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(5)); // contoh field
    expect(find.text('Daftar'), findsOneWidget);
  });
}
