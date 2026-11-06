import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:aurasync/services/auth_service.dart';

void main() {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  const correo = 'pruebas.aurasync@example.com';
  const password = 'AuraTest12345';

  group('Integración real: AuthService y API', () {
    test(
      'I01: credenciales correctas devuelven el usuario esperado',
          () async {
        final usuario = await AuthService.iniciarSesion(
          correo: correo,
          password: password,
        );

        expect(usuario.id, greaterThan(0));
        expect(usuario.nombre, 'Usuario Pruebas');
        expect(usuario.correo, correo);
      },
      timeout: const Timeout(Duration(seconds: 90)),
    );

    test(
      'I02: contraseña incorrecta produce un rechazo de autenticación',
          () async {
        // Verifica que la API realmente responde 401.
        // Un fallo de conexión no debe contar como un rechazo correcto.
        final response = await http
            .post(
          Uri.parse('$baseUrl/api/auth/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'correo': correo,
            'password': 'Incorrecta98765',
          }),
        )
            .timeout(const Duration(seconds: 75));

        expect(
          response.statusCode,
          401,
          reason: 'La API debe rechazar las credenciales con HTTP 401.',
        );

        final body = response.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(response.body) as Map<String, dynamic>;

        final mensajeEsperado =
            body['mensaje'] as String? ??
                'Correo o contraseña incorrectos.';

        // Verifica cómo interpreta el servicio real ese rechazo.
        await expectLater(
          AuthService.iniciarSesion(
            correo: correo,
            password: 'Incorrecta98765',
          ),
          throwsA(
            isA<AuthException>().having(
                  (error) => error.mensaje,
              'mensaje',
              mensajeEsperado,
            ),
          ),
        );
      },
      timeout: const Timeout(Duration(seconds: 170)),
    );
  });
}