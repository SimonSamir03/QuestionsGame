import 'package:flutter_test/flutter_test.dart';
import 'package:brainplay/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrainPlayApp());
    expect(find.text('BrainPlay'), findsWidgets);
  });
}
