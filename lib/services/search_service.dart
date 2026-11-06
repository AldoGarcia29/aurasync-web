import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/search_result.dart';

class SearchService {
  static const String _baseUrl = 
    String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://aurasync-backend-use4.onrender.com',
);

  Future<List<SearchResult>> buscar(String texto) async {
    final uri = Uri.parse('$_baseUrl/api/search').replace(
      queryParameters: {
        'q': texto.trim(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'No fue posible realizar la búsqueda. '
        'Código: ${response.statusCode}',
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
          (item) => SearchResult.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}