import 'package:flutter_test/flutter_test.dart';
import 'package:fish_feeder_app/src/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const FishFeederApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Select Device'), findsWidgets);
  });
}
