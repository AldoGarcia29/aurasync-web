class SearchResult {
  final String id;
  final String titulo;
  final String descripcion;
  final String ruta;

  const SearchResult({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ruta,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      ruta: json['ruta']?.toString() ?? '/',
    );
  }
}