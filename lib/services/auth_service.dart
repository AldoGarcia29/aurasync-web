import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UsuarioSesion {
  final int id;
  final String nombre;
  final String correo;

  const UsuarioSesion({
    required this.id,
    required this.nombre,
    required this.correo,
  });

  factory UsuarioSesion.fromJson(Map<String, dynamic> json) {
    final id = json['usuarioId'];
    final nombre = json['nombre'];
    final correo = json['correo'];

    if (id is! int || nombre is! String || correo is! String) {
      throw const FormatException(
        'Los datos del usuario no tienen el formato esperado.',
      );
    }

    return UsuarioSesion(
      id: id,
      nombre: nombre,
      correo: correo,
    );
  }
}

class AuthException implements Exception {
  final String mensaje;

  const AuthException(this.mensaje);

  @override
  String toString() => mensaje;
}

class AuthService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://aurasync-backend-use4.onrender.com',
  );

  static const _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Estos mensajes solo se imprimen en modo depuración.
  // No se registran contraseñas, tokens ni cuerpos completos.
  static void _log(String mensaje) {
    if (kDebugMode) {
      debugPrint('[AuraSync] $mensaje');
    }
  }

  static Map<String, dynamic>? _leerJson(http.Response response) {
    final texto = utf8.decode(response.bodyBytes);

    if (texto.trim().isEmpty) {
      return null;
    }

    final contenido = jsonDecode(texto);

    if (contenido is! Map<String, dynamic>) {
      throw const FormatException(
        'Se esperaba un objeto JSON.',
      );
    }

    return contenido;
  }

  static Future<UsuarioSesion> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final cronometro = Stopwatch()..start();

    _log('POST /api/auth/login | Iniciando solicitud');

    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'correo': correo.trim().toLowerCase(),
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 75));

      cronometro.stop();

      _log(
        'POST /api/auth/login '
            '| HTTP ${response.statusCode} '
            '| ${cronometro.elapsedMilliseconds} ms',
      );

      if (response.statusCode == 400) {
        throw const AuthException(
          'Revisa el formato del correo y la contraseña.',
        );
      }

      if (response.statusCode == 401) {
        throw const AuthException(
          'Correo o contraseña incorrectos.',
        );
      }

      if (response.statusCode != 200) {
        throw AuthException(
          'Error del servidor (${response.statusCode}).',
        );
      }

      final body = _leerJson(response);

      if (body == null) {
        throw const FormatException('Respuesta vacía.');
      }

      final usuario = UsuarioSesion.fromJson(body);

      _log(
        'Login confirmado '
            '| usuarioId=${usuario.id} '
            '| nombre y correo recibidos',
      );

      return usuario;
    } on TimeoutException {
      _log(
        'Login: tiempo de espera agotado '
            '| ${cronometro.elapsedMilliseconds} ms',
      );

      throw const AuthException(
        'El servidor tardó demasiado en responder.',
      );
    } on http.ClientException {
      _log(
        'Login: fallo de comunicación '
            '| ${cronometro.elapsedMilliseconds} ms',
      );

      throw const AuthException(
        'No se pudo conectar con el servidor. '
            'Revisa tu conexión e intenta nuevamente.',
      );
    } on FormatException {
      _log('Login: respuesta con formato inválido');

      throw const AuthException(
        'La respuesta del servidor no es válida.',
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      _log('Login: error inesperado');

      throw const AuthException(
        'No se pudo completar el inicio de sesión.',
      );
    } finally {
      cronometro.stop();
    }
  }

  static Future<void> registrar({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final nombreEnviado = nombre.trim();
    final correoEnviado = correo.trim().toLowerCase();
    final cronometro = Stopwatch()..start();

    _log('POST /api/auth/registro | Iniciando solicitud');

    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/api/auth/registro'),
        headers: _headers,
        body: jsonEncode({
          'nombre': nombreEnviado,
          'correo': correoEnviado,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 75));

      cronometro.stop();

      _log(
        'POST /api/auth/registro '
            '| HTTP ${response.statusCode} '
            '| ${cronometro.elapsedMilliseconds} ms',
      );

      if (response.statusCode == 409) {
        throw const AuthException(
          'Ya existe una cuenta con ese correo.',
        );
      }

      if (response.statusCode == 400) {
        throw const AuthException(
          'Revisa los datos del registro.',
        );
      }

      if (response.statusCode != 201) {
        throw AuthException(
          'Error del servidor (${response.statusCode}).',
        );
      }

      final body = _leerJson(response);

      if (body == null) {
        throw const FormatException('Respuesta vacía.');
      }

      final usuario = UsuarioSesion.fromJson(body);

      final nombreCoincide = usuario.nombre == nombreEnviado;
      final correoCoincide = usuario.correo == correoEnviado;

      _log(
        'Integridad de respuesta de registro '
            '| usuarioId=${usuario.id} '
            '| nombre coincide=$nombreCoincide '
            '| correo coincide=$correoCoincide',
      );

      if (!nombreCoincide || !correoCoincide) {
        throw const AuthException(
          'El servidor informó que creó la cuenta, pero los datos '
              'recibidos no coinciden con los enviados. '
              'Verifica la cuenta antes de volver a registrarte.',
        );
      }

      _log('Registro confirmado por el servidor');
    } on TimeoutException {
      _log(
        'Registro: tiempo de espera agotado '
            '| ${cronometro.elapsedMilliseconds} ms',
      );

      throw const AuthException(
        'El servidor tardó demasiado en responder. '
            'No se pudo confirmar el registro. '
            'Intenta iniciar sesión antes de volver a registrarte.',
      );
    } on http.ClientException {
      _log(
        'Registro: fallo de comunicación '
            '| ${cronometro.elapsedMilliseconds} ms',
      );

      throw const AuthException(
        'No se pudo confirmar el registro por un problema de conexión. '
            'Revisa internet e intenta iniciar sesión antes de repetirlo.',
      );
    } on FormatException {
      _log('Registro: respuesta con formato inválido');

      throw const AuthException(
        'La respuesta del servidor no es válida. '
            'Verifica si puedes iniciar sesión antes de repetir el registro.',
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      _log('Registro: error inesperado');

      throw const AuthException(
        'No se pudo confirmar el registro. '
            'Verifica si puedes iniciar sesión antes de repetirlo.',
      );
    } finally {
      cronometro.stop();
    }
  }

  static Future<void> cerrarSesion() async {
    // Pendiente: invalidación de sesión en el backend.
  }
}