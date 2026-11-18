import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aurasync/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

void main() {
  const email = 'ci@example.com';
  const password = 'PruebaCI123';
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() => server.close(force: true));

  Future<UsuarioSesion> login() => http.runWithClient(
    () => AuthService.iniciarSesion(
      correo: ' CI@EXAMPLE.COM ',
      password: password,
    ),
    () => _LocalClient(server.port),
  );

  test('I01: envía POST JSON y convierte HTTP 200 en una sesión', () async {
    final received = Completer<Map<String, dynamic>>();
    server.listen((request) async {
      received.complete({
        'method': request.method,
        'path': request.uri.path,
        'contentType': request.headers.contentType?.mimeType,
        'body': jsonDecode(await utf8.decoder.bind(request).join()),
      });
      request.response
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'usuarioId': 24,
            'nombre': 'Usuario CI',
            'correo': email,
          }),
        );
      await request.response.close();
    });

    final session = await login();

    expect(await received.future, {
      'method': 'POST',
      'path': '/api/auth/login',
      'contentType': 'application/json',
      'body': {'correo': email, 'password': password},
    });
    expect(session.id, 24);
    expect(session.correo, email);
  });

  test('I02: traduce HTTP 401 al mensaje de credenciales', () async {
    server.listen((request) async {
      await request.drain<void>();
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
    });

    await expectLater(
      login(),
      throwsA(
        isA<AuthException>().having(
          (error) => error.mensaje,
          'mensaje',
          'Correo o contraseña incorrectos.',
        ),
      ),
    );
  });

  test('I03: traduce el cierre de la conexión a un mensaje de red', () async {
    server.listen((request) async {
      await request.drain<void>();
      final socket = await request.response.detachSocket(writeHeaders: false);
      socket.destroy();
    });

    await expectLater(
      login(),
      throwsA(
        isA<AuthException>().having(
          (error) => error.mensaje,
          'mensaje',
          'No se pudo conectar con el servidor. '
              'Revisa tu conexión e intenta nuevamente.',
        ),
      ),
    );
  });
}

class _LocalClient extends http.BaseClient {
  _LocalClient(this.port);

  final int port;
  final http.Client _transport = IOClient();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final original = request as http.Request;
    final local =
        http.Request(
            original.method,
            original.url.replace(scheme: 'http', host: '127.0.0.1', port: port),
          )
          ..headers.addAll(original.headers)
          ..bodyBytes = original.bodyBytes;

    return _transport.send(local);
  }

  @override
  void close() => _transport.close();
}
