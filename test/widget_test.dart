import 'package:flutter_test/flutter_test.dart';
import 'package:halopet_mobile/core/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('HaloPet logo renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HaloPetLogo())));
    expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
  });
}
