import 'package:flutter_test/flutter_test.dart';
import 'package:aurasync/validators/login_validator.dart';

void main() {
  group('Validación de contraseña', () {
    test('U01: acepta una contraseña válida de más de 8 caracteres', () {
      expect(
        LoginValidator.validarPassword('Prueba12345'),
        isNull,
      );
    });

    test('U02: acepta el límite exacto de 8 caracteres', () {
      expect(
        LoginValidator.validarPassword('Abcd1234'),
        isNull,
      );
    });

    test('U03: rechaza una contraseña de 7 caracteres', () {
      expect(
        LoginValidator.validarPassword('Abcd123'),
        'Debe contener al menos 8 caracteres.',
      );
    });

    test('U04: rechaza una contraseña vacía', () {
      expect(
        LoginValidator.validarPassword(''),
        'Ingresa tu contraseña.',
      );
    });
  });

  group('Validación de correo', () {
    test('U05: acepta un correo con formato válido', () {
      expect(
        LoginValidator.validarCorreo('pruebas@example.com'),
        isNull,
      );
    });

    test('U06: rechaza un correo sin arroba', () {
      expect(
        LoginValidator.validarCorreo('pruebas.example.com'),
        'Ingresa un correo válido.',
      );
    });

    test('U07: rechaza un correo vacío', () {
      expect(
        LoginValidator.validarCorreo(''),
        'Ingresa tu correo electrónico.',
      );
    });

    test('U08: acepta un correo con espacios exteriores', () {
      expect(
        LoginValidator.validarCorreo('  pruebas@example.com  '),
        isNull,
      );
    });
  });
}