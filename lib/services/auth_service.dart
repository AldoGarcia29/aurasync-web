import 'dart:async';
import 'dart:convert';

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

  factory UsuarioSesion.fromJson(
    Map<String, dynamic> json,
  ) {
    return UsuarioSesion(
      id: json['usuarioId'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
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
  static const String _baseUrl = 
    String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

  static Future<UsuarioSesion> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '$_baseUrl/api/auth/login',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'correo': correo.trim(),
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      Map<String, dynamic>? body;

      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body)
            as Map<String, dynamic>;
      }

      if (response.statusCode == 200) {
        if (body == null) {
          throw const AuthException(
            'El servidor devolvió una respuesta vacía.',
          );
        }

        return UsuarioSesion.fromJson(body);
      }

      if (response.statusCode == 400) {
        throw const AuthException(
          'Revisa el formato del correo y la contraseña.',
        );
      }

      if (response.statusCode == 401) {
        throw AuthException(
          body?['mensaje'] as String? ??
              'Correo o contraseña incorrectos.',
        );
      }

      throw AuthException(
        'Error del servidor (${response.statusCode}).',
      );
    } on TimeoutException {
      throw const AuthException(
        'El servidor tardó demasiado en responder.',
      );
    } on FormatException {
      throw const AuthException(
        'La respuesta del servidor no es válida.',
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'No se pudo conectar con el servidor.',
      );
    }
  }

  static Future<void> registrar({
  required String nombre,
  required String correo,
  required String password,
}) async {
  try {
    final response = await http
        .post(
          Uri.parse(
            '$_baseUrl/api/auth/registro',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'nombre': nombre.trim(),
            'correo': correo.trim().toLowerCase(),
            'password': password,
          }),
        )
        .timeout(
          const Duration(seconds: 10),
        );

    Map<String, dynamic>? body;

    if (response.body.isNotEmpty) {
      body = jsonDecode(response.body)
          as Map<String, dynamic>;
    }

    if (response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 409) {
      throw AuthException(
        body?['mensaje']?.toString() ??
            'Ya existe una cuenta con ese correo.',
      );
    }

    if (response.statusCode == 400) {
      throw const AuthException(
        'Revisa los datos del registro.',
      );
    }

    throw AuthException(
      body?['mensaje']?.toString() ??
          'Error del servidor (${response.statusCode}).',
    );
  } on TimeoutException {
    throw const AuthException(
      'El servidor tardó demasiado en responder.',
    );
  } on FormatException {
    throw const AuthException(
      'La respuesta del servidor no es válida.',
    );
  } on AuthException {
    rethrow;
  } catch (_) {
    throw const AuthException(
      'No se pudo conectar con el servidor.',
    );
  }
}

  static Future<void> cerrarSesion() async {
    // Más adelante enviaremos la petición para invalidar
    // el token o la sesión en el backend.
  }
}