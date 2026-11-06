import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/biometria.dart';

class BiometriaService {
  static const String _baseUrl = 
    String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://aurasync-backend-use4.onrender.com',
);

  Future<Biometria> obtenerUltima(int usuarioId) async {
    final uri = Uri.parse(
      '$_baseUrl/api/biometria/usuario/$usuarioId/ultima',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'No fue posible obtener la información biométrica.',
      );
    }

    final json = jsonDecode(
      utf8.decode(response.bodyBytes),
    ) as Map<String, dynamic>;

    return Biometria.fromJson(json);
  }

  Future<List<Biometria>> obtenerHistorial(int usuarioId) async {
  final uri = Uri.parse(
    '$_baseUrl/api/biometria/usuario/$usuarioId',
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception(
      'No fue posible obtener el historial biométrico.',
    );
  }

  final dynamic decoded = jsonDecode(
    utf8.decode(response.bodyBytes),
  );

  if (decoded is! List) {
    throw Exception('El backend devolvió un formato no válido.');
  }

  return decoded
      .map(
        (item) => Biometria.fromJson(
          item as Map<String, dynamic>,
        ),
      )
      .toList();
}
}