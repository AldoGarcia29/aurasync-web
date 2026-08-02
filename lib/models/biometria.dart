class Biometria {
  final int id;
  final int usuarioId;
  final int ritmoCardiaco;
  final int pasos;
  final int actividadMinutos;
  final double horasSueno;
  final DateTime fecha;

  const Biometria({
    required this.id,
    required this.usuarioId,
    required this.ritmoCardiaco,
    required this.pasos,
    required this.actividadMinutos,
    required this.horasSueno,
    required this.fecha,
  });

  factory Biometria.fromJson(Map<String, dynamic> json) {
    return Biometria(
      id: (json['id'] as num?)?.toInt() ?? 0,
      usuarioId: (json['usuarioId'] as num?)?.toInt() ?? 0,
      ritmoCardiaco:
          (json['ritmoCardiaco'] as num?)?.toInt() ?? 0,
      pasos: (json['pasos'] as num?)?.toInt() ?? 0,
      actividadMinutos:
          (json['actividadMinutos'] as num?)?.toInt() ?? 0,
      horasSueno:
          (json['horasSueno'] as num?)?.toDouble() ?? 0,
      fecha: DateTime.tryParse(
            json['fecha']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}