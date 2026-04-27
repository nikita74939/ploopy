import 'package:flutter_test/flutter_test.dart';
import 'package:ploopy/app.dart';

void main() {
  testWidgets('Ploopy smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PloopyApp());
  });
}