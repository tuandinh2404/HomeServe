import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeserve_flutter/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeServeApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}