import 'package:flutter_test/flutter_test.dart';

import 'package:train_ledger/main.dart';

void main() {
  testWidgets('Hello Ledger smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TrainLedgerApp());

    expect(find.text('Hello Ledger'), findsOneWidget);
    expect(find.text('铁道运转记录程序'), findsOneWidget);
  });
}
