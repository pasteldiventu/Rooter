import 'package:flutter_test/flutter_test.dart';
import 'package:rooter_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RooterApp carrega áreas dos dados locais', (tester) async {
    await tester.pumpWidget(const RooterApp());
    expect(find.text('Distrito 4440'), findsOneWidget);
    expect(find.text('Mato Grosso'), findsOneWidget);

    // Splash tem LinearProgressIndicator; espera o Future do catálogo local.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Equipe Distrital'), findsOneWidget);
    expect(find.textContaining('Área'), findsWidgets);
  });
}
