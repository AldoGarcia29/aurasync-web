import 'package:aurasync/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('U09: la sesión conserva los datos devueltos por la API', () {
    final session = UsuarioSesion.fromJson({
      'usuarioId': 24,
      'nombre': 'Usuario CI',
      'correo': 'ci@example.com',
    });

    expect(session.id, 24);
    expect(session.nombre, 'Usuario CI');
    expect(session.correo, 'ci@example.com');
  });

  test('U10: un identificador nulo produce FormatException', () {
    expect(
      () => UsuarioSesion.fromJson({
        'usuarioId': null,
        'nombre': 'Usuario CI',
        'correo': 'ci@example.com',
      }),
      throwsFormatException,
    );
  });
}
