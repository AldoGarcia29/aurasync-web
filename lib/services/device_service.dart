import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CodigoVinculacion {
  final String codigo;
  final DateTime fechaExpiracion;
  final int duracionMinutos;
  final String mensaje;

  const CodigoVinculacion({
    required this.codigo,
    required this.fechaExpiracion,
    required this.duracionMinutos,
    required this.mensaje,
  });

  

  factory CodigoVinculacion.fromJson(
    Map<String, dynamic> json,
  ) {
    return CodigoVinculacion(
      codigo: json['codigo'] as String,
      fechaExpiracion: DateTime.parse(
        json['fechaExpiracion'] as String,
      ).toLocal(),
      duracionMinutos:
          json['duracionMinutos'] as int,
      mensaje: json['mensaje'] as String,
    );
  }
}


class Dispositivo {
  final int id;
  final String tipo;
  final String nombre;
  final String estado;
  final DateTime? fechaConexion;
  final bool pinHabilitado;

  const Dispositivo({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.estado,
    required this.fechaConexion,
    required this.pinHabilitado,
  });

  factory Dispositivo.fromJson(
    Map<String, dynamic> json,
  ) {
    final fecha = json['fechaConexion'];

    return Dispositivo(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      nombre: json['nombre'] as String,
      estado: json['estado'] as String,
      fechaConexion: fecha == null
          ? null
          : DateTime.parse(fecha as String),
      pinHabilitado:
          json['pinHabilitado'] as bool? ?? false,
    );
  }
}

class DeviceException implements Exception {
  final String mensaje;

  const DeviceException(this.mensaje);

  @override
  String toString() => mensaje;
}

class DeviceService {
  static const String _baseUrl = 
    String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://aurasync-backend-use4.onrender.com',
);

      static Future<List<Dispositivo>>
obtenerDispositivos({
  required int usuarioId,
}) async {
  try {
    final response = await http
        .get(
          Uri.parse(
            '$_baseUrl/api/dispositivos/'
            'usuario/$usuarioId',
          ),
          headers: {
            'Accept': 'application/json',
          },
        )
        .timeout(
          const Duration(seconds: 75),
        );

    if (response.statusCode != 200) {
      throw DeviceException(
        'No se pudieron cargar los dispositivos.',
      );
    }

    final List<dynamic> body =
        jsonDecode(response.body) as List<dynamic>;

    return body
        .map(
          (item) => Dispositivo.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  } on TimeoutException {
    throw const DeviceException(
      'El servidor tardó demasiado en responder.',
    );
  } on DeviceException {
    rethrow;
  } catch (_) {
    throw const DeviceException(
      'No se pudieron cargar los dispositivos.',
    );
  }
}

  static Future<CodigoVinculacion>
  generarCodigo({
    required int usuarioId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '$_baseUrl/api/vinculacion/generar',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'usuarioId': usuarioId,
            }),
          )
          .timeout(
            const Duration(seconds: 75),
          );

      final Map<String, dynamic> body =
          response.body.isEmpty
              ? <String, dynamic>{}
              : jsonDecode(response.body)
                  as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return CodigoVinculacion.fromJson(body);
      }

      throw DeviceException(
        body['mensaje'] as String? ??
            'No se pudo generar el código.',
      );
    } on TimeoutException {
      throw const DeviceException(
        'El servidor tardó demasiado en responder.',
      );
    } on DeviceException {
      rethrow;
    } catch (_) {
      throw const DeviceException(
        'No se pudo conectar con el servidor.',
      );
    }
  }
}