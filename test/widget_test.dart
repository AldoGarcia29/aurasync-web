import 'package:flutter_test/flutter_test.dart';
import 'package:aurasync/main.dart';

void main() {
  testWidgets(
    'Debe mostrar la pantalla de inicio de sesión',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const AuraSyncApp(),
      );

      expect(
        find.text('Bienvenido de nuevo'),
        findsOneWidget,
      );

      expect(
        find.text('Iniciar sesión'),
        findsOneWidget,
      );

      expect(
        find.text('Correo electrónico'),
        findsOneWidget,
      );

      expect(
        find.text('Contraseña'),
        findsOneWidget,
      );
    },
  );
}