import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:aurasync/main.dart' as app;
import 'package:aurasync/screens/home_screen.dart';
import 'package:aurasync/screens/login_screen.dart';

Future<void> esperarWidget(
    WidgetTester tester,
    Finder finder, {
      Duration timeout = const Duration(seconds: 90),
    }) async {
  final reloj = Stopwatch()..start();

  while (finder.evaluate().isEmpty) {
    if (reloj.elapsed >= timeout) {
      fail('No apareció el elemento esperado: $finder');
    }

    await tester.pump(const Duration(milliseconds: 250));
  }

  // Permite terminar la transición de pantalla.
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'E01: iniciar sesión y acceder al inicio del usuario correcto',
        (tester) async {
      app.main();
      await tester.pump();

      await esperarWidget(
        tester,
        find.byType(LoginScreen),
      );

      expect(
        find.text('Bienvenido de nuevo'),
        findsOneWidget,
      );

      final campos = find.byType(TextFormField);
      expect(campos, findsNWidgets(2));

      await tester.enterText(
        campos.at(0),
        'pruebas.aurasync@example.com',
      );

      await tester.enterText(
        campos.at(1),
        'AuraTest12345',
      );

      // Cierra el teclado para poder pulsar el botón
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 300));

      final botonLogin = find.widgetWithText(
        FilledButton,
        'Iniciar sesión',
      );

      await tester.ensureVisible(botonLogin);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(botonLogin);

      // Espera la respuesta real del backend y la navegación.
      await esperarWidget(
        tester,
        find.byType(HomeScreen),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      final home = tester.widget<HomeScreen>(
        find.byType(HomeScreen),
      );

      expect(home.usuarioId, greaterThan(0));
      expect(home.nombre, 'Usuario Pruebas');

      expect(
        find.text('¡Buenos días, Usuario Pruebas! ☀️'),
        findsOneWidget,
      );

      debugPrint(
        'E01 APROBADA: login real y acceso al inicio '
            'de Usuario Pruebas.',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}