import 'package:aurasync/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'P01: registra una cuenta y recupera sus datos en dos solicitudes',
    () async {
      const baseUrl = String.fromEnvironment('API_BASE_URL');
      expect(
        Uri.tryParse(baseUrl)?.host,
        anyOf('127.0.0.1', 'localhost'),
        reason: 'P01 requiere una API local con una base de datos de pruebas.',
      );

      const name = 'Usuario Persistencia CI';
      const password = 'PruebaCI12345';
      final suffix = DateTime.now().microsecondsSinceEpoch;
      final email = 'persistencia-$suffix@example.com';

      await AuthService.registrar(
        nombre: '  $name  ',
        correo: email.toUpperCase(),
        password: password,
      );

      final session = await AuthService.iniciarSesion(
        correo: email,
        password: password,
      );
      expect(session.id, greaterThan(0));
      expect(session.nombre, name);
      expect(session.correo, email);

      await expectLater(
        AuthService.registrar(nombre: name, correo: email, password: password),
        throwsA(
          isA<AuthException>().having(
            (error) => error.mensaje,
            'mensaje',
            'Ya existe una cuenta con ese correo.',
          ),
        ),
      );

      final recovered = await AuthService.iniciarSesion(
        correo: email,
        password: password,
      );
      expect(recovered.id, session.id);
    },
  );
}
