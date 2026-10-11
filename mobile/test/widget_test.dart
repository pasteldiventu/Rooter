import 'package:flutter_test/flutter_test.dart';
import 'package:rooter_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RooterApp carrega áreas dos dados locais', (tester) async {
    await tester.pumpWidget(const RooterApp());
    expect(find.text('Rooter'), findsOneWidget);
    expect(find.text('Mato Grosso'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.textContaining('Área'), findsWidgets);
  });
}
